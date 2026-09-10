import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class MarketLinkageScreen extends StatelessWidget {
  const MarketLinkageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find Better Markets', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
            Text('HastKala AI found these opportunities for your craft.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8))),
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
            _buildMarketFilters(),
            const SizedBox(height: AppDimensions.xxl),
            _buildBestMatch(),
            const SizedBox(height: AppDimensions.xxl),
            _buildOtherOpportunities(),
            const SizedBox(height: AppDimensions.xxl),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductContext() {
    final product = MockProducts.all[0];
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: Image.network(
              product.imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              cacheWidth: 150,
              cacheHeight: 150,
              errorBuilder: (_, __, ___) => Container(
                width: 48,
                height: 48,
                color: AppColors.warmBeige,
                child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.titleSmall),
                Text('Home Decor \u2022 High Demand', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketFilters() {
    final chips = ['Local', 'B2C', 'B2B', 'Government', 'Corporate'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (context, i) {
          final isSelected = i == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.terracotta : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: isSelected ? AppColors.terracotta : AppColors.border),
            ),
            child: Center(child: Text(chips[i], style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.cream : AppColors.charcoal))),
          );
        },
      ),
    );
  }

  Widget _buildBestMatch() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('\uD83C\uDFAF Best Match', style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text('94%', style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text('Urban Home Decor Buyers', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppDimensions.sm),
          _matchReason('High demand'),
          _matchReason('Medium competition'),
          _matchReason('Good price fit'),
          _matchReason('Strong handmade preference'),
          const SizedBox(height: AppDimensions.md),
          _opportunityDetails(),
        ],
      ),
    );
  }

  Widget _matchReason(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.oliveGreen),
          const SizedBox(width: 6),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _opportunityDetails() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
      ),
      child: Column(
        children: [
          _detailRow('Estimated demand', 'High'),
          _detailRow('Potential order', '50\u2013100 units'),
          _detailRow('Suggested price', '\u20B9899\u2013\u20B91,099'),
          _detailRow('Competition', 'Medium'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }

  Widget _buildOtherOpportunities() {
    final opportunities = [
      _Opportunity('Government / Institutional Buyers', '89%', 'Handmade & cultural products'),
      _Opportunity('Corporate Gifting', '84%', 'Festive gifting demand'),
      _Opportunity('B2B Home Decor Stores', '81%', 'Bulk order potential'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Other Opportunities', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.md),
        ...opportunities.map((o) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.name, style: AppTextStyles.titleSmall),
                    Text(o.reason, style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(o.match, style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.cream,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('View Buyer Opportunities', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream)),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
            child: Text('Add to Marketplace', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
          ),
        ),
      ],
    );
  }
}

class _Opportunity {
  final String name;
  final String match;
  final String reason;
  const _Opportunity(this.name, this.match, this.reason);
}
