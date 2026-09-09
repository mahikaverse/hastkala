import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';

class ArtisanAddProductScreen extends StatelessWidget {
  const ArtisanAddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New Product', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
            Text('Let AI help you create your listing', style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8))),
          ],
        ),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPhotoSection(),
            const SizedBox(height: AppDimensions.xl),
            _buildVoiceSection(),
            const SizedBox(height: AppDimensions.xxl),
            _buildAIButton(context),
            const SizedBox(height: AppDimensions.md),
            _buildManualButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.terracotta.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Icon(Icons.camera_alt_outlined, color: AppColors.terracotta, size: 36),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text('Add Product Photos', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _photoButton('Take a Photo', Icons.camera_alt_outlined),
              const SizedBox(width: AppDimensions.lg),
              _photoButton('Choose from Gallery', Icons.photo_library_outlined),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Clear photos help AI understand your craft better.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _photoButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Icon(icon, color: AppColors.terracotta, size: 24),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta)),
        ],
      ),
    );
  }

  Widget _buildVoiceSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.mustardGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Icon(Icons.mic_outlined, color: AppColors.mustardGold, size: 36),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text('Describe Your Craft', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Text('Tap to Speak', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.terracotta)),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Tell us about your product in your own language.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.sm,
            alignment: WrapAlignment.center,
            children: ['Hindi', 'English', 'Marathi', 'Bengali', 'Tamil', 'Telugu'].map((lang) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.xs),
                decoration: BoxDecoration(
                  color: AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(lang, style: AppTextStyles.labelSmall),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, '/ai-product-studio'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.cream,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      ),
      child: Text('\u2728 Create with AI', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
    );
  }

  Widget _buildManualButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/smart-catalog'),
      child: Text('Enter Details Manually', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
    );
  }
}
