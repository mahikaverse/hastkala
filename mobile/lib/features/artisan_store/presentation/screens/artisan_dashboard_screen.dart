import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/localization/language_provider.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/adaptive_product_image.dart';
import '../../../../core/widgets/hastkala_bottom_nav.dart';
import 'my_products_screen.dart';
import 'schemes_events_screen.dart';
import 'marketplace_hub_screen.dart';
import 'artisan_profile_new_screen.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  final DataService _data = DataService();
  int _currentNavIndex = 0;

  // Scheme carousel
  final PageController _schemePageController = PageController();
  int _schemePage = 0;
  Timer? _schemeTimer;

  // Exhibition carousel
  final PageController _exhibitionPageController = PageController();
  int _exhibitionPage = 0;
  Timer? _exhibitionTimer;

  static const _schemeImages = [
    'assets/government1-img.png',
    'assets/government2-img.png',
    'assets/government3-img.png',
  ];

  static const _exhibitionImages = [
    'assets/exibitions-img.png',
    'assets/exibitions2-img.png',
  ];

  ArtisanStore? get _store =>
      _data.stores.isNotEmpty ? _data.stores.first : null;

  ArtisanProfile? get _profile =>
      _data.artisanProfiles.isNotEmpty ? _data.artisanProfiles.first : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSchemeTimer();
      _startExhibitionTimer();
    });
  }

  @override
  void dispose() {
    _schemeTimer?.cancel();
    _exhibitionTimer?.cancel();
    _schemePageController.dispose();
    _exhibitionPageController.dispose();
    super.dispose();
  }

  void _startSchemeTimer() {
    _schemeTimer?.cancel();
    _schemeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_schemePageController.hasClients) return;
      final total = _schemeImages.length;
      final next = (_schemePage + 1) % total;
      _schemePageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _startExhibitionTimer() {
    _exhibitionTimer?.cancel();
    _exhibitionTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_exhibitionPageController.hasClients) return;
      final total = _exhibitionImages.length;
      final next = (_exhibitionPage + 1) % total;
      _exhibitionPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentNavIndex == 0
          ? _buildHomeTab()
          : _currentNavIndex == 1
              ? const SchemesEventsScreen()
              : _currentNavIndex == 2
                  ? const MarketplaceHubScreen()
                  : const ArtisanProfileNewScreen(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HOME TAB ──────────────────────────────────────────────────────────────

  Widget _buildHomeTab() {
    final store = _store;
    final profile = _profile;
    if (store == null) return Center(child: Text(LanguageProvider.of(context).t('noStoreFound')));
    final stats = _data.getStoreStats(store.id);
    final products = _data.getProductsByStore(store.id);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        _buildHeader(store, profile),
        _buildAICraftAssistant(),
        _buildStatsRow(stats),
        _buildOpportunities(),
        _buildMyProductsSection(products),
        _buildMarketplaceHubCard(),
        _buildGovernmentSchemes(),
        _buildUpcomingExhibitions(),
      ],
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────

  Widget _buildHeader(ArtisanStore store, ArtisanProfile? profile) {
    final lang = LanguageProvider.of(context);
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
                      Builder(
                        builder: (ctx) {
                          final lang = LanguageProvider.of(ctx);
                          return GestureDetector(
                            onTap: () => _showLanguageSheet(ctx),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.brown.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.language_rounded, size: 16, color: AppColors.brown),
                                  const SizedBox(width: 4),
                                  Text(
                                    lang.langCode == 'hi' ? 'हिन्दी' : 'EN',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brown),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
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
                  Text(lang.t('welcomeBack'), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          store.name.isNotEmpty ? store.name : lang.t('artisan'),
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
                              Text(lang.t('verified'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.oliveGreen)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lang.t('tagline'),
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

  // ─── AI CRAFT ASSISTANT ─────────────────────────────────────────────────

  Widget _buildAICraftAssistant() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 18),
                      const SizedBox(width: 6),
                      Text(lang.t('aiCraftAssistant'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.t('aiDescription'),
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      _featureChip(Icons.mic, lang.t('speakLanguage')),
                      _featureChip(Icons.camera_alt_outlined, lang.t('addPhoto')),
                      _featureChip(Icons.auto_awesome, lang.t('aiDoesRest')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(lang.t('addProduct'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 110,
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                'assets/app-logo.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.park_rounded, size: 60, color: AppColors.brown.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.terracotta),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  // ─── STATISTICS ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(Map<String, dynamic> stats) {
    final lang = LanguageProvider.of(context);
    final items = [
      _StatItem(Icons.inventory_2_outlined, AppColors.terracotta, '${stats['totalProducts'] ?? 0}', lang.t('products')),
      _StatItem(Icons.shopping_bag_outlined, AppColors.oliveGreen, '${stats['totalOrders'] ?? 0}', lang.t('orders')),
      _StatItem(Icons.currency_rupee_rounded, AppColors.mustardGold, '₹${(stats['totalRevenue'] ?? 0).toInt()}', lang.t('revenue')),
      _StatItem(Icons.visibility_outlined, Colors.blue.shade600, '${stats['totalViews'] ?? 0}', lang.t('visits')),
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

  // ─── OPPORTUNITIES ────────────────────────────────────────────────────────

  Widget _buildOpportunities() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline_rounded, color: AppColors.oliveGreen, size: 20),
                const SizedBox(width: 8),
                Text(lang.t('opportunities'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                const Spacer(),
                Text(lang.t('viewAll'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.terracotta)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.terracotta),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warmBeige.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.handshake_rounded, color: AppColors.terracotta, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.terracotta,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(lang.t('b2b'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(lang.t('bulkOrderRequest'), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(lang.t('woodenBoxes'), style: TextStyle(fontSize: 13, color: AppColors.charcoal)),
                        const SizedBox(height: 2),
                        Text(lang.t('buyerDelhi'), style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(lang.t('priceRange'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.brown)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.oliveGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(lang.t('aiMatch'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.oliveGreen)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.warmBeige,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.inventory_2_outlined, color: AppColors.brown.withValues(alpha: 0.5), size: 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang.t('viewRequest'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MY PRODUCTS SECTION ───────────────────────────────────────────────────

  Widget _buildMyProductsSection(List<MarketplaceProduct> products) {
    final lang = LanguageProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          child: Row(
            children: [
              Text(lang.t('myProducts'), style: AppTextStyles.titleMedium.copyWith(
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
                    Text(lang.t('viewAll'), style: AppTextStyles.bodyMedium.copyWith(
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
    final lang = LanguageProvider.of(context);
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
            Text(lang.t('noProductsYet'), style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13,
            )),
            const SizedBox(height: 4),
            Text(
              lang.t('addFirstProduct'),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusFull)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
              ),
              child: Text(lang.t('addProduct')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHorizontalCard(MarketplaceProduct product) {
    final lang = LanguageProvider.of(context);
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
                            product.stockQuantity > 0 ? '${lang.t('inStock')} (${product.stockQuantity})' : lang.t('outOfStock'),
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

  // ─── MARKETPLACE HUB CARD ────────────────────────────────────────────────

  Widget _buildMarketplaceHubCard() {
    final lang = LanguageProvider.of(context);
    final store = _store;
    final publishedCount = store != null ? _data.getPublishedProductsByStore(store.id).length : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.marketplaceHub),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.mustardGold.withValues(alpha: 0.9), AppColors.terracotta.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.mustardGold.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.t('marketplaceHub'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$publishedCount ${lang.t('productsReadyExport')}',
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── GOVERNMENT SCHEMES CAROUSEL ─────────────────────────────────────────

  Widget _buildGovernmentSchemes() {
    final lang = LanguageProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          child: Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: AppColors.terracotta, size: 20),
              const SizedBox(width: 8),
              Text(lang.t('schemesForYourArt'), style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 16,
              )),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.schemesEvents),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang.t('viewAll'), style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.terracotta, fontWeight: FontWeight.w600, fontSize: 13,
                    )),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.terracotta),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _schemePageController,
            itemCount: _schemeImages.length,
            onPageChanged: (i) => setState(() => _schemePage = i),
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.schemesEvents),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      child: Image.asset(
                        _schemeImages[i],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.terracotta,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                          ),
                          child: Icon(
                            Icons.account_balance_rounded,
                            size: 48,
                            color: AppColors.cream.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_schemeImages.length, (i) {
            final active = i == _schemePage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppColors.terracotta : AppColors.border,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── UPCOMING EXHIBITIONS ─────────────────────────────────────────────────

  Widget _buildUpcomingExhibitions() {
    final lang = LanguageProvider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
          child: Row(
            children: [
              const Icon(Icons.event_rounded, color: AppColors.mustardGold, size: 20),
              const SizedBox(width: 8),
              Text(lang.t('upcomingExhibitions'), style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.charcoal, fontSize: 16,
              )),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.schemesEvents, arguments: 1),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(lang.t('viewAll'), style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.terracotta, fontWeight: FontWeight.w600, fontSize: 13,
                    )),
                    const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.terracotta),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _exhibitionPageController,
            itemCount: _exhibitionImages.length,
            onPageChanged: (i) => setState(() => _exhibitionPage = i),
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.schemesEvents, arguments: 1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      child: Image.asset(
                        _exhibitionImages[i],
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppColors.mustardGold,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                          ),
                          child: Icon(
                            Icons.event_rounded,
                            size: 48,
                            color: AppColors.cream.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_exhibitionImages.length, (i) {
            final active = i == _exhibitionPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? AppColors.mustardGold : AppColors.border,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ─── LANGUAGE SHEET ──────────────────────────────────────────────────────

  void _showLanguageSheet(BuildContext ctx) {
    final lang = LanguageProvider.of(ctx);
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang.t('language'),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(ctx, 'en', 'English', 'English'),
              const SizedBox(height: 8),
              _buildLanguageOption(ctx, 'hi', 'हिन्दी', 'हिन्दी (Hindi)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, String code, String label, String subtitle) {
    final lang = LanguageProvider.of(ctx);
    final isSelected = lang.langCode == code;
    return GestureDetector(
      onTap: () {
        lang.setLanguage(code);
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracotta.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(width: 8),
            Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 20, color: AppColors.terracotta),
          ],
        ),
      ),
    );
  }

  // ─── BOTTOM NAV ────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final lang = LanguageProvider.of(context);
    return HastKalaBottomNavigation(
      currentIndex: _currentNavIndex,
      onTap: (index) {
        setState(() => _currentNavIndex = index);
      },
      items: HastKalaNavItems.artisan(context),
      centerButton: HastKalaCenterButton(
        icon: Icons.camera_alt_rounded,
        label: lang.t('add'),
        onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
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
