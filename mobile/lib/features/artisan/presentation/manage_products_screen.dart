import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/adaptive_product_image.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  late List<ArtisanProduct> _products;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _products = List.from(MockArtisanProducts.all);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<ArtisanProduct> get _filteredProducts {
    List<ArtisanProduct> list = _selectedFilter == 'All'
        ? List.from(MockArtisanProducts.all)
        : MockArtisanProducts.byStatus(_selectedFilter);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
        p.product.name.toLowerCase().contains(q) ||
        p.product.category.toLowerCase().contains(q) ||
        p.product.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }
    return list;
  }

  void _deleteProduct(int id) {
    setState(() {
      _products.removeWhere((p) => p.product.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSubtitle(),
                    _buildSummary(),
                    _buildAddProductCTA(),
                    _buildSearch(),
                    _buildFilterTabs(),
                    _buildAIInsight(),
                    _isLoading ? _buildSkeletonList() : _buildProductList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          Expanded(
            child: Text('My Products', style: AppTextStyles.titleLarge.copyWith(color: AppColors.charcoal)),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search, color: AppColors.charcoal, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.lg),
      child: Text(
        'Manage your craft. Grow your market.',
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  // ─── SUMMARY ───────────────────────────────────────────────────────────────

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _summaryItem(Icons.inventory_2_outlined, '${MockArtisanProducts.totalProducts}', 'Products', AppColors.brown),
            _summaryDivider(),
            _summaryItem(Icons.check_circle_outline, '${MockArtisanProducts.publishedCount}', 'Published', AppColors.oliveGreen),
            _summaryDivider(),
            _summaryItem(Icons.edit_note, '${MockArtisanProducts.draftCount}', 'Drafts', AppColors.mustardGold),
            _summaryDivider(),
            _summaryItem(Icons.rate_review_outlined, '${MockArtisanProducts.reviewCount}', 'Review', AppColors.terracotta),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 36, color: AppColors.borderLight);
  }

  // ─── ADD PRODUCT CTA ───────────────────────────────────────────────────────

  Widget _buildAddProductCTA() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xl),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg, horizontal: AppDimensions.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.terracotta, AppColors.terracotta.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            boxShadow: [
              BoxShadow(
                color: AppColors.terracotta.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              const SizedBox(width: AppDimensions.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Product with AI',
                      style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Photo + Voice \u2192 AI Listing',
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.7), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── SEARCH ────────────────────────────────────────────────────────────────

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.md),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search your products...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.6)),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
            ? GestureDetector(
                onTap: () => setState(() => _searchQuery = ''),
                child: Icon(Icons.close, color: AppColors.textSecondary, size: 18),
              )
            : null,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

  // ─── FILTER TABS ───────────────────────────────────────────────────────────

  Widget _buildFilterTabs() {
    final filters = ['All', 'Published', 'Drafts', 'Needs Review'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.lg),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
        itemBuilder: (context, i) {
          final f = filters[i];
          final isSelected = f == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.terracotta : AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: isSelected ? AppColors.terracotta : AppColors.border),
              ),
              child: Center(
                child: Text(
                  f,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected ? AppColors.cream : AppColors.charcoal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── AI INSIGHT ────────────────────────────────────────────────────────────

  Widget _buildAIInsight() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, AppDimensions.xl),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.warmBeige.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: AppColors.mustardGold),
                const SizedBox(width: 6),
                Text(
                  'AI SUGGESTION',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.brown, letterSpacing: 0.8),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Your terracotta products are getting 24% more views than your other products.',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              'Consider adding more home-decor pieces.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.md),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.marketLinkage),
              child: Row(
                children: [
                  Text('Explore Opportunity', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.terracotta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PRODUCT LIST ──────────────────────────────────────────────────────────

  Widget _buildProductList() {
    final products = _filteredProducts;
    if (products.isEmpty) return _buildEmptyState();
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${products.length} product${products.length == 1 ? '' : 's'}',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.md),
          ...products.map((ap) => _buildProductCard(ap)),
        ],
      ),
    );
  }

  Widget _buildProductCard(ArtisanProduct ap) {
    final statusColor = ap.status == 'Published'
        ? AppColors.oliveGreen
        : ap.status == 'Draft'
            ? AppColors.mustardGold
            : AppColors.terracotta;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Info row
          Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.productDetails, arguments: ap.product),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    child: AdaptiveProductImage(
                      imageUrl: ap.product.imageUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      placeholder: Container(
                        width: 96,
                        height: 96,
                        color: AppColors.warmBeige,
                        child: Icon(Icons.image_outlined, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              ap.product.name,
                              style: AppTextStyles.titleSmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showProductMenu(ap),
                            child: Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ap.product.category,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\u20B9${ap.product.price}',
                        style: AppTextStyles.titleMedium.copyWith(color: AppColors.terracotta),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('${ap.views} views', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                          const SizedBox(width: AppDimensions.md),
                          Icon(Icons.shopping_bag_outlined, size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text('${ap.orders} orders', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(AppDimensions.md, 0, AppDimensions.md, AppDimensions.md),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                ap.status,
                style: AppTextStyles.labelSmall.copyWith(color: statusColor),
              ),
            ),
          ),
          // Draft completion indicator
          if (ap.status == 'Draft' || ap.status == 'Needs Review')
            _buildCompletionIndicator(ap),
        ],
      ),
    );
  }

  Widget _buildCompletionIndicator(ArtisanProduct ap) {
    final color = ap.status == 'Draft' ? AppColors.mustardGold : AppColors.terracotta;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 0, AppDimensions.md, AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Listing ${ap.completionPercent}% complete',
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ap.completionPercent / 100,
              backgroundColor: AppColors.warmBeige,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 4,
            ),
          ),
          if (ap.missingFields.isNotEmpty) ...[
            const SizedBox(height: 6),
            ...ap.missingFields.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 5, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Missing: $f', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )),
          ],
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.smartCatalog),
            child: Row(
              children: [
                Text('Continue Listing', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.terracotta),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── EMPTY STATE ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl, vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: AppDimensions.lg),
          Text('No products here yet', style: AppTextStyles.titleMedium.copyWith(color: AppColors.charcoal)),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Add your first craft and let HastKala AI create the listing for you.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xl),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.terracotta,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '+ Add Product with AI',
                style: AppTextStyles.buttonMedium.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SKELETON LOADING ──────────────────────────────────────────────────────

  Widget _buildSkeletonList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, 0, AppDimensions.xl, 0),
      child: Column(
        children: List.generate(3, (_) => Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.md),
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          child: Row(
            children: [
              _skeletonBox(96, 96),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(120, 14),
                    const SizedBox(height: 6),
                    _skeletonBox(80, 10),
                    const SizedBox(height: 6),
                    _skeletonBox(60, 14),
                    const SizedBox(height: 6),
                    _skeletonBox(100, 10),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _skeletonBox(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ─── PRODUCT MENU ──────────────────────────────────────────────────────────

  void _showProductMenu(ArtisanProduct ap) {
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
              const SizedBox(height: AppDimensions.md),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: AppDimensions.lg),
              _menuTile(Icons.edit_outlined, 'Edit Product', () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.smartCatalog);
              }),
              _menuTile(Icons.visibility_outlined, 'View Product', () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.productDetails, arguments: ap.product);
              }),
              _menuTile(Icons.content_copy, 'Duplicate', () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product duplicated', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white))),
                );
              }),
              if (ap.status == 'Published')
                _menuTile(Icons.unpublished_outlined, 'Unpublish', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product unpublished', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white))),
                  );
                }),
              _menuTile(Icons.delete_outline, 'Delete', () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(ap);
              }, isDestructive: true),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        );
      },
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : AppColors.charcoal, size: 20),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(color: isDestructive ? AppColors.error : AppColors.charcoal),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
    );
  }

  // ─── DELETE CONFIRMATION ───────────────────────────────────────────────────

  void _showDeleteConfirmation(ArtisanProduct ap) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusLG)),
        title: Text('Delete this product?', style: AppTextStyles.titleMedium),
        content: Text(
          'This product will be removed from your catalog.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProduct(ap.product.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${ap.product.name} deleted', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white))),
              );
            },
            child: Text('Delete', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return HastKalaBottomNavigation(
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
      items: HastKalaNavItems.artisanLegacy(context),
    );
  }
}
