import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Products', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
            icon: const Icon(Icons.add, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(),
          _buildSearch(),
          _buildFilters(),
          Expanded(child: _buildProductList(context)),
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
          _statCard('12', 'Products'),
          const SizedBox(width: AppDimensions.md),
          _statCard('8', 'Published'),
          const SizedBox(width: AppDimensions.md),
          _statCard('4', 'Drafts'),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label) {
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
            Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.terracotta)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your products...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
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
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'Published', 'Drafts', 'Out of Stock'];
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

  Widget _buildProductList(BuildContext context) {
    final products = [
      _ProductItem(MockProducts.all[0], 'Published'),
      _ProductItem(MockProducts.all[1], 'Draft'),
      _ProductItem(MockProducts.all[2], 'Published'),
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.lg),
      itemCount: products.length,
      itemBuilder: (context, i) => _buildProductCard(context, products[i]),
    );
  }

  Widget _buildProductCard(BuildContext context, _ProductItem item) {
    final isDraft = item.status == 'Draft';
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                child: Image.network(
                  item.product.imageUrl,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, style: AppTextStyles.titleSmall),
                    Text('\u20B9${item.product.price}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.terracotta)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: isDraft ? AppColors.mustardGold.withValues(alpha: 0.1) : AppColors.oliveGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(item.status, style: AppTextStyles.labelSmall.copyWith(color: isDraft ? AppColors.mustardGold : AppColors.oliveGreen)),
              ),
            ],
          ),
          if (!isDraft) ...[
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Text('Views: ${item.product.reviews}', style: AppTextStyles.caption),
                const SizedBox(width: AppDimensions.md),
                Text('Orders: ${item.product.stock}', style: AppTextStyles.caption),
                const Spacer(),
                _actionButton(Icons.edit_outlined, () {}),
                _actionButton(Icons.content_copy, () {}),
                _actionButton(Icons.more_vert, () => _showMoreMenu(context)),
              ],
            ),
          ],
          if (isDraft) ...[
            const SizedBox(height: AppDimensions.sm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.smartCatalog),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.terracotta),
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                ),
                child: Text('Complete Listing', style: AppTextStyles.buttonSmall.copyWith(color: AppColors.terracotta)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xs),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLG)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(leading: const Icon(Icons.edit_outlined), title: Text('Edit', style: AppTextStyles.bodyMedium), onTap: () => Navigator.pop(ctx)),
              ListTile(leading: const Icon(Icons.visibility_outlined), title: Text('View', style: AppTextStyles.bodyMedium), onTap: () => Navigator.pop(ctx)),
              ListTile(leading: const Icon(Icons.content_copy), title: Text('Duplicate', style: AppTextStyles.bodyMedium), onTap: () => Navigator.pop(ctx)),
              ListTile(
                leading: Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Delete', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Product', style: AppTextStyles.titleMedium),
        content: Text('Are you sure you want to delete this product?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Delete', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      onTap: (i) {
        final routes = [
          AppRoutes.artisanHome,
          null,
          AppRoutes.artisanAddProduct,
          AppRoutes.artisanOrders,
          AppRoutes.artisanProfile,
        ];
        if (routes[i] != null) {
          Navigator.pushNamed(context, routes[i]!);
        }
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.terracotta,
      unselectedItemColor: AppColors.textSecondary,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Products'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Add Product'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}

class _ProductItem {
  final Product product;
  final String status;
  const _ProductItem(this.product, this.status);
}
