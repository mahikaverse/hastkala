import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class ArtisanHomeScreen extends StatelessWidget {
  const ArtisanHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildQuickStats(),
            _buildPrimaryAction(context),
            _buildAIAssistant(context),
            _buildMarketOpportunity(context),
            _buildRecentOrders(context),
              _buildPerformance(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.lg, AppDimensions.lg, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Namaste, Sita Devi \u{1F44B}', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 2),
                Text("Let's grow your craft business!", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined, color: AppColors.charcoal)),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.artisanProfile),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.warmBeige,
              child: Icon(Icons.person, color: AppColors.brown),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Row(
        children: [
          _statCard('Products', '12', Icons.inventory_2_outlined),
          const SizedBox(width: AppDimensions.md),
          _statCard('Views', '356', Icons.visibility_outlined),
          const SizedBox(width: AppDimensions.md),
          _statCard('Orders', '48', Icons.shopping_bag_outlined),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.terracotta, size: AppDimensions.iconMD),
            const SizedBox(height: AppDimensions.xs),
            Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.brown)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryAction(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Icon(Icons.add, color: AppColors.cream, size: AppDimensions.iconLG),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add New Product', style: AppTextStyles.titleMedium.copyWith(color: AppColors.cream)),
                    const SizedBox(height: 2),
                    Text('Turn your craft into a professional listing', style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.8))),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: AppColors.cream.withValues(alpha: 0.7), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIAssistant(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mustardGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 20),
                ),
                const SizedBox(width: AppDimensions.sm),
                Text('AI Assistant', style: AppTextStyles.titleMedium.copyWith(color: AppColors.mustardGold)),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text('Need help with your product?', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppDimensions.md),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: [
                _aiActionChip('Describe Product', Icons.edit_outlined, context),
                _aiActionChip('Improve Listing', Icons.trending_up_outlined, context),
                _aiActionChip('Suggest Price', Icons.attach_money, context),
                _aiActionChip('Find Buyers', Icons.people_outline, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiActionChip(String label, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.aiProductStudio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.mustardGold.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.mustardGold),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.mustardGold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketOpportunity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Market Opportunities', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppDimensions.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Icon(Icons.local_fire_department_outlined, color: AppColors.terracotta, size: 20),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('High demand near you', style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta)),
                      const SizedBox(height: 2),
                      Text(
                        'Handmade terracotta d\u00E9cor is trending among urban home buyers.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.marketLinkage),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.terracotta),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                ),
                child: Text('Explore Opportunities', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: AppTextStyles.titleMedium),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.artisanOrders),
                child: Text('See All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
              ),
            ],
          ),
          _orderCard('#HK12568', MockProducts.all[0], 'Delivered'),
          const SizedBox(height: AppDimensions.sm),
          _orderCard('#HK12572', MockProducts.all[1], 'Packed'),
        ],
      ),
    );
  }

  Widget _orderCard(String id, Product product, String status) {
    final isDelivered = status == 'Delivered';
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
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                Text(product.name, style: AppTextStyles.titleSmall),
                Text('\u20B9${product.price}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.terracotta)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
            decoration: BoxDecoration(
              color: isDelivered ? AppColors.oliveGreen.withValues(alpha: 0.1) : AppColors.mustardGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(
              status,
              style: AppTextStyles.labelSmall.copyWith(color: isDelivered ? AppColors.oliveGreen : AppColors.mustardGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformance() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Craft is Getting Noticed', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              _perfStat('+24%', 'Product Views'),
              const SizedBox(width: AppDimensions.md),
              _perfStat('+12%', 'Orders'),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.warmBeige.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Product', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                Text(MockProducts.all[0].name, style: AppTextStyles.titleSmall.copyWith(color: AppColors.brown)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _perfStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.oliveGreen)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      onTap: (i) {
        final routes = [
          null,
          AppRoutes.manageProducts,
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
      selectedLabelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta),
      unselectedLabelStyle: AppTextStyles.labelSmall,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Products'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), activeIcon: Icon(Icons.add_circle), label: 'Add Product'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
