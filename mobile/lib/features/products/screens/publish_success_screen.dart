import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../models/product_draft.dart';

class PublishSuccessScreen extends StatelessWidget {
  final ProductDraft draft;

  const PublishSuccessScreen({super.key, required this.draft});

  Widget _buildProductImage() {
    if (draft.isBase64Image && draft.imagePath != null) {
      final base64Str = draft.imagePath!.contains(',')
          ? draft.imagePath!.split(',').last
          : draft.imagePath!;
      return Image.memory(
        base64Decode(base64Str),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else if (draft.imagePath != null) {
      return Image.file(
        File(draft.imagePath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.warmBeige,
      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.oliveGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 44),
                ),
                const SizedBox(height: AppDimensions.xl),
                Text(
                  lang.t('productPublished'),
                  style: AppTextStyles.headlineLarge.copyWith(color: AppColors.charcoal),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.md),
                Text(
                  lang.t('productNowReady'),
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.xxxl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: _buildProductImage(),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              draft.productName ?? lang.t('productFallback'),
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '₹${draft.price ?? '---'}',
                              style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta),
                            ),
                            Text(
                              draft.craft ?? '',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracotta,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      lang.t('viewProduct'),
                      style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.charcoal,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Text(
                      lang.t('shareProduct'),
                      style: AppTextStyles.buttonLarge.copyWith(color: AppColors.charcoal),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    lang.t('goToMyProducts'),
                    style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
