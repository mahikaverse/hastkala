import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final Set<String> _tags = {'Terracotta', 'Handmade', 'IndianCraft', 'HomeDecor', 'Rajasthan'};
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Smart Catalog', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Edit', style: AppTextStyles.labelMedium.copyWith(color: AppColors.cream)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductImage(),
            const SizedBox(height: AppDimensions.xxl),
            _buildProductDetails(),
            const SizedBox(height: AppDimensions.xxl),
            _buildDescription(),
            const SizedBox(height: AppDimensions.xxl),
            _buildLanguageSection(),
            const SizedBox(height: AppDimensions.xxl),
            _buildTags(),
            const SizedBox(height: AppDimensions.xxl),
            _buildPrice(),
            const SizedBox(height: AppDimensions.xxl),
            _buildMarket(),
            const SizedBox(height: AppDimensions.xxl),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    final product = MockProducts.all[0];
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          child: Image.network(
            product.imageUrl,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            cacheWidth: 500,
            cacheHeight: 250,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 200,
              color: AppColors.warmBeige,
              child: Icon(Icons.image_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.oliveGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: AppColors.oliveGreen),
              const SizedBox(width: 4),
              Text('AI Enhanced', style: AppTextStyles.labelSmall.copyWith(color: AppColors.oliveGreen)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    final details = [
      _DetailRow('Product Name', 'Terracotta Decorative Pot'),
      _DetailRow('Category', 'Home Decor'),
      _DetailRow('Craft', 'Hand-painted Terracotta'),
      _DetailRow('Material', 'Natural Clay'),
      _DetailRow('Region', 'Rajasthan'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Details', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        ...details.map((d) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 110, child: Text(d.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary))),
              Expanded(child: Text(d.value, style: AppTextStyles.bodyMedium)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'AI-generated description...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              borderSide: const BorderSide(color: AppColors.terracotta),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Listing Language', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: ['English', 'Hindi', 'Marathi', 'Bengali'].map((lang) {
            final isSelected = _selectedLanguage == lang;
            return GestureDetector(
              onTap: () => setState(() => _selectedLanguage = lang),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.terracotta : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: isSelected ? AppColors.terracotta : AppColors.border),
                ),
                child: Text(lang, style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.cream : AppColors.charcoal)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Translate Listing', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Suggested Tags', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        Wrap(
          spacing: AppDimensions.sm,
          runSpacing: AppDimensions.sm,
          children: _tags.map((tag) {
            return Chip(
              label: Text('#$tag', style: AppTextStyles.labelSmall),
              deleteIcon: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
              onDeleted: () => setState(() => _tags.remove(tag)),
              backgroundColor: AppColors.warmBeige,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Suggested Price', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.sm),
        Text('\u20B9899 \u2013 \u20B91,099', style: AppTextStyles.displaySmall.copyWith(color: AppColors.terracotta)),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.aiPricing),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('View Price Recommendation', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ),
      ],
    );
  }

  Widget _buildMarket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Best Market Match', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.warmBeige.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Urban Home Decor Buyers', style: AppTextStyles.titleSmall.copyWith(color: AppColors.brown)),
              const SizedBox(height: 4),
              Text('Match: 94%', style: AppTextStyles.bodySmall.copyWith(color: AppColors.oliveGreen)),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.marketLinkage),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Find Buyers', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Save Product', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.charcoal)),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.publishProduct),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.cream,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Continue', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream)),
          ),
        ),
      ],
    );
  }
}

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
}
