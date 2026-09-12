import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

class AnalyticsPlaceholderScreen extends StatelessWidget {
  const AnalyticsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        title: Text('Analytics', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_outlined, size: 48, color: AppColors.terracotta),
              ),
              const SizedBox(height: AppDimensions.xl),
              Text(
                'Your analytics will appear here.',
                style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Once your store gets activity, you\'ll see product views, orders and sales insights.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xxl),
              _buildComingSoonCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    final items = [
      _MetricPreview(icon: Icons.visibility_outlined, label: 'Product Views', value: '—'),
      _MetricPreview(icon: Icons.shopping_bag_outlined, label: 'Orders', value: '—'),
      _MetricPreview(icon: Icons.currency_rupee_outlined, label: 'Revenue', value: '—'),
      _MetricPreview(icon: Icons.trending_up_rounded, label: 'Growth', value: '—'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Coming Soon', style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.brown,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: AppDimensions.md),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 20, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                const SizedBox(width: 12),
                Expanded(child: Text(item.label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))),
                Text(item.value, style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                )),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _MetricPreview {
  final IconData icon;
  final String label;
  final String value;
  const _MetricPreview({required this.icon, required this.label, required this.value});
}
