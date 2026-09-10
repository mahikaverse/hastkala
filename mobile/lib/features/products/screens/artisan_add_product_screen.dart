import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

class ArtisanAddProductScreen extends StatefulWidget {
  const ArtisanAddProductScreen({super.key});

  @override
  State<ArtisanAddProductScreen> createState() => _ArtisanAddProductScreenState();
}

class _ArtisanAddProductScreenState extends State<ArtisanAddProductScreen> {
  XFile? _selectedImage;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _hasTranscript = false;
  bool _showManualInput = false;
  final TextEditingController _manualController = TextEditingController();
  String _selectedLanguage = 'Hindi';

  bool get _hasInput => _selectedImage != null || _hasTranscript || _manualController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCamera());
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _manualController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _selectedImage == null
                  ? _buildWaitingForPhoto()
                  : _buildContentAfterPhoto(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Text(
              'Add Your Craft',
              style: AppTextStyles.titleLarge.copyWith(color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForPhoto() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            'Opening camera...',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.xxl),
          GestureDetector(
            onTap: _openCamera,
            child: Text(
              'Tap to open camera again',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentAfterPhoto() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(),
          const SizedBox(height: AppDimensions.xxl),
          _buildPhotoPreview(),
          const SizedBox(height: AppDimensions.xxl),
          _buildVoiceSection(),
          if (_showManualInput) ...[
            const SizedBox(height: AppDimensions.xxl),
            _buildManualInput(),
          ],
          const SizedBox(height: AppDimensions.xxl),
          _buildAIPreview(),
          const SizedBox(height: AppDimensions.xxl),
          _buildCTA(),
          const SizedBox(height: AppDimensions.md),
          _buildSaveDraft(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final hasDescription = _hasTranscript || _manualController.text.isNotEmpty;
    final steps = [
      _StepData('1', 'Photo', true),
      _StepData('2', 'Describe', hasDescription),
      _StepData('3', 'AI Listing', false),
      _StepData('4', 'Publish', false),
    ];
    final currentStep = hasDescription ? 2 : 1;

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: steps[(index ~/ 2) + 1].done ? AppColors.terracotta : AppColors.warmBeige,
            ),
          );
        }
        final stepIndex = index ~/ 2;
        final step = steps[stepIndex];
        final isCurrent = stepIndex == currentStep;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: step.done
                    ? AppColors.terracotta
                    : isCurrent
                        ? AppColors.terracotta.withValues(alpha: 0.1)
                        : AppColors.warmBeige,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: step.done
                    ? const Icon(Icons.check, size: 14, color: AppColors.cream)
                    : Text(
                        step.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isCurrent ? AppColors.terracotta : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(step.title, style: AppTextStyles.labelSmall.copyWith(fontSize: 9, color: AppColors.textSecondary)),
          ],
        );
      }),
    );
  }

  Widget _buildPhotoPreview() {
    final imagePath = _selectedImage!.path;
    final isBase64 = imagePath.startsWith('data:');

    Widget imageWidget;
    if (isBase64) {
      final base64Str = imagePath.split(',').last;
      imageWidget = Image.memory(
        base64Decode(base64Str),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    } else {
      imageWidget = Image.file(
        File(imagePath),
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageError(),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.oliveGreen.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.brown.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
            child: imageWidget,
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: AppColors.oliveGreen),
                const SizedBox(width: 6),
                Text('Photo ready', style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen)),
                const Spacer(),
                _photoAction('Retake', Icons.refresh, _openCamera),
                const SizedBox(width: AppDimensions.md),
                _photoAction('Remove', Icons.close, () => setState(() => _selectedImage = null)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageError() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppColors.warmBeige,
      child: Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary),
    );
  }

  Widget _photoAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Tell Us About It', Icons.mic_outlined),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              if (!_isRecording && !_hasTranscript) ...[
                GestureDetector(
                  onTap: _startRecording,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.mustardGold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Icon(Icons.mic_outlined, color: AppColors.mustardGold, size: 36),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                Text('Tap to speak', style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal)),
                const SizedBox(height: 4),
                Text('Tell us what you made...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppDimensions.md),
                _buildLanguageSelector(),
                const SizedBox(height: AppDimensions.md),
                GestureDetector(
                  onTap: () => setState(() => _showManualInput = !_showManualInput),
                  child: Text('Prefer typing? Add details manually', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                ),
              ] else if (_isRecording) ...[
                _buildRecordingState(),
              ] else if (_hasTranscript) ...[
                _buildTranscriptPreview(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Language: ', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        GestureDetector(
          onTap: _showLanguageSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
            decoration: BoxDecoration(color: AppColors.warmBeige, borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_selectedLanguage, style: AppTextStyles.labelMedium),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.charcoal),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    return Column(
      children: [
        GestureDetector(
          onTap: _stopRecording,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.terracotta, width: 2),
            ),
            child: Icon(Icons.mic, color: AppColors.terracotta, size: 36),
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        Text('Listening...', style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta)),
        const SizedBox(height: 4),
        Text('00:${_recordingSeconds.toString().padLeft(2, '0')}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.charcoal)),
        const SizedBox(height: AppDimensions.md),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.sm),
            decoration: BoxDecoration(color: AppColors.terracotta, borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
            child: Text('Tap to stop', style: AppTextStyles.labelMedium.copyWith(color: AppColors.cream)),
          ),
        ),
      ],
    );
  }

  Widget _buildTranscriptPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: AppColors.oliveGreen),
            const SizedBox(width: 6),
            Text('Your description', style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen)),
          ],
        ),
        const SizedBox(height: AppDimensions.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(color: AppColors.cream, borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
          child: Text(
            'Ye mitti se bana hua haath se paint kiya hua decorative pot hai. Isme traditional Indian motifs hain.',
            style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: AppColors.brown, height: 1.5),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Row(
          children: [
            Text('Language: $_selectedLanguage', style: AppTextStyles.bodySmall),
            const Spacer(),
            _transcriptAction('Edit', Icons.edit_outlined, () {}),
            const SizedBox(width: AppDimensions.md),
            _transcriptAction('Record Again', Icons.refresh, () {
              setState(() {
                _hasTranscript = false;
                _isRecording = false;
                _recordingSeconds = 0;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _transcriptAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.terracotta),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta)),
        ],
      ),
    );
  }

  Widget _buildManualInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeading('Or Type Your Description', Icons.edit_outlined),
        const SizedBox(height: AppDimensions.md),
        TextField(
          controller: _manualController,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Tell us about your craft...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.all(AppDimensions.lg),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), borderSide: const BorderSide(color: AppColors.borderLight)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), borderSide: const BorderSide(color: AppColors.borderLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD), borderSide: const BorderSide(color: AppColors.terracotta)),
          ),
        ),
      ],
    );
  }

  Widget _buildAIPreview() {
    final items = ['Understand your product', 'Create a product description', 'Suggest product details', 'Translate your listing', 'Suggest a price', 'Find suitable markets'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(color: AppColors.warmBeige.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: AppColors.mustardGold),
              const SizedBox(width: AppDimensions.sm),
              Text('WHAT HASTKALA AI WILL DO', style: AppTextStyles.labelSmall.copyWith(color: AppColors.brown, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.xs),
            child: Row(
              children: [
                Icon(Icons.check, size: 14, color: AppColors.oliveGreen),
                const SizedBox(width: AppDimensions.sm),
                Text(item, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildCTA() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _hasInput ? _createListing : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          disabledBackgroundColor: AppColors.warmBeige,
          foregroundColor: AppColors.cream,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 20, color: _hasInput ? AppColors.cream : AppColors.textSecondary),
            const SizedBox(width: AppDimensions.sm),
            Text('Create My Listing', style: AppTextStyles.buttonLarge.copyWith(color: _hasInput ? AppColors.cream : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveDraft() {
    return Center(
      child: TextButton(
        onPressed: _saveDraft,
        child: Text('Save as Draft', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
      ),
    );
  }

  Widget _sectionHeading(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.terracotta),
        const SizedBox(width: AppDimensions.sm),
        Text(title, style: AppTextStyles.titleMedium),
      ],
    );
  }

  // ─── ACTIONS ───────────────────────────────────────────────────────────────

  void _openCamera() async {
    final result = await Navigator.pushNamed(context, AppRoutes.customCamera);
    if (result != null && result is String) {
      _navigateToImageStudio(result);
    }
  }

  void _navigateToImageStudio(String imagePath) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.aiImageStudio,
      arguments: imagePath,
    );
    if (result != null && result is Map<String, dynamic>) {
      final String? returnedPath = result['imagePath'] as String?;
      if (returnedPath != null) {
        setState(() => _selectedImage = XFile(returnedPath));
      }
    }
  }

  void _showLanguageSheet() {
    final languages = ['Hindi', 'English', 'Marathi', 'Bengali', 'Tamil', 'Telugu', 'Gujarati', 'Kannada', 'Punjabi'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.md),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: AppDimensions.lg),
              Text('Select Language', style: AppTextStyles.titleMedium),
              const SizedBox(height: AppDimensions.md),
              ...languages.map((lang) {
                final isSelected = _selectedLanguage == lang;
                return ListTile(
                  title: Text(lang, style: AppTextStyles.bodyMedium.copyWith(color: isSelected ? AppColors.terracotta : AppColors.charcoal)),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.terracotta) : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
                    Navigator.pop(ctx);
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
                );
              }),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        );
      },
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _recordingSeconds++);
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _hasTranscript = true;
    });
  }

  void _createListing() {
    Navigator.pushNamed(context, AppRoutes.aiProductStudio);
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Draft saved'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
        backgroundColor: AppColors.charcoal,
      ),
    );
  }
}

class _StepData {
  final String label;
  final String title;
  final bool done;
  const _StepData(this.label, this.title, this.done);
}
