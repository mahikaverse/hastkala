import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class AIPricingScreen extends StatefulWidget {
  const AIPricingScreen({super.key});

  @override
  State<AIPricingScreen> createState() => _AIPricingScreenState();
}

class _AIPricingScreenState extends State<AIPricingScreen> {
  double _price = 999;

  String get _priceFeedback {
    if (_price < 850) return 'Lower demand';
    if (_price > 1100) return 'Higher margin';
    return 'Good price';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Smart Pricing', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
            Text('AI-powered price guidance for your craft', style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8))),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductContext(),
            const SizedBox(height: AppDimensions.xxl),
            _buildPriceRecommendation(),
            const SizedBox(height: AppDimensions.xxl),
            _buildWhyThisPrice(),
            const SizedBox(height: AppDimensions.xxl),
            _buildMarketDemand(),
            const SizedBox(height: AppDimensions.xxl),
            _buildPriceSlider(),
            const SizedBox(height: AppDimensions.xxl),
            _buildCTA(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContext() {
    final product = MockProducts.all[0];
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          child: Image.network(
            product.imageUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            cacheWidth: 150,
            cacheHeight: 150,
            errorBuilder: (_, __, ___) => Container(
              width: 56,
              height: 56,
              color: AppColors.warmBeige,
              child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Text(product.name, style: AppTextStyles.titleMedium),
      ],
    );
  }

  Widget _buildPriceRecommendation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text('Recommended Price', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppDimensions.sm),
          Text('\u20B9${_price.toInt()}', style: AppTextStyles.displayLarge.copyWith(color: AppColors.terracotta)),
          const SizedBox(height: AppDimensions.sm),
          Text('\u20B9899 \u2014 \u20B91,099', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppDimensions.sm),
          Text('Good balance of profit and market demand', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildWhyThisPrice() {
    final factors = [
      _FactorRow('Material Cost', '\u20B9350'),
      _FactorRow('Craft Time', '6 hours'),
      _FactorRow('Craft Complexity', 'High'),
      _FactorRow('Similar Products', '\u20B9850 \u2013 \u20B91,200'),
      _FactorRow('Market Demand', 'High'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Why HastKala recommends this', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        ...factors.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(f.label, style: AppTextStyles.bodyMedium),
              Text(f.value, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMarketDemand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Market Demand', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        _demandIndicator('Demand', 'HIGH', AppColors.oliveGreen),
        const SizedBox(height: AppDimensions.sm),
        _demandIndicator('Competition', 'MEDIUM', AppColors.mustardGold),
        const SizedBox(height: AppDimensions.sm),
        _demandIndicator('Suggested Range', '\u20B9899 \u2013 \u20B91,099', AppColors.terracotta),
      ],
    );
  }

  Widget _demandIndicator(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(value, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ),
      ],
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Adjust Price', style: AppTextStyles.titleMedium),
            Text(_priceFeedback, style: AppTextStyles.labelMedium.copyWith(
              color: _priceFeedback == 'Good price' ? AppColors.oliveGreen : AppColors.mustardGold,
            )),
          ],
        ),
        Slider(
          value: _price,
          min: 700,
          max: 1500,
          divisions: 80,
          activeColor: AppColors.terracotta,
          inactiveColor: AppColors.warmBeige,
          onChanged: (v) => setState(() => _price = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\u20B9700', style: AppTextStyles.caption),
            Text('\u20B9${_price.toInt()}', style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta)),
            Text('\u20B91,500', style: AppTextStyles.caption),
          ],
        ),
      ],
    );
  }

  Widget _buildCTA(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.cream,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
      ),
      child: Text('Use This Price', style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
    );
  }
}

class _FactorRow {
  final String label;
  final String value;
  const _FactorRow(this.label, this.value);
}
