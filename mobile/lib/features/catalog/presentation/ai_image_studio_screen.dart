import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

class AIImageStudioScreen extends StatefulWidget {
  const AIImageStudioScreen({super.key, this.imagePath});

  final String? imagePath;

  @override
  State<AIImageStudioScreen> createState() => _AIImageStudioScreenState();
}

class _AIImageStudioScreenState extends State<AIImageStudioScreen>
    with SingleTickerProviderStateMixin {
  bool _showEnhanced = true;
  bool _isProcessing = true;
  bool _hasError = false;
  String? _errorMessage;
  String? _enhancedBase64;
  List<String> _completedSteps = [];
  int _currentStepIndex = 0;
  bool _hasNavigatedBack = false;
  late AnimationController _scanController;

  static const String _baseUrl = 'http://192.168.1.5:8000';

  final List<String> _processingSteps = [
    'Analyzing your photo...',
    'Cleaning the background...',
    'Improving the lighting...',
    'Cropping for e-commerce...',
    'Finalizing your image...',
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    if (widget.imagePath != null) {
      _enhanceImage();
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _enhanceImage() async {
    if (widget.imagePath == null) return;

    setState(() {
      _isProcessing = true;
      _hasError = false;
      _errorMessage = null;
      _completedSteps = [];
      _currentStepIndex = 0;
    });

    _simulateProgress();

    final stopwatch = Stopwatch()..start();

    try {
      final file = File(widget.imagePath!);
      final bytes = await file.readAsBytes();
      final uri = Uri.parse('$_baseUrl/api/ai/enhance-image');

      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final responseBody = await response.stream.bytesToString();

      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed));
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['success'] == true) {
          setState(() {
            _enhancedBase64 = data['enhanced_image'];
            _completedSteps = List<String>.from(data['processing_steps'] ?? []);
            _showEnhanced = true;
            _isProcessing = false;
          });
          return;
        }
      }
      _setError('Enhancement failed. You can continue with the original.');
    } catch (e) {
      stopwatch.stop();
      final elapsed = stopwatch.elapsedMilliseconds;
      if (elapsed < 3000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed));
      }
      _setError('Could not connect to server. You can continue with the original.');
    }
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _hasError = true;
        _errorMessage = message;
      });
    }
  }

  void _simulateProgress() async {
    for (int i = 0; i < _processingSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted && _isProcessing) {
        setState(() => _currentStepIndex = i);
      }
    }
  }

  void _useEnhancedPhoto() {
    if (_hasNavigatedBack) return;
    _hasNavigatedBack = true;
    final imagePath = _showEnhanced && _enhancedBase64 != null
        ? _enhancedBase64!
        : widget.imagePath!;
    Navigator.pop(context, {'useEnhanced': _showEnhanced, 'imagePath': imagePath});
  }

  void _keepOriginal() {
    if (_hasNavigatedBack) return;
    _hasNavigatedBack = true;
    Navigator.pop(context, {'useEnhanced': false, 'imagePath': widget.imagePath});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasNavigatedBack,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_hasNavigatedBack) {
          _hasNavigatedBack = true;
          Navigator.pop(context, null);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.cream,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () {
              if (!_hasNavigatedBack) {
                _hasNavigatedBack = true;
                Navigator.pop(context, null);
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Image Studio',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.cream,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Make your product ready for the market',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: AppDimensions.xxl),
                    if (_isProcessing) ...[
                      _buildProcessingSection(),
                    ] else if (_hasError) ...[
                      _buildErrorBanner(),
                      const SizedBox(height: AppDimensions.xxl),
                      _buildSafetyNote(),
                    ] else ...[
                      _buildSegmentedControl(),
                      const SizedBox(height: AppDimensions.xxl),
                      _buildAIImprovements(),
                      const SizedBox(height: AppDimensions.xl),
                      _buildSafetyNote(),
                    ],
                  ],
                ),
              ),
            ),
            if (!_isProcessing) _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: _isProcessing
              ? AppColors.mustardGold.withValues(alpha: 0.4)
              : _showEnhanced
                  ? AppColors.oliveGreen.withValues(alpha: 0.4)
                  : AppColors.borderLight,
          width: _isProcessing || _showEnhanced ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCurrentImage(),
            if (_isProcessing) _buildScanningOverlay(),
            if (!_isProcessing)
              Positioned(
                top: AppDimensions.md,
                left: AppDimensions.md,
                child: _buildImageBadge(
                  _showEnhanced ? 'Enhanced' : 'Original',
                  _showEnhanced ? AppColors.oliveGreen : AppColors.charcoal,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentImage() {
    if (_showEnhanced && _enhancedBase64 != null) {
      return Image.memory(
        base64Decode(_enhancedBase64!.split(',').last),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    if (widget.imagePath != null) {
      final path = widget.imagePath!;
      if (path.startsWith('data:')) {
        return Image.memory(
          base64Decode(path.split(',').last),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.warmBeige.withValues(alpha: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 36,
              color: AppColors.terracotta.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Product photo',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.charcoal.withValues(alpha: 0.3),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Transform.translate(
                offset: Offset(
                  0,
                  320 * _scanController.value,
                ),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.mustardGold.withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: AppDimensions.lg,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                    vertical: AppDimensions.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    _currentStepIndex < _processingSteps.length
                        ? _processingSteps[_currentStepIndex]
                        : 'Finishing up...',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.cream,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.cream,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildProcessingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.mustardGold),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'Improving your product photo...',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.mustardGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.lg),
        ...List.generate(_processingSteps.length, (i) {
          final isDone = _completedSteps.contains(_processingSteps[i]) ||
              i < _currentStepIndex;
          final isCurrent = i == _currentStepIndex && _isProcessing;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.sm),
            child: Row(
              children: [
                Icon(
                  isDone
                      ? Icons.check_circle
                      : isCurrent
                          ? Icons.radio_button_checked
                          : Icons.circle_outlined,
                  size: 18,
                  color: isDone
                      ? AppColors.oliveGreen
                      : isCurrent
                          ? AppColors.mustardGold
                          : AppColors.border,
                ),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    _processingSteps[i],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDone
                          ? AppColors.charcoal
                          : isCurrent
                              ? AppColors.mustardGold
                              : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (isCurrent)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.mustardGold),
                    ),
                  ),
              ],
            ),
          );
        }),
        if (_hasError) ...[
          const SizedBox(height: AppDimensions.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.mustardGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: AppColors.mustardGold),
                const SizedBox(width: AppDimensions.sm),
                Expanded(
                  child: Text(
                    _errorMessage ?? 'Something went wrong.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSegmentedControl() {
    if (_enhancedBase64 == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xs),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSegment('Original', !_showEnhanced, () {
              setState(() => _showEnhanced = false);
            }),
          ),
          Expanded(
            child: _buildSegment('Enhanced', _showEnhanced, () {
              setState(() => _showEnhanced = true);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM - 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.buttonMedium.copyWith(
              color: isSelected ? AppColors.charcoal : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIImprovements() {
    final steps = _completedSteps.isNotEmpty
        ? _completedSteps
        : ['Background cleaned', 'Lighting improved', 'E-commerce crop'];

    final icons = [
      Icons.cleaning_services_outlined,
      Icons.wb_sunny_outlined,
      Icons.crop,
    ];

    final descriptions = [
      'Clean, professional background',
      'Bright, natural lighting',
      'Optimized for online selling',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: AppColors.mustardGold),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'AI IMPROVEMENTS',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.brown,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: List.generate(steps.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.md),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.oliveGreen.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        i < icons.length ? icons[i] : Icons.check,
                        size: 16,
                        color: AppColors.oliveGreen,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i],
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            i < descriptions.length
                                ? descriptions[i]
                                : 'Processing complete',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.mustardGold),
              const SizedBox(width: AppDimensions.sm),
              Text(
                'Enhancement unavailable',
                style: AppTextStyles.titleSmall.copyWith(color: AppColors.charcoal),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            _errorMessage ?? 'Something went wrong.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'You can still continue with your original photo.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.brown),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.mustardGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: AppColors.mustardGold),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'Your original photo is always kept safe.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.brown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.lg,
        AppDimensions.xl,
        AppDimensions.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _useEnhancedPhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: AppColors.cream,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.auto_awesome, size: 20),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      'Use Enhanced Photo',
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: AppColors.cream,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            GestureDetector(
              onTap: _keepOriginal,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                child: Text(
                  'Keep Original',
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
