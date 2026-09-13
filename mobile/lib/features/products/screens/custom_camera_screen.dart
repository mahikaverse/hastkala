import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/widgets/voice_mute_button.dart';

class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _showCapturedOverlay = false;
  bool _showProcessing = false;
  late AnimationController _flashController;
  late Animation<double> _flashOpacity;

  // Real-time height detection state
  double _topLineY = 0.29; // Normalized position (0.0 - 1.0)
  double _bottomLineY = 0.71; // Normalized position (0.0 - 1.0)
  bool _showRuler = true;
  static const double _cameraFOV = 53.0; // Typical smartphone camera vertical FOV in degrees

  // Voice guidance TTS
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );
    _ttsService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playGuidance();
    });
    _initCamera();
  }

  void _playGuidance() {
    if (!mounted) return;
    final lang = LanguageProvider.of(context);
    final langCode = lang.langCode;
    final text = langCode == 'hi' ? lang.t('cameraTtsGuidanceHi') : lang.t('cameraTtsGuidanceEn');
    _ttsService.speak(text, language: langCode);
  }

  /// Calculates detected height in cm at typical holding distance (~30cm)
  double _calculateHeight() {
    final heightRatio = (_bottomLineY - _topLineY).abs();
    // At ~30cm distance, visible height is 2 * 30 * tan(FOV / 2)
    final visibleHeight = 2 * 30.0 * math.tan(_cameraFOV * math.pi / 360.0);
    return heightRatio * visibleHeight;
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) Navigator.pop(context);
        return;
      }
      await _setupCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      if (mounted) {
        final lang = LanguageProvider.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('cameraNotAvailable')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            backgroundColor: AppColors.charcoal,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    _controller?.dispose();
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        final lang = LanguageProvider.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('couldNotStartCamera')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            backgroundColor: AppColors.charcoal,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;
    _ttsService.stop();
    setState(() => _isCapturing = true);
    try {
      // Flash effect
      await _flashController.forward();
      _flashController.reverse();
      
      final XFile photo = await _controller!.takePicture();
      
      if (!mounted) return;
      
      // Show captured overlay
      setState(() {
        _showCapturedOverlay = true;
        _isCapturing = false;
      });
      
      // Wait a moment to show the checkmark
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (!mounted) return;
      
      // Show processing state
      setState(() {
        _showCapturedOverlay = false;
        _showProcessing = true;
      });
      
      // Wait to show processing
      await Future.delayed(const Duration(milliseconds: 600));
      
      if (mounted) {
        final double? detectedHeight = _showRuler ? _calculateHeight() : null;
        final String? heightStr = detectedHeight != null
            ? '${detectedHeight.toStringAsFixed(1)} cm'
            : null;
        final double? heightVal = detectedHeight != null
            ? double.parse(detectedHeight.toStringAsFixed(1))
            : null;

        Navigator.pop(context, {
          'imagePath': photo.path,
          'height': heightStr,
          'heightValue': heightVal,
        });
      }
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _showCapturedOverlay = false;
        _showProcessing = false;
      });
      if (mounted) {
        final lang = LanguageProvider.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('failedToCapture')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            backgroundColor: AppColors.charcoal,
          ),
        );
      }
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _isInitialized = false;
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    });
    await _setupCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _openGallery() async {
    _ttsService.stop();
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        Navigator.pop(context, {
          'imagePath': image.path,
          'height': null,
          'heightValue': null,
        });
      }
    } catch (e) {
      if (mounted) {
        final lang = LanguageProvider.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lang.t('couldNotOpenGallery')),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            backgroundColor: AppColors.charcoal,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _flashController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final detectedHeight = _calculateHeight();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_isInitialized && _controller != null)
            _buildCameraPreview()
          else
            const Center(
              child: CircularProgressIndicator(color: AppColors.cream),
            ),

          // Single Vertical Ruler Scale & Calipers (when enabled)
          if (_showRuler && _isInitialized) ...[
            _buildHorizontalCaliper(isTop: true, screenHeight: screenHeight),
            _buildHorizontalCaliper(isTop: false, screenHeight: screenHeight),
            _buildVerticalRulerScale(screenHeight),
            _buildHeightBadge(screenHeight, detectedHeight),
            _buildDistanceGuide(),
          ],

          _buildTopBar(),
          _buildBottomBar(),

          // Flash overlay
          AnimatedBuilder(
            animation: _flashOpacity,
            builder: (context, child) {
              if (_flashOpacity.value == 0) return const SizedBox.shrink();
              return Opacity(
                opacity: _flashOpacity.value,
                child: Container(color: Colors.white),
              );
            },
          ),
          // Captured overlay
          if (_showCapturedOverlay) _buildCapturedOverlay(),
          // Processing overlay
          if (_showProcessing) _buildProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _controller!;
    return Center(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  static const double _rulerTopFraction = 0.14;
  static const double _rulerBottomFraction = 0.74;

  Widget _buildVerticalRulerScale(double screenHeight) {
    final rulerTop = screenHeight * _rulerTopFraction;
    final rulerHeight = screenHeight * (_rulerBottomFraction - _rulerTopFraction);
    final topRatio = ((screenHeight * _topLineY) - rulerTop) / rulerHeight;
    final bottomRatio = ((screenHeight * _bottomLineY) - rulerTop) / rulerHeight;

    return Positioned(
      top: rulerTop,
      right: 12,
      width: 46,
      height: rulerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Scale Painter (graduations, numbers, active range highlight)
          Positioned.fill(
            child: CustomPaint(
              painter: VerticalRulerPainter(
                topRatio: topRatio.clamp(0.0, 1.0),
                bottomRatio: bottomRatio.clamp(0.0, 1.0),
                maxCm: 30.0,
              ),
            ),
          ),
          // Top Slider Handle (Draggable directly on ruler)
          Positioned(
            top: (topRatio * rulerHeight) - 16,
            left: -16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                setState(() {
                  final deltaY = details.delta.dy / screenHeight;
                  _topLineY = (_topLineY + deltaY).clamp(_rulerTopFraction, _bottomLineY - 0.04);
                });
              },
              child: _buildScaleThumb(isTop: true),
            ),
          ),
          // Bottom Slider Handle (Draggable directly on ruler)
          Positioned(
            top: (bottomRatio * rulerHeight) - 16,
            left: -16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (details) {
                setState(() {
                  final deltaY = details.delta.dy / screenHeight;
                  _bottomLineY = (_bottomLineY + deltaY).clamp(_topLineY + 0.04, _rulerBottomFraction);
                });
              },
              child: _buildScaleThumb(isTop: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleThumb({required bool isTop}) {
    return SizedBox(
      width: 34,
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_right_rounded,
            color: AppColors.mustardGold,
            size: 20,
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mustardGold,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCaliper({required bool isTop, required double screenHeight}) {
    final currentY = isTop ? _topLineY : _bottomLineY;

    return Positioned(
      top: (screenHeight * currentY) - 20,
      left: 16,
      right: 64, // Leaves space for the ruler on the right
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          setState(() {
            final deltaY = details.delta.dy / screenHeight;
            if (isTop) {
              _topLineY = (_topLineY + deltaY).clamp(_rulerTopFraction, _bottomLineY - 0.04);
            } else {
              _bottomLineY = (_bottomLineY + deltaY).clamp(_topLineY + 0.04, _rulerBottomFraction);
            }
          });
        },
        child: SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Delicate laser guideline with left fade
              Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.mustardGold.withValues(alpha: 0.35),
                      AppColors.mustardGold.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.25, 1.0],
                  ),
                ),
              ),
              // Caliper tick at the left edge
              Positioned(
                left: 10,
                child: Container(
                  width: 2,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.mustardGold.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Caliper label pill
              Positioned(
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.mustardGold.withValues(alpha: 0.6),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isTop ? 'TOP' : 'BASE',
                    style: const TextStyle(
                      color: AppColors.mustardGold,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeightBadge(double screenHeight, double detectedHeight) {
    final midY = screenHeight * ((_topLineY + _bottomLineY) / 2);

    return Positioned(
      top: midY - 18,
      right: 70,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(
              color: AppColors.mustardGold,
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mustardGold.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📏', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '${detectedHeight.toStringAsFixed(1)} cm',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceGuide() {
    return Positioned(
      bottom: 128,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.straighten,
                  color: AppColors.mustardGold,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  'Hold phone ~30cm from object',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.warmBeige,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapturedOverlay() {
    final lang = LanguageProvider.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.oliveGreen,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.oliveGreen.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              lang.t('photoCaptured'),
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('enhancingWithAI'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    final lang = LanguageProvider.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              lang.t('processingImage'),
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lang.t('aiEnhancingPhoto'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final lang = LanguageProvider.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: AppColors.cream, size: 28),
            ),
            const Spacer(),
            Text(
              lang.t('takePhoto'),
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream),
            ),
            const Spacer(),
            VoiceMuteButton(
              backgroundColor: Colors.black.withValues(alpha: 0.4),
              color: AppColors.cream,
              onReplay: _playGuidance,
            ),
            const SizedBox(width: 4),
            if (_cameras.length > 1)
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(Icons.cameraswitch_outlined, color: AppColors.cream, size: 26),
              )
            else
              const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.only(bottom: 36, top: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _openGallery,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.charcoal.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.cream, size: 22),
                  ),
                ),
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cream, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCapturing ? AppColors.warmBeige : AppColors.terracotta,
                      ),
                      child: _isCapturing
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cream),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _showRuler = !_showRuler);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _showRuler
                          ? AppColors.mustardGold.withValues(alpha: 0.3)
                          : AppColors.charcoal.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _showRuler ? AppColors.mustardGold : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.straighten,
                      color: _showRuler ? AppColors.mustardGold : AppColors.cream,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Auto-detect Height pill toggle
            GestureDetector(
              onTap: () {
                setState(() => _showRuler = !_showRuler);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _showRuler
                      ? AppColors.mustardGold.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(
                    color: _showRuler ? AppColors.mustardGold : Colors.white30,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showRuler ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: _showRuler ? AppColors.mustardGold : Colors.white70,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showRuler ? 'Auto-detect height: ON' : 'Auto-detect height: OFF',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _showRuler ? AppColors.cream : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Precision vertical measurement ruler painter with cm graduations and active span indicator
class VerticalRulerPainter extends CustomPainter {
  final double topRatio;
  final double bottomRatio;
  final double maxCm;

  const VerticalRulerPainter({
    required this.topRatio,
    required this.bottomRatio,
    this.maxCm = 30.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Dark frosted ruler track
    final trackPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.68)
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(14),
    );
    canvas.drawRRect(rrect, trackPaint);

    // 2. Outer border
    final borderPaint = Paint()
      ..color = AppColors.mustardGold.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, borderPaint);

    // 3. Active measurement span highlight
    final topY = (topRatio * size.height).clamp(0.0, size.height);
    final bottomY = (bottomRatio * size.height).clamp(0.0, size.height);
    if (bottomY > topY) {
      final activePaint = Paint()
        ..color = AppColors.mustardGold.withValues(alpha: 0.24)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(2, topY, size.width - 2, bottomY),
          const Radius.circular(6),
        ),
        activePaint,
      );

      // Left active indicator strip
      final activeBarPaint = Paint()
        ..color = AppColors.mustardGold
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(3, topY),
        Offset(3, bottomY),
        activeBarPaint,
      );
    }

    // 4. Graduations (0 cm at bottom, 30 cm at top)
    const double paddingY = 14.0;
    final usableHeight = size.height - (paddingY * 2);

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    final majorTickPaint = Paint()
      ..color = AppColors.mustardGold
      ..strokeWidth = 1.6;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const int totalSteps = 30; // 0 to 30 cm
    for (int cm = 0; cm <= totalSteps; cm++) {
      final y = size.height - paddingY - ((cm / totalSteps) * usableHeight);
      final isMajor = (cm % 5 == 0);

      if (isMajor) {
        // Major tick
        canvas.drawLine(
          Offset(size.width - 14, y),
          Offset(size.width - 4, y),
          majorTickPaint,
        );

        // Number label
        textPainter.text = TextSpan(
          text: '$cm',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width - 17 - textPainter.width, y - (textPainter.height / 2)),
        );
      } else {
        // Minor tick
        canvas.drawLine(
          Offset(size.width - 8, y),
          Offset(size.width - 4, y),
          tickPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant VerticalRulerPainter oldDelegate) {
    return oldDelegate.topRatio != topRatio ||
        oldDelegate.bottomRatio != bottomRatio ||
        oldDelegate.maxCm != maxCm;
  }
}
