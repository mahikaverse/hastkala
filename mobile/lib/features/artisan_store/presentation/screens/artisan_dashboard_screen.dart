import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';

const _pad = EdgeInsets.symmetric(horizontal: AppDimensions.lg);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.xxl,
                vertical: 12,
              ),
              child: Center(
                child: Image.asset(
                  'assets/horizontal-logo.png',
                  height: 44,
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
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _currentNavIndex == 0
                ? _buildOverviewTab()
                : _currentNavIndex == 1
                    ? _buildMyStoreTab()
                    : _currentNavIndex == 2
                        ? _buildProductsTab()
                        : _currentNavIndex == 3
                            ? _buildOrdersTab()
                            : _buildProfileTab(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── OVERVIEW ──────────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    final store = _store;
    if (store == null) return const Center(child: Text('No store found'));
    final stats = _data.getStoreStats(store.id);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const SizedBox(height: 10),
        // Greeting
        Padding(
          padding: _pad,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Welcome back,',
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(store.name,
                        style: AppTextStyles.headlineLarge
                            .copyWith(color: AppColors.brown)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: store.isVerified
                      ? AppColors.oliveGreen.withValues(alpha: 0.1)
                      : AppColors.warmBeige,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      store.isVerified
                          ? Icons.verified
                          : Icons.pending_outlined,
                      size: 14,
                      color: store.isVerified
                          ? AppColors.oliveGreen
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      store.isVerified ? 'Verified' : 'Pending',
                      style: AppTextStyles.labelSmall.copyWith(
                          color: store.isVerified
                              ? AppColors.oliveGreen
                              : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Stats
        Padding(
          padding: _pad,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard('Total Sales', '${stats['totalSales']}',
                  Icons.shopping_bag_outlined, AppColors.terracotta),
              _buildStatCard(
                  'Revenue',
                  '₹${(stats['totalRevenue'] as double).toStringAsFixed(0)}',
                  Icons.account_balance_wallet_outlined,
                  AppColors.oliveGreen),
              _buildStatCard('Orders', '${stats['totalOrders']}',
                  Icons.receipt_long_outlined, AppColors.mustardGold),
              _buildStatCard('Pending', '${stats['pendingOrders']}',
                  Icons.pending_actions_outlined, AppColors.brown),
              _buildStatCard('Products', '${stats['publishedProducts']}',
                  Icons.inventory_2_outlined, AppColors.terracotta),
              _buildStatCard('Store Visits', '${stats['totalViews']}',
                  Icons.visibility_outlined, AppColors.oliveGreen),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Quick Actions
        Padding(
          padding: _pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Actions',
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.brown)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard('Add Product',
                        Icons.add_box_outlined, AppColors.terracotta,
                        () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard(
                        'My Store', Icons.store_outlined, AppColors.oliveGreen,
                        () => setState(() => _currentNavIndex = 1)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionCard('Analytics',
                        Icons.analytics_outlined, AppColors.mustardGold,
                        () {}),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Recent Orders
        if (_buildRecentOrdersList().isNotEmpty) ...[
          Padding(
            padding: _pad,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Orders',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.brown)),
                TextButton(
                  onPressed: () =>
                      setState(() => _currentNavIndex = 3),
                  child: Text('View All',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.terracotta)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ..._buildRecentOrdersList(),
        ],
      ],
    );
  }

  List<Widget> _buildRecentOrdersList() {
    final store = _store;
    if (store == null) return [];
    final orders = _data.getOrdersByStore(store.id).take(5).toList();
    if (orders.isEmpty) return [];
    return orders
        .map((order) => Padding(
              padding: _pad.add(const EdgeInsets.only(bottom: 8)),
              child: _buildOrderTile(order),
            ))
        .toList();
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value,
                style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.brown, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.charcoal)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTile(MarketplaceOrder order) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warmBeige.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: const Icon(Icons.receipt_long,
                size: 16, color: AppColors.brown),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.orderNumber,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.charcoal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  '${order.items.length} item${order.items.length > 1 ? 's' : ''} • ₹${order.total.toStringAsFixed(0)}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _buildStatusBadge(order.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    String text;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.mustardGold;
        text = 'Pending';
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        text = 'Confirmed';
        break;
      case OrderStatus.processing:
        color = AppColors.terracotta;
        text = 'Processing';
        break;
      case OrderStatus.shipped:
        color = AppColors.oliveGreen;
        text = 'Shipped';
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        text = 'Delivered';
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        text = 'Cancelled';
        break;
      case OrderStatus.returned:
        color = AppColors.textSecondary;
        text = 'Returned';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child:
          Text(text, style: AppTextStyles.labelSmall.copyWith(color: color)),
    );
  }

  // ─── MY STORE ──────────────────────────────────────────────────────────────

  Widget _buildMyStoreTab() {
    final store = _store;
    if (store == null) return const Center(child: Text('No store'));

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: _pad,
          child: Text('My Store',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.brown)),
        ),
        const SizedBox(height: 16),
        // Banner
        Padding(
          padding: _pad,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              gradient: const LinearGradient(
                  colors: [AppColors.brown, AppColors.brownLight]),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store,
                      size: 40,
                      color: AppColors.cream.withValues(alpha: 0.7)),
                  const SizedBox(height: 8),
                  Text(store.name,
                      style: AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.cream)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Info cards
        Padding(
          padding: _pad,
          child: Column(
            children: [
              _buildInfoCard('Store Name', store.name, Icons.store_outlined),
              _buildInfoCard(
                  'Category', store.craftCategory, Icons.category_outlined),
              _buildInfoCard('Location', '${store.location}, ${store.state}',
                  Icons.location_on_outlined),
              _buildInfoCard(
                  'Slug', '/artisan/${store.slug}', Icons.link),
              _buildInfoCard(
                  'Rating',
                  '${store.averageRating.toStringAsFixed(1)} (${store.totalReviews} reviews)',
                  Icons.star_outline),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Buttons
        Padding(
          padding: _pad,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text('Edit Store'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: AppColors.cream,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                      context, '/artisan-store',
                      arguments: store.slug),
                  icon: const Icon(Icons.visibility_outlined, size: 20),
                  label: const Text('Preview Store'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.terracotta),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.terracotta),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.charcoal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PRODUCTS ──────────────────────────────────────────────────────────────

  Widget _buildProductsTab() {
    final store = _store;
    if (store == null) return const Center(child: Text('No store'));
    final products = _data.getProductsByStore(store.id);

    return Column(
      children: [
        Padding(
          padding: _pad.add(const EdgeInsets.only(top: 16)),
          child: Row(
            children: [
              Text('Products',
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.brown)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: AppColors.cream,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (products.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 56, color: AppColors.warmBeige),
                  const SizedBox(height: 12),
                  Text('No products yet',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding:
                  _pad.add(const EdgeInsets.only(bottom: 100)),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) =>
                  _buildProductTile(products[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildProductTile(MarketplaceProduct product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              color: AppColors.warmBeige.withValues(alpha: 0.5),
            ),
            child: product.imageUrls.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                    child: Image.asset(product.imageUrls.first,
                        fit: BoxFit.cover),
                  )
                : const Icon(Icons.image, color: AppColors.brown),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.charcoal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('₹${product.effectivePrice.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.terracotta,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isPublished
                            ? AppColors.oliveGreen.withValues(alpha: 0.1)
                            : AppColors.warmBeige,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusXS),
                      ),
                      child: Text(
                          product.isPublished ? 'Published' : 'Draft',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: product.isPublished
                                  ? AppColors.oliveGreen
                                  : AppColors.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    Text('${product.totalSales} sold',
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert,
                size: 20, color: AppColors.textSecondary),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                  value: 'duplicate', child: Text('Duplicate')),
              PopupMenuItem(
                  value: 'toggle',
                  child: Text(
                      product.isPublished ? 'Unpublish' : 'Publish')),
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete',
                      style: TextStyle(color: AppColors.error))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── ORDERS ────────────────────────────────────────────────────────────────

  Widget _buildOrdersTab() {
    final store = _store;
    if (store == null) return const Center(child: Text('No store'));
    final orders = _data.getOrdersByStore(store.id);

    return Column(
      children: [
        Padding(
          padding: _pad.add(const EdgeInsets.only(top: 16)),
          child: Text('Orders',
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.brown)),
        ),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 56, color: AppColors.warmBeige),
                  const SizedBox(height: 12),
                  Text('No orders yet',
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              padding:
                  _pad.add(const EdgeInsets.only(bottom: 100)),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) =>
                  _buildOrderCard(orders[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderCard(MarketplaceOrder order) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderNumber,
                  style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600)),
              _buildStatusBadge(order.status),
            ],
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(item.productName,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)),
                    Flexible(
                      child: Text('x${item.quantity}',
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text('₹${item.totalPrice.toStringAsFixed(0)}',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: AppColors.brown)),
                  ],
                ),
              )),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total: ₹${order.total.toStringAsFixed(0)}',
                  style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600)),
              Text(order.isPaid ? 'Paid' : 'Unpaid',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: order.isPaid
                          ? AppColors.oliveGreen
                          : AppColors.error)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── PROFILE ───────────────────────────────────────────────────────────────

  Widget _buildProfileTab() {
    final store = _store;
    final profile =
        store != null ? _data.getArtisanProfile(store.artisanId) : null;
    if (profile == null) return const Center(child: Text('No profile'));

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        const SizedBox(height: 24),
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.warmBeige,
          child: Text(profile.name[0],
              style: AppTextStyles.displaySmall
                  .copyWith(color: AppColors.brown)),
        ),
        const SizedBox(height: 12),
        Text(profile.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineLarge
                .copyWith(color: AppColors.brown)),
        const SizedBox(height: 4),
        Text(profile.craftSpecialization,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        Padding(
          padding: _pad,
          child: Column(
            children: [
              _buildProfileOption(Icons.store_outlined, 'My Store',
                  () => setState(() => _currentNavIndex = 1)),
              _buildProfileOption(Icons.inventory_2_outlined, 'Products',
                  () => setState(() => _currentNavIndex = 2)),
              _buildProfileOption(Icons.receipt_long_outlined, 'Orders',
                  () => setState(() => _currentNavIndex = 3)),
              _buildProfileOption(
                  Icons.analytics_outlined, 'Analytics', () {}),
              _buildProfileOption(
                  Icons.settings_outlined, 'Store Settings', () {}),
              _buildProfileOption(
                  Icons.help_outline, 'Help & Support', () {}),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption(
      IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brown),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: AppColors.textSecondary),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: (i) => setState(() => _currentNavIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 60,
        indicatorColor: AppColors.terracotta.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, size: 22),
              selectedIcon: Icon(Icons.dashboard, size: 22),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.store_outlined, size: 22),
              selectedIcon: Icon(Icons.store, size: 22),
              label: 'Store'),
          NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined, size: 22),
              selectedIcon: Icon(Icons.inventory_2, size: 22),
              label: 'Products'),
          NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, size: 22),
              selectedIcon: Icon(Icons.receipt_long, size: 22),
              label: 'Orders'),
          NavigationDestination(
              icon: Icon(Icons.person_outlined, size: 22),
              selectedIcon: Icon(Icons.person, size: 22),
              label: 'Profile'),
        ],
      ),
    );
  }
}
