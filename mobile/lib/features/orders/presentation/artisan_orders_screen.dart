import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';

class ArtisanOrdersScreen extends StatelessWidget {
  const ArtisanOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Orders', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSummary(),
          _buildFilters(),
          Expanded(child: _buildOrderList(context)),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.lg, AppDimensions.lg, 0),
      child: Row(
        children: [
          _statCard('8', 'Pending', AppColors.mustardGold),
          const SizedBox(width: AppDimensions.md),
          _statCard('5', 'Processing', AppColors.terracotta),
          const SizedBox(width: AppDimensions.md),
          _statCard('35', 'Completed', AppColors.oliveGreen),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'New', 'Packed', 'Shipped', 'Completed'];
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
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
            child: Center(child: Text(filters[i], style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.cream : AppColors.charcoal))),
          );
        },
      ),
    );
  }

  Widget _buildOrderList(BuildContext context) {
    final orders = [
      _OrderItem('#HK12568', MockProducts.all[0], 2, 2598, 'Ananya Sharma', 'New Order'),
      _OrderItem('#HK12572', MockProducts.all[1], 4, 3596, 'Priya Patel', 'Packed'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      itemCount: orders.length,
      itemBuilder: (context, i) => _buildOrderCard(context, orders[i]),
    );
  }

  Widget _buildOrderCard(BuildContext context, _OrderItem order) {
    final isNew = order.status == 'New Order';
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: isNew ? AppColors.terracotta.withValues(alpha: 0.1) : AppColors.mustardGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(order.status, style: AppTextStyles.labelSmall.copyWith(color: isNew ? AppColors.terracotta : AppColors.mustardGold)),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  order.product.imageUrl,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  cacheWidth: 100,
                  cacheHeight: 100,
                  errorBuilder: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: AppColors.warmBeige,
                    child: Icon(Icons.shopping_bag_outlined, color: AppColors.brown, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.product.name, style: AppTextStyles.titleSmall),
                    Text('Qty: ${order.qty} \u2022 Total: \u20B9${order.total}', style: AppTextStyles.bodySmall),
                    Text('Buyer: ${order.buyer}', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showOrderDetails(context, order),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.terracotta),
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              ),
              child: Text('View Order', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, _OrderItem order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: AppDimensions.lg),
                Text('Order ${order.id}', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.md),
                _detailRow('Product', order.product.name),
                _detailRow('Quantity', '${order.qty}'),
                _detailRow('Total', '\u20B9${order.total}'),
                _detailRow('Buyer', order.buyer),
                _detailRow('Delivery', 'Mumbai, Maharashtra'),
                _detailRow('Status', order.status),
                const SizedBox(height: AppDimensions.lg),
                _buildStatusUpdate(ctx),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusUpdate(BuildContext context) {
    final statuses = ['New', 'Packed', 'Shipped', 'Delivered'];
    return Row(
      children: statuses.map((s) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.terracotta),
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
              ),
              child: Text(s, style: AppTextStyles.buttonSmall.copyWith(color: AppColors.terracotta)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return HastKalaBottomNavigation(
      currentIndex: 3,
      onTap: (i) {
        final routes = [
          AppRoutes.artisanHome,
          AppRoutes.manageProducts,
          AppRoutes.artisanAddProduct,
          null,
          AppRoutes.artisanProfile,
        ];
        if (routes[i] != null) {
          Navigator.pushNamed(context, routes[i]!);
        }
      },
      items: HastKalaNavItems.artisanLegacy(context),
    );
  }
}

class _OrderItem {
  final String id;
  final Product product;
  final int qty;
  final int total;
  final String buyer;
  final String status;
  const _OrderItem(this.id, this.product, this.qty, this.total, this.buyer, this.status);
}
