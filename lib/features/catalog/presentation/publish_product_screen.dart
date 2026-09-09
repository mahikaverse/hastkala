import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class PublishProductScreen extends StatelessWidget {
  const PublishProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Your Product is Ready!', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
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
          children: [
            _buildSuccess(),
            const SizedBox(height: AppDimensions.xxl),
            _buildProductPreview(),
            const SizedBox(height: AppDimensions.xxl),
            _buildAIFeatures(),
            const SizedBox(height: AppDimensions.xxl),
            _buildMarketMatch(),
            const SizedBox(height: AppDimensions.xxl),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.oliveGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle, size: 48, color: AppColors.oliveGreen),
        ),
        const SizedBox(height: AppDimensions.lg),
        Text('Your craft is ready for the market \uD83C\uDF89', style: AppTextStyles.headlineMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppDimensions.sm),
        Text('HastKala AI helped create your listing.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildProductPreview() {
    final product = MockProducts.all[0];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: Image.network(
              product.imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              cacheWidth: 400,
              cacheHeight: 200,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 120,
                color: AppColors.warmBeige,
                child: Icon(Icons.image_outlined, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(product.name, style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text('\u20B9${product.price}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.terracotta)),
          const SizedBox(height: 4),
          Text('Home Decor \u2022 ${product.category}', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAIFeatures() {
    final features = [
      'Enhanced Image',
      'Product Description',
      'Translated Listing',
      'Smart Price',
      'Market Match',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Generated Features', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: features.map((f) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.oliveGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: AppColors.oliveGreen),
                  const SizedBox(width: 4),
                  Text(f, style: AppTextStyles.labelSmall.copyWith(color: AppColors.oliveGreen)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMarketMatch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Best Match', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text('Urban Home Decor Buyers', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('Match: ', style: AppTextStyles.bodySmall),
              Text('94%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.oliveGreen, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.artisanHome, (route) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.cream,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Publish Product', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.artisanHome, (route) => false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Save as Draft', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.charcoal)),
          ),
        ),
      ],
    );
  }
}
