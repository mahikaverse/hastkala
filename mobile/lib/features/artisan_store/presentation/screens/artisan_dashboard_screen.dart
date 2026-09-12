import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';
import 'my_products_screen.dart';
import 'schemes_events_screen.dart';
import 'analytics_placeholder_screen.dart';
import 'artisan_profile_new_screen.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  final DataService _data = DataService();
  int _currentNavIndex = 0;

  ArtisanStore? get _store =>
      _data.stores.isNotEmpty ? _data.stores.first : null;

  ArtisanProfile? get _profile =>
      _data.artisanProfiles.isNotEmpty ? _data.artisanProfiles.first : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentNavIndex == 0
          ? _buildHomeTab()
          : _currentNavIndex == 1
              ? const SchemesEventsScreen()
              : _currentNavIndex == 3
                  ? const AnalyticsPlaceholderScreen()
                  : const ArtisanProfileNewScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HOME TAB ──────────────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    final store = _store;
    final profile = _profile;
    if (store == null) return const Center(child: Text('No store found'));
    final stats = _data.getStoreStats(store.id);
    final products = _data.getProductsByStore(store.id);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildHeader(store, profile),
        _buildStatsRow(stats),
        _buildMyProductsSection(products),
        _buildQuickActions(),
      ],
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(ArtisanStore store, ArtisanProfile? profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: Opacity(
                opacity: 0.12,
                child: Image.asset(
                  'assets/app-logo.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Image.asset(
                          'assets/horizontal-logo.png',
                          height: 36,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Text(
                            'HastKala',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.brown,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 22),
                        onPressed: () {},
                        color: AppColors.brown,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.terracotta.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, size: 18, color: AppColors.terracotta),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('Welcome back,', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          store.name.isNotEmpty ? store.name : 'Artisan',
                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.brown, fontSize: 22),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (store.isVerified) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.oliveGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: AppColors.oliveGreen),
                              const SizedBox(width: 2),
                              Text('Verified', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.oliveGreen)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Keep creating. The world values your craft.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATISTICS ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final items = [
      _StatItem(Icons.inventory_2_outlined, AppColors.terracotta, '${stats['totalProducts'] ?? 0}', 'Products'),
      _StatItem(Icons.shopping_bag_outlined, AppColors.oliveGreen, '${stats['totalOrders'] ?? 0}', 'Orders'),
      _StatItem(Icons.currency_rupee_rounded, AppColors.mustardGold, '₹${(stats['totalRevenue'] ?? 0).toInt()}', 'Revenue'),
      _StatItem(Icons.visibility_outlined, Colors.blue.shade600, '${stats['totalViews'] ?? 0}', 'Visits'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Row(
        children: items.map((item) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildStatCard(item),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 16, color: item.color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(item.value, style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 14,
            )),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(item.label, style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary, fontSize: 10,
            ), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  // ─── MY PRODUCTS SECTION ───────────────────────────────────────────────────

  Widget _buildMyProductsSection(List<MarketplaceProduct> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          child: Row(
            children: [
              Text('My Products', style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 16,
              )),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All', style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.terracotta, fontWeight: FontWeight.w600, fontSize: 13,
                    )),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.terracotta),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (products.isEmpty)
          _buildEmptyProducts()
        else
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => _buildProductHorizontalCard(products[i]),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            Text('No products yet', style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13,
            )),
            const SizedBox(height: 4),
            Text(
              'Add your first product to get started',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/voice-add-product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHorizontalCard(MarketplaceProduct product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/seller-product-detail',
        arguments: {'productId': product.id},
      ),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
                    child: SizedBox(
                      width: double.infinity,
                      child: AdaptiveProductImage(
                        imageUrl: product.imageUrls.isNotEmpty ? product.imageUrls.first : '',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.more_vert_rounded, size: 12, color: AppColors.charcoal),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${product.effectivePrice.toInt()}',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: product.stockQuantity > 0 ? AppColors.oliveGreen : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            product.stockQuantity > 0 ? 'In Stock (${product.stockQuantity})' : 'Out',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: product.stockQuantity > 0 ? AppColors.oliveGreen : AppColors.error,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── QUICK ACTIONS ─────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    final actions = [
      _ActionItem(Icons.camera_alt_rounded, AppColors.terracotta, 'Add Product', 'Camera / Voice', () {
        Navigator.pushNamed(context, '/voice-add-product');
      }),
      _ActionItem(Icons.store_outlined, AppColors.oliveGreen, 'My Store', 'Manage store', () {
        Navigator.pushNamed(context, '/artisan-store', arguments: _store?.slug ?? 'store');
      }),
      _ActionItem(Icons.analytics_outlined, AppColors.mustardGold, 'Analytics', 'Performance', () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalyticsPlaceholderScreen()),
        );
      }),
      _ActionItem(Icons.menu_book_outlined, Colors.blue.shade600, 'Help', 'Learn & grow', () {}),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold, color: AppColors.charcoal,
          )),
          const SizedBox(height: 4),
          Text('Turn your craft into opportunity', style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary, fontSize: 11,
          )),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildActionCard(a),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(_ActionItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 18, color: item.color),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(item.title, style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 12,
              ), textAlign: TextAlign.center, maxLines: 1),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(item.subtitle, style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary, fontSize: 9,
              ), textAlign: TextAlign.center, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4, top: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.festival_outlined, Icons.festival_rounded, 'Schemes'),
              _buildCenterButton(),
              _buildNavItem(3, Icons.analytics_outlined, Icons.analytics_rounded, 'Analytics'),
              _buildNavItem(4, Icons.person_outlined, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: isSelected
                  ? BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppColors.terracotta : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.terracotta : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/voice-add-product'),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.terracotta, AppColors.brown],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.terracotta.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              'Add',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.terracotta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _StatItem(this.icon, this.color, this.value, this.label);
}

class _ActionItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionItem(this.icon, this.color, this.title, this.subtitle, this.onTap);
}
