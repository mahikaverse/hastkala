import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Order Details', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.support_agent_outlined, size: 20)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            const SizedBox(height: AppDimensions.xxl),
            _buildTimeline(),
            const SizedBox(height: AppDimensions.xxl),
            _buildProductCard(),
            const SizedBox(height: AppDimensions.xxl),
            _buildDeliveryDetails(),
            const SizedBox(height: AppDimensions.xxl),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('#HK12568', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 4),
        Text('Placed on 12 Aug 2025', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep('Order Placed', '12 Aug, 10:30 AM', true),
      _TimelineStep('Packed', '12 Aug, 2:45 PM', true),
      _TimelineStep('Shipped', '13 Aug, 9:10 AM', true),
      _TimelineStep('Out for Delivery', '14 Aug, 8:20 AM', true),
      _TimelineStep('Delivered', '14 Aug, 11:45 AM', true),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tracking', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.lg),
        ...List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: step.completed ? AppColors.oliveGreen : AppColors.warmBeige,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      step.completed ? Icons.check : Icons.circle,
                      size: 14,
                      color: step.completed ? AppColors.cream : AppColors.textSecondary,
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 40, color: AppColors.oliveGreen),
                ],
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: AppTextStyles.titleSmall.copyWith(
                      color: step.completed ? AppColors.charcoal : AppColors.textSecondary,
                    )),
                    Text(step.time, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProductCard() {
    final product = MockProducts.all[0];
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: Image.network(
              product.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              cacheWidth: 200,
              cacheHeight: 200,
              errorBuilder: (_, __, ___) => Container(
                width: 64,
                height: 64,
                color: AppColors.warmBeige,
                child: Icon(Icons.handyman_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4)),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: AppTextStyles.titleSmall),
                const SizedBox(height: 4),
                Text('\u20B9${product.price}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta)),
                Text('Qty: 1', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Delivering to', style: AppTextStyles.titleMedium),
        const SizedBox(height: AppDimensions.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ananya Sharma', style: AppTextStyles.titleSmall),
              Text('123, Green Park', style: AppTextStyles.bodyMedium),
              Text('Mumbai, Maharashtra', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.support_agent_outlined, size: 18, color: AppColors.terracotta),
            label: Text('Contact Support', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.terracotta),
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.cream),
            label: Text('Buy Again', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: AppColors.cream,
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String title;
  final String time;
  final bool completed;
  const _TimelineStep(this.title, this.time, this.completed);
}
