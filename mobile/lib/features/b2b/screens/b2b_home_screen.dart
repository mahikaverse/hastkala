import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/helpers/artisan_image_helper.dart';
import '../../../core/models/marketplace_product.dart';
import '../../../core/models/artisan_profile.dart';
import '../services/b2b_service.dart';
import 'b2b_explore_screen.dart';
import 'b2b_requirement_form_screen.dart';
import 'b2b_product_detail_screen.dart';
import 'b2b_artisan_profile_screen.dart';
import 'b2b_regional_artisans_screen.dart';
import '../../../core/localization/language_provider.dart';

class B2BHomeScreen extends StatefulWidget {
  const B2BHomeScreen({super.key});

  @override
  State<B2BHomeScreen> createState() => _B2BHomeScreenState();
}

class _B2BHomeScreenState extends State<B2BHomeScreen> {
  final B2BService _service = B2BService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<MarketplaceProduct> _featuredProducts = [];
  List<ArtisanProfile> _topArtisans = [];
  List<ArtisanProfile> _regionalArtisans = [];
  bool _hasBuyerLocation = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.exploreProducts(),
        _service.getArtisans(),
      ]);
      setState(() {
        _featuredProducts = results[0] as List<MarketplaceProduct>;
        _topArtisans = results[1] as List<ArtisanProfile>;
        _isLoading = false;
      });
      _loadRegionalArtisans();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRegionalArtisans() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final city = user?.userMetadata?['location'] as String?;
      final state = user?.userMetadata?['state'] as String?;
      List<ArtisanProfile> artisans;
      if (city != null || state != null) {
        artisans = await _service.getArtisansByRegion(city: city, state: state);
      } else {
        artisans = await _service.getArtisans();
      }
      if (mounted && artisans.isNotEmpty) {
        setState(() {
          _regionalArtisans = artisans;
          _hasBuyerLocation = true;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header: Logo + Bell + Avatar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/horizontal-logo.png',
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                              'HastKala',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.brown,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lang.t('b2bTagline'),
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: AppColors.brown.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bell icon with red dot
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.brown.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.brown.withValues(alpha: 0.7),
                            size: 22,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Profile avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.brown,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.brown.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'B',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brown.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => B2BExploreScreen(initialSearch: value.trim()),
                          ),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: lang.t('b2bSearchHint'),
                      hintStyle: TextStyle(
                        color: AppColors.brown.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.brown.withValues(alpha: 0.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: AppColors.terracotta.withValues(alpha: 0.6),
                        ),
                        onPressed: () {},
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Hero Banner (image only) ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    'assets/b2b-hero-img.jpeg',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE8D8BE), Color(0xFFF8F1E3)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats Row ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.brown.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.groups_outlined, '5,000+', lang.t('b2bStatArtisans'), AppColors.terracotta),
                      _buildStatItem(Icons.category_outlined, '20+', lang.t('b2bStatCategories'), AppColors.oliveGreen),
                      _buildStatItem(Icons.location_on_outlined, '200+', lang.t('b2bStatClusters'), AppColors.mustardGold),
                      _buildStatItem(Icons.verified_outlined, 'Trusted by', lang.t('b2bStatBusinesses'), AppColors.brown),
                    ],
                  ),
                ),
              ),
            ),

            // ── Shop by Craft Category ──
            _buildSectionHeader(
              title: lang.t('b2bShopByCategory'),
              lang: lang,
              padding: const EdgeInsets.fromLTRB(20, 24, 16, 0),
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const B2BExploreScreen()),
                );
              },
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  children: [
                    _buildCategoryItem(lang.t('b2bTerracotta'), 'assets/craft/craft_terracotta_pot.jpg', AppColors.terracotta, lang: lang),
                    _buildCategoryItem(lang.t('b2bBambooCane'), 'assets/craft/craft_bamboo_basket.jpg', AppColors.mustardGold, lang: lang),
                    _buildCategoryItem(lang.t('b2bHandloom'), 'assets/craft/craft_handwoven_fabric.jpg', AppColors.oliveGreen, lang: lang),
                    _buildCategoryItem(lang.t('b2bJewellery'), 'assets/craft/craft_lac_bangles.jpg', AppColors.terracotta, lang: lang),
                    _buildCategoryItem(lang.t('b2bWoodcraft'), 'assets/craft/craft_wooden_carved_box.jpg', AppColors.brown, lang: lang),
                    _buildCategoryItem(lang.t('b2bHomeDecor'), 'assets/craft/craft_brass_metal.jpg', AppColors.mustardGold, lang: lang),
                    _buildCategoryItem(lang.t('b2bMore'), '', AppColors.brown, lang: lang),
                  ],
                ),
              ),
            ),

            // ── Post a Requirement Banner ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const B2BRequirementFormScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B3A1F), Color(0xFF8B5E3C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brown.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                   Text(
                                    lang.t('b2bPostRequirementBanner'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.terracotta,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lang.t('b2bAiMatch'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                lang.t('b2bPostBannerDesc'),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lang.t('b2bPostNow'),
                                style: TextStyle(
                                  color: AppColors.brown,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.chevron_right, size: 14, color: AppColors.brown),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Featured Artisan Products ──
            _buildSectionHeader(
              title: lang.t('b2bFeaturedProducts'),
              lang: lang,
              padding: const EdgeInsets.fromLTRB(20, 24, 16, 12),
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const B2BExploreScreen()),
                );
              },
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppColors.terracotta),
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 240,
                  child: _featuredProducts.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _featuredProducts.length.clamp(0, 6),
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                              return _buildProductCard(_featuredProducts[index], lang);
                          },
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _buildDemoProductCard('Folk Painted Terracotta Pots', 750, 50, 'Molela, Rajasthan', lang),
                            _buildDemoProductCard('Handmade Terracotta Dinner...', 450, 100, 'Khurja, Uttar Pradesh', lang),
                            _buildDemoProductCard('Bamboo Hanging Lamp', 950, 50, 'Tripura', lang),
                            _buildDemoProductCard('Handloom Silk Saree', 620, 20, 'Bhagalpur, Bihar', lang),
                          ],
                        ),
                ),
              ),

            // ── Featured Artisan Manufacturers ──
            _buildSectionHeader(
              title: lang.t('b2bFeaturedManufacturers'),
              lang: lang,
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
              onViewAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const B2BExploreScreen()),
                );
              },
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 175,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                    : _topArtisans.isNotEmpty
                        ? ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _topArtisans.length.clamp(0, 4),
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              return _buildManufacturerCard(_topArtisans[index], lang);
                            },
                          )
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _buildDemoManufacturerCard('Shakti Self Help Group', 'Women Artisans Collective', true, 'assets/artisans/artisan_meera.jpg', lang),
                              _buildDemoManufacturerCard('Kashmir Wood Crafts', 'Srinagar, J&K', true, 'assets/artisans/artisan_sita.jpg', lang),
                              _buildDemoManufacturerCard('Kutch Weavers Association', 'Bhuj, Gujarat', true, 'assets/artisans/artisan_arjun.jpg', lang),
                            ],
                          ),
              ),
            ),

            // ── Crafts From Your Region ──
            if (_hasBuyerLocation && !_isLoading) ...[
              _buildSectionHeader(
                title: lang.t('b2bCraftsFromRegion'),
                lang: lang,
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                onViewAll: () {
                  final user = Supabase.instance.client.auth.currentUser;
                  final city = user?.userMetadata?['location'] as String?;
                  final state = user?.userMetadata?['state'] as String?;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => B2BRegionalArtisansScreen(
                        buyerCity: city,
                        buyerState: state,
                      ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 175,
                  child: _regionalArtisans.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _regionalArtisans.length.clamp(0, 6),
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            return _buildRegionalArtisanCard(_regionalArtisans[index], lang);
                          },
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_off_outlined,
                                  size: 32,
                                  color: AppColors.brown.withValues(alpha: 0.25),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  lang.t('b2bNoLocalArtisans'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.brown.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  // ── Helper Widgets ──

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onViewAll,
    required LanguageProvider lang,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(20, 20, 16, 12),
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brown,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.t('b2bViewAll'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.terracotta,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.terracotta),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppColors.brown.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, String assetPath, Color color, {LanguageProvider? lang}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BExploreScreen(initialCategory: label.replaceAll('\n', ' ')),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: assetPath.isNotEmpty
                    ? Image.asset(
                        assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
Icons.palette_outlined,
                            color: color,
                            size: 28,
                          ),
                      )
                    : label == (lang?.t('b2bMore') ?? 'More')
                        ? Icon(
                            Icons.grid_view_rounded,
                            color: color,
                            size: 28,
                          )
                        : Icon(
                            Icons.palette_outlined,
                            color: color,
                            size: 28,
                          ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.brown.withValues(alpha: 0.8),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoProductCard(String name, int price, int minOrder, String location, LanguageProvider lang) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: Image.asset(
                      CraftImageHelper.getImageForProduct(
                        productId: name,
                        name: name,
                        category: location,
                      ),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF7EFE2),
                        child: const Center(
                          child: Icon(Icons.palette_outlined, size: 36, color: AppColors.terracotta),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppColors.brown.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracotta,
                          ),
                        ),
                        Text(
                          lang.t('b2bPerPiece'),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.brown.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${lang.t('b2bMinOrder')}: $minOrder ${lang.t('b2bPcs')}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.brown.withValues(alpha: 0.5),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: AppColors.brown.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.brown.withValues(alpha: 0.55),
                            ),
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

  Widget _buildProductCard(MarketplaceProduct product, LanguageProvider lang) {
    final firstImage = product.imageUrls.isNotEmpty ? product.imageUrls.first.trim() : '';
    final hasNetworkImage = firstImage.isNotEmpty &&
        (firstImage.startsWith('http://') || firstImage.startsWith('https://'));
    final fallbackAsset = CraftImageHelper.getImageForProduct(
      productId: product.id,
      craftType: product.craftType,
      category: product.category,
      name: product.name,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 165,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.brown.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7EFE2),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    child: hasNetworkImage
                        ? Image.network(
                            firstImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFF7EFE2),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.terracotta.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Image.asset(
                              fallbackAsset,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFF7EFE2),
                                child: const Center(
                                  child: Icon(Icons.palette_outlined, size: 36, color: AppColors.terracotta),
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            fallbackAsset,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF7EFE2),
                              child: const Center(
                                child: Icon(Icons.palette_outlined, size: 36, color: AppColors.terracotta),
                              ),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppColors.brown.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracotta,
                          ),
                        ),
                        Text(
                          lang.t('b2bPerPiece'),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.brown.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    if (product.stockQuantity > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${lang.t('b2bMinOrder')}: ${product.stockQuantity} ${lang.t('b2bPcs')}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.brown.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: AppColors.brown.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.craftType ?? product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.brown.withValues(alpha: 0.55),
                            ),
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

  Widget _buildManufacturerCard(ArtisanProfile artisan, LanguageProvider lang) {
    final fallbackAsset = ArtisanImageHelper.getAssetForArtisan(
      name: artisan.name,
      craftType: artisan.craftSpecialization,
      artisanId: artisan.id,
    );
    final useNetwork = !ArtisanImageHelper.isForeignerOrInvalidPhoto(artisan.avatarUrl);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BArtisanProfileScreen(artisan: artisan),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: 90,
                child: useNetwork
                    ? Image.network(
                        artisan.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          fallbackAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.terracotta.withValues(alpha: 0.08),
                            child: Center(
                              child: Text(
                                artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : 'A',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.terracotta.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Image.asset(
                        fallbackAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.terracotta.withValues(alpha: 0.08),
                          child: Center(
                            child: Text(
                              artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : 'A',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.terracotta.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _cleanLocation(artisan.location, artisan.state),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.brown.withValues(alpha: 0.55),
                      ),
                    ),
                    const Spacer(),
                    if (artisan.isVerified)
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 13, color: Colors.blue),
                          const SizedBox(width: 3),
                          Text(
                            lang.t('b2bVerified'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.withValues(alpha: 0.8),
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

  Widget _buildDemoManufacturerCard(String name, String subtitle, bool verified, String assetPath, LanguageProvider lang) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: 90,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.terracotta.withValues(alpha: 0.08),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.terracotta.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.brown.withValues(alpha: 0.55),
                      ),
                    ),
                    const Spacer(),
                    if (verified)
                      Row(
                        children: [
                          const Icon(Icons.verified, size: 13, color: Colors.blue),
                          const SizedBox(width: 3),
                          Text(
                            lang.t('b2bVerified'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.withValues(alpha: 0.8),
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

  Widget _buildRegionalArtisanCard(ArtisanProfile artisan, LanguageProvider lang) {
    final fallbackAsset = ArtisanImageHelper.getAssetForArtisan(
      name: artisan.name,
      craftType: artisan.craftSpecialization,
      artisanId: artisan.id,
    );
    final useNetwork = !ArtisanImageHelper.isForeignerOrInvalidPhoto(artisan.avatarUrl);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => B2BArtisanProfileScreen(artisan: artisan),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brown.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                width: double.infinity,
                height: 80,
                child: useNetwork
                    ? Image.network(
                        artisan.avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          fallbackAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.terracotta.withValues(alpha: 0.08),
                            child: Center(
                              child: Text(
                                artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : 'A',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.terracotta.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Image.asset(
                        fallbackAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.terracotta.withValues(alpha: 0.08),
                          child: Center(
                            child: Text(
                              artisan.name.isNotEmpty ? artisan.name[0].toUpperCase() : 'A',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppColors.terracotta.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artisan.craftSpecialization,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.terracotta.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 10,
                          color: AppColors.brown.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            _cleanLocation(artisan.location, artisan.state),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.brown.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 26,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => B2BArtisanProfileScreen(artisan: artisan),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: BorderSide(color: AppColors.terracotta.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          lang.t('b2bViewProfile'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.terracotta,
                          ),
                        ),
                      ),
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

  String _cleanLocation(String location, String state) {
    if (location.isEmpty && state.isEmpty) return '';
    if (state.isEmpty) return location;
    if (location.isEmpty) return state;
    if (location.endsWith(', $state') || location == state) return location;
    return '$location, $state';
  }
}
