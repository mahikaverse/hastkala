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
    final screenWidth = MediaQuery.of(context).size.width;
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

          // Measurement overlay (when enabled)
          if (_showRuler && _isInitialized) ...[
            _buildMeasurementFrame(screenWidth, screenHeight),
            _buildHorizontalCaliper(isTop: true, screenHeight: screenHeight, screenWidth: screenWidth),
            _buildHorizontalCaliper(isTop: false, screenHeight: screenHeight, screenWidth: screenWidth),
            _buildVerticalRulerScale(screenHeight, screenWidth),
            _buildHeightBadge(screenWidth, screenHeight, detectedHeight),
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
  static const double _frameWidthFraction = 0.82;
  static const double _rulerWidth = 50.0;

  Widget _buildVerticalRulerScale(double screenHeight, double screenWidth) {
    final frameWidth = screenWidth * _frameWidthFraction;
    final frameLeft = (screenWidth - frameWidth) / 2;
    final rulerTop = screenHeight * _rulerTopFraction;
    final rulerHeight = screenHeight * (_rulerBottomFraction - _rulerTopFraction);
    final topRatio = ((screenHeight * _topLineY) - rulerTop) / rulerHeight;
    final bottomRatio = ((screenHeight * _bottomLineY) - rulerTop) / rulerHeight;

    return Positioned(
      top: rulerTop,
      left: frameLeft + frameWidth - _rulerWidth,
      width: _rulerWidth,
      height: rulerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Glass panel background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
            ),
          ),
          // Scale Painter (graduations, numbers, active range highlight)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: CustomPaint(
                painter: VerticalRulerPainter(
                  topRatio: topRatio.clamp(0.0, 1.0),
                  bottomRatio: bottomRatio.clamp(0.0, 1.0),
                  maxCm: 30.0,
                ),
              ),
            ),
          ),
          // Top Slider Handle (Draggable directly on ruler)
          Positioned(
            top: (topRatio * rulerHeight) - 16,
            left: -22,
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
            left: -22,
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
      width: 36,
      height: 32,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_right_rounded,
            color: AppColors.mustardGold,
            size: 18,
          ),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mustardGold,
              border: Border.all(color: Colors.white, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
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

  Widget _buildHorizontalCaliper({required bool isTop, required double screenHeight, required double screenWidth}) {
    final currentY = isTop ? _topLineY : _bottomLineY;
    final frameWidth = screenWidth * _frameWidthFraction;
    final frameLeft = (screenWidth - frameWidth) / 2;

    return Positioned(
      top: (screenHeight * currentY) - 1,
      left: frameLeft,
      width: frameWidth - _rulerWidth,
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
          height: 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Measurement line inside frame
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.mustardGold.withValues(alpha: 0.85),
                        AppColors.mustardGold.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              // Compact pill label attached to the left edge
              Positioned(
                left: 0,
                top: -11,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mustardGold,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    isTop ? 'TOP' : 'BASE',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
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

  Widget _buildHeightBadge(double screenWidth, double screenHeight, double detectedHeight) {
    final frameWidth = screenWidth * _frameWidthFraction;
    final frameLeft = (screenWidth - frameWidth) / 2;
    final frameTop = screenHeight * _rulerTopFraction;

    return Positioned(
      top: frameTop - 56,
      left: frameLeft + frameWidth - _rulerWidth - 130,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.mustardGold.withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.straighten, color: AppColors.mustardGold, size: 16),
              const SizedBox(width: 8),
              Text(
                detectedHeight.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'cm',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementFrame(double screenWidth, double screenHeight) {
    final frameWidth = screenWidth * _frameWidthFraction;
    final frameLeft = (screenWidth - frameWidth) / 2;
    final frameTop = screenHeight * _rulerTopFraction;
    final frameBottom = screenHeight * _rulerBottomFraction;
    final frameHeight = frameBottom - frameTop;

    return Positioned(
      left: frameLeft,
      top: frameTop,
      width: frameWidth,
      height: frameHeight,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
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
    // 1. Active measurement span highlight
    final topY = (topRatio * size.height).clamp(0.0, size.height);
    final bottomY = (bottomRatio * size.height).clamp(0.0, size.height);
    if (bottomY > topY) {
      final activePaint = Paint()
        ..color = AppColors.mustardGold.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(2, topY, size.width - 2, bottomY),
          const Radius.circular(4),
        ),
        activePaint,
      );

      // Left active indicator strip
      final activeBarPaint = Paint()
        ..color = AppColors.mustardGold
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(3, topY),
        Offset(3, bottomY),
        activeBarPaint,
      );
    }

    // 2. Graduations (0 cm at bottom, 30 cm at top)
    const double paddingY = 12.0;
    final usableHeight = size.height - (paddingY * 2);

    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    final majorTickPaint = Paint()
      ..color = AppColors.mustardGold
      ..strokeWidth = 1.5;

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
          Offset(size.width - 12, y),
          Offset(size.width - 2, y),
          majorTickPaint,
        );

        // Number label
        textPainter.text = TextSpan(
          text: '$cm',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(size.width - 15 - textPainter.width, y - (textPainter.height / 2)),
        );
      } else {
        // Minor tick
        canvas.drawLine(
          Offset(size.width - 6, y),
          Offset(size.width - 2, y),
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
