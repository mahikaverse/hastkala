import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/helpers/craft_image_helper.dart';
import '../../../core/helpers/artisan_image_helper.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/artisan_profile.dart';
import '../../../core/models/marketplace_product.dart';
import '../services/b2b_service.dart';
import 'b2b_product_detail_screen.dart';
import 'b2b_enquiry_form_screen.dart';

class B2BArtisanProfileScreen extends StatefulWidget {
  final ArtisanProfile artisan;

  const B2BArtisanProfileScreen({super.key, required this.artisan});

  @override
  State<B2BArtisanProfileScreen> createState() => _B2BArtisanProfileScreenState();
}

class _B2BArtisanProfileScreenState extends State<B2BArtisanProfileScreen> {
  final B2BService _service = B2BService();
  bool _isSaved = false;
  List<MarketplaceProduct> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _checkSaved();
    _loadProducts();
  }

  Future<void> _checkSaved() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final saved = await _service.isArtisanSaved(userId, widget.artisan.id);
      setState(() => _isSaved = saved);
    }
  }

  Future<void> _loadProducts() async {
    final products = await _service.exploreProducts();
    var artisanProducts = products.where((p) => p.artisanId == widget.artisan.id).toList();

    if (artisanProducts.isEmpty) {
      final specLower = widget.artisan.craftSpecialization.toLowerCase();
      artisanProducts = products.where((p) {
        final pCraft = (p.craftType ?? '').toLowerCase();
        final pCat = p.category.toLowerCase();
        return specLower.isNotEmpty &&
            (pCraft.contains(specLower) ||
                specLower.contains(pCraft) ||
                pCat.contains(specLower) ||
                specLower.contains(pCat));
      }).toList();
    }

    if (artisanProducts.isEmpty && products.isNotEmpty) {
      artisanProducts = products.take(4).toList();
    }

    if (mounted) {
      setState(() {
        _products = artisanProducts;
        _isLoadingProducts = false;
      });
    }
  }

  String _cleanLocation(String location, String state) {
    if (location.isEmpty && state.isEmpty) return '';
    if (state.isEmpty) return location;
    if (location.isEmpty) return state;
    if (location.endsWith(', $state') || location == state) return location;
    return '$location, $state';
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    final artisan = widget.artisan;
    final cleanLoc = _cleanLocation(artisan.location, artisan.state);

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF8F0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.brown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          artisan.name,
          style: TextStyle(
            color: AppColors.brown,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppColors.terracotta : AppColors.brown.withValues(alpha: 0.5),
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Large Hero Image ──
            _buildHeroImage(artisan),

            const SizedBox(height: 20),

            // ── Artisan Identity ──
            _buildIdentity(artisan, cleanLoc),

            const SizedBox(height: 20),

            // ── Stats ──
            _buildStats(artisan, lang),

            const SizedBox(height: 24),

            // ── Journey & Heritage ──
            _buildJourneyCard(artisan),

            const SizedBox(height: 20),

            // ── About ──
            if (artisan.bio.isNotEmpty) _buildAbout(artisan),

            // ── Specialization ──
            if (artisan.craftSpecialization.isNotEmpty) _buildSpecialization(artisan),

            // ── Products ──
            _buildProductsSection(lang),
          ],
        ),
      ),

      // ── Fixed Send Enquiry CTA ──
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => B2BEnquiryFormScreen(
                    artisanId: artisan.id,
                    artisanName: artisan.name,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.send_outlined, size: 18),
            label: Text(
              lang.t('b2bSendEnquiry'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.terracotta,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO IMAGE ────────────────────────────────────────────────────────────

  Widget _buildHeroImage(ArtisanProfile artisan) {
    final fallbackAsset = ArtisanImageHelper.getAssetForArtisan(
      name: artisan.name,
      craftType: artisan.craftSpecialization,
      artisanId: artisan.id,
    );
    final useNetwork = !ArtisanImageHelper.isForeignerOrInvalidPhoto(artisan.avatarUrl);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.brown.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: useNetwork
                ? Image.network(
                    artisan.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackHero(fallbackAsset, artisan.name),
                  )
                : Image.asset(
                    fallbackAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderHero(artisan.name),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackHero(String asset, String name) {
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholderHero(name),
    );
  }

  Widget _buildPlaceholderHero(String name) {
    return Container(
      color: AppColors.terracotta.withValues(alpha: 0.08),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'A',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: AppColors.terracotta.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  // ── IDENTITY ──────────────────────────────────────────────────────────────

  Widget _buildIdentity(ArtisanProfile artisan, String cleanLoc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Name + Verified
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  artisan.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (artisan.isVerified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified, color: AppColors.oliveGreen, size: 22),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // Craft
          if (artisan.craftSpecialization.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                artisan.craftSpecialization,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.terracotta,
                ),
              ),
            ),

          // Location
          if (cleanLoc.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.brown.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    cleanLoc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.brown.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── STATS ─────────────────────────────────────────────────────────────────

  Widget _buildStats(ArtisanProfile artisan, LanguageProvider lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brown.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            _buildStatItem(
              '${_products.length}',
              lang.t('b2bProducts'),
              AppColors.terracotta,
            ),
            _buildDivider(),
            _buildStatItem(
              artisan.averageRating > 0 ? artisan.averageRating.toStringAsFixed(1) : '-',
              lang.t('b2bRating'),
              AppColors.mustardGold,
            ),
            _buildDivider(),
            _buildStatItem(
              artisan.yearsOfExperience > 0 ? '${artisan.yearsOfExperience}yr' : '-',
              lang.t('b2bExperience'),
              AppColors.oliveGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.brown.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.brown.withValues(alpha: 0.08),
    );
  }

  // ── JOURNEY & HERITAGE ────────────────────────────────────────────────────

  Widget _buildJourneyCard(ArtisanProfile artisan) {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.terracotta.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.terracotta.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.terracotta,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.t('b2bArtisanJourney'),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brown,
                        ),
                      ),
                      Text(
                        'कारीगर की कहानी व परंपरा',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.terracotta,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              ArtisanImageHelper.getArtisanStory(artisan),
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppColors.brown.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ABOUT ─────────────────────────────────────────────────────────────────

  Widget _buildAbout(ArtisanProfile artisan) {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('b2bAbout'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artisan.bio,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.brown.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // ── SPECIALIZATION ────────────────────────────────────────────────────────

  Widget _buildSpecialization(ArtisanProfile artisan) {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.t('b2bSpecialization'),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  artisan.craftSpecialization,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.oliveGreen,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── PRODUCTS ──────────────────────────────────────────────────────────────

  Widget _buildProductsSection(LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                '${lang.t('b2bProducts')} (${_products.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
        ),

        if (_isLoadingProducts)
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            ),
          )
        else if (_products.isEmpty)
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Text(
                lang.t('b2bNoProductsListed'),
                style: TextStyle(
                  color: AppColors.brown.withValues(alpha: 0.4),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = _products[index];
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
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brown.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: product.imageUrls.isNotEmpty
                                  ? Image.network(
                                      product.imageUrls.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        CraftImageHelper.getImageForProduct(
                                          productId: product.id,
                                          craftType: product.craftType,
                                          category: product.category,
                                          name: product.name,
                                        ),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                  : Image.asset(
                                      CraftImageHelper.getImageForProduct(
                                        productId: product.id,
                                        craftType: product.craftType,
                                        category: product.category,
                                        name: product.name,
                                      ),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.brown,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${product.price.toStringAsFixed(0)}/pc',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.terracotta,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ── SAVE TOGGLE ───────────────────────────────────────────────────────────

  Future<void> _toggleSave() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    if (_isSaved) {
      await _service.unsaveArtisan(userId, widget.artisan.id);
    } else {
      await _service.saveArtisan(userId, widget.artisan.id);
    }
    setState(() => _isSaved = !_isSaved);
  }
}
