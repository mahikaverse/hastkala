import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/models/models.dart';
import '../../../../core/services/data_service.dart';
import '../../../../core/widgets/marketplace_product_card.dart';

class ArtisanStoreScreen extends StatefulWidget {
  final String storeSlug;

  const ArtisanStoreScreen({super.key, required this.storeSlug});

  @override
  State<ArtisanStoreScreen> createState() => _ArtisanStoreScreenState();
}

class _ArtisanStoreScreenState extends State<ArtisanStoreScreen> {
  final DataService _data = DataService();
  ArtisanStore? _store;
  ArtisanProfile? _profile;
  List<MarketplaceProduct> _products = [];
  List<StoreCollection> _collections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  void _loadStore() {
    final store = _data.getStoreBySlug(widget.storeSlug);
    if (store != null) {
      final profile = _data.getArtisanProfile(store.artisanId);
      final products = _data.getPublishedProductsByStore(store.id);
      final collections = _data.getCollectionsByStore(store.id);
      setState(() {
        _store = store;
        _profile = profile;
        _products = products;
        _collections = collections;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.terracotta)),
      );
    }

    if (_store == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Store Not Found')),
        body: const Center(child: Text('This store could not be found.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(child: _buildStoreHeader()),
          SliverToBoxAdapter(child: _buildStoreInfo()),
          if (_collections.isNotEmpty) SliverToBoxAdapter(child: _buildCollections()),
          SliverToBoxAdapter(child: _buildSectionTitle('Our Crafts')),
          _buildProductGrid(),
          SliverToBoxAdapter(child: _buildAboutSection()),
          SliverToBoxAdapter(child: _buildReviewsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.brown,
      flexibleSpace: FlexibleSpaceBar(
        background: _store!.bannerUrl.isNotEmpty
            ? Image.asset(_store!.bannerUrl, fit: BoxFit.cover)
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.brown, AppColors.brownLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.store_outlined,
                    size: 80,
                    color: AppColors.cream.withValues(alpha: 0.3),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.xxl),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -40),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
                color: AppColors.warmBeige,
              ),
              child: _profile?.avatarUrl.isNotEmpty == true
                  ? ClipOval(child: Image.asset(_profile!.avatarUrl, fit: BoxFit.cover))
                  : const Icon(Icons.person, size: 48, color: AppColors.brown),
            ),
          ),
          const SizedBox(height: 4),
          Transform.translate(
            offset: const Offset(0, -32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _store!.name,
                      style: AppTextStyles.headlineLarge.copyWith(color: AppColors.brown),
                    ),
                    if (_store!.isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 20, color: AppColors.oliveGreen),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _store!.craftCategory,
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.mustardGold),
                    const SizedBox(width: 4),
                    Text(
                      _store!.averageRating.toStringAsFixed(1),
                      style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${_store!.totalReviews} reviews)',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      '${_store!.location}, ${_store!.state}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _store!.description,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('${_store!.totalProducts}', 'Products'),
          _buildDivider(),
          _buildStatItem('${_store!.totalFollowers}', 'Followers'),
          _buildDivider(),
          _buildStatItem('${_store!.totalSales}', 'Sales'),
          _buildDivider(),
          _buildStatItem(_store!.averageRating.toStringAsFixed(1), 'Rating'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 32, color: AppColors.divider);
  }

  Widget _buildCollections() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl, vertical: AppDimensions.lg),
        itemCount: _collections.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
        itemBuilder: (context, index) {
          final col = _collections[index];
          return Container(
            width: 160,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(col.name, style: AppTextStyles.titleSmall.copyWith(color: AppColors.brown, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('${col.productIds.length} items', style: AppTextStyles.caption),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xxl, AppDimensions.lg, AppDimensions.xxl, AppDimensions.md),
      child: Text(title, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown)),
    );
  }

  Widget _buildProductGrid() {
    if (_products.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.xxl),
          child: Center(child: Text('No products available yet.', style: AppTextStyles.bodyMedium)),
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
          delegate: SliverChildBuilderDelegate(
          (context, index) => MarketplaceProductCard(product: _products[index]),
          childCount: _products.length,
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    if (_profile == null || _profile!.craftStory.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(AppDimensions.xxl),
      padding: const EdgeInsets.all(AppDimensions.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.terracotta, size: 20),
              const SizedBox(width: 8),
              Text('About the Artisan', style: AppTextStyles.titleLarge.copyWith(color: AppColors.brown)),
            ],
          ),
          const SizedBox(height: 12),
          Text(_profile!.craftStory, style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.charcoal)),
          if (_profile!.craftSpecialization.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Craft Specialization', style: AppTextStyles.titleSmall.copyWith(color: AppColors.brown)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.craftSpecialization.split(',').map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.terracotta.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(e.trim(), style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final storeReviews = _data.getReviewsByStore(_store!.id);
    if (storeReviews.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Customer Reviews'),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
            itemCount: storeReviews.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppDimensions.md),
            itemBuilder: (context, index) {
              final review = storeReviews[index];
              return Container(
                width: 280,
                padding: const EdgeInsets.all(AppDimensions.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.warmBeige,
                          child: Text(review.buyerName[0], style: AppTextStyles.labelMedium.copyWith(color: AppColors.brown)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(review.buyerName, style: AppTextStyles.labelMedium)),
                        ...List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          size: 14, color: AppColors.mustardGold,
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(review.comment, style: AppTextStyles.bodySmall.copyWith(height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isFollowing = _data.isFollowing(_store!.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xxl, 12, AppDimensions.xxl, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() => _data.toggleFollow(_store!.id));
              },
              icon: Icon(
                isFollowing ? Icons.favorite : Icons.favorite_border,
                color: isFollowing ? AppColors.terracotta : AppColors.charcoal,
                size: 20,
              ),
              label: Text(isFollowing ? 'Following' : 'Follow',
                style: AppTextStyles.buttonMedium.copyWith(color: isFollowing ? AppColors.terracotta : AppColors.charcoal)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: isFollowing ? AppColors.terracotta : AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined, size: 20),
              label: const Text('Share Store'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracotta,
                foregroundColor: AppColors.cream,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMD)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
