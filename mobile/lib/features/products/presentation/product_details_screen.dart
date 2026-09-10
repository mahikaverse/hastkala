import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  bool _isWished = false;
  bool _descriptionExpanded = false;
  int _quantity = 1;

  late final List<String> _galleryImages;

  @override
  void initState() {
    super.initState();
    _galleryImages = [
      widget.product.imageUrl,
      widget.product.imageUrl,
      widget.product.imageUrl,
      widget.product.imageUrl,
    ];
  }

  Product get _product => widget.product;

  int get _discountPercent {
    if (_product.oldPrice == null) return 0;
    return ((1 - _product.price / _product.oldPrice!) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeroImage()),
                SliverToBoxAdapter(child: _buildImageGallery()),
                SliverToBoxAdapter(child: _buildProductHeader()),
                SliverToBoxAdapter(child: _buildRating()),
                SliverToBoxAdapter(child: _buildPrice()),
                SliverToBoxAdapter(child: _buildArtisanStory()),
                SliverToBoxAdapter(child: _buildCraftStory()),
                SliverToBoxAdapter(child: _buildCraftDetails()),
                SliverToBoxAdapter(child: _buildProductHighlights()),
                SliverToBoxAdapter(child: _buildDeliveryInfo()),
                SliverToBoxAdapter(child: _buildQuantitySelector()),
                SliverToBoxAdapter(child: _buildReviews()),
                SliverToBoxAdapter(child: _buildSimilarCrafts()),
                SliverToBoxAdapter(child: _buildTrustBadges()),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(top: 0, left: 0, right: 0, child: _buildTopOverlay()),
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
          ],
        ),
      ),
    );
  }

  // ─── 1. TOP IMAGE EXPERIENCE ───────────────────────────────────────────────

  Widget _buildHeroImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.42,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: _galleryImages.length,
            onPageChanged: (i) => setState(() => _selectedImageIndex = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppDimensions.radiusXL)),
                child: Image.network(
                  _galleryImages[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  cacheHeight: 800,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.warmBeige,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: AlwaysStoppedAnimation(AppColors.terracotta.withValues(alpha: 0.5)),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.warmBeige,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.handyman_outlined, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                            const SizedBox(height: AppDimensions.sm),
                            Text('Handcrafted with love', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${_selectedImageIndex + 1} / ${_galleryImages.length}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.cream),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
        child: Row(
          children: [
            _circleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
              semanticLabel: 'Go back',
            ),
            const Spacer(),
            _circleButton(
              icon: _isWished ? Icons.favorite : Icons.favorite_border,
              onTap: _toggleWishlist,
              color: _isWished ? AppColors.terracotta : null,
              semanticLabel: _isWished ? 'Remove from wishlist' : 'Add to wishlist',
            ),
            const SizedBox(width: AppDimensions.sm),
            _circleButton(
              icon: Icons.share_outlined,
              onTap: _showShareSheet,
              semanticLabel: 'Share product',
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    String? semanticLabel,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
          ),
          child: Icon(icon, size: 18, color: color ?? AppColors.charcoal),
        ),
      ),
    );
  }

  // ─── 2. IMAGE GALLERY ──────────────────────────────────────────────────────

  Widget _buildImageGallery() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.md, AppDimensions.xl, 0),
      child: SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _galleryImages.length,
          separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
          itemBuilder: (context, index) {
            final isSelected = _selectedImageIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedImageIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(
                    color: isSelected ? AppColors.terracotta : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM - 1),
                  child: Image.network(
                    _galleryImages[index],
                    fit: BoxFit.cover,
                    cacheWidth: 150,
                    cacheHeight: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.warmBeige,
                        child: Icon(Icons.image_outlined, size: 24, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── 3. PRODUCT HEADER ─────────────────────────────────────────────────────

  Widget _buildProductHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  '${_product.category.toUpperCase()} \u2022 ${_product.tags.isNotEmpty ? _product.tags.first.toUpperCase() : 'CRAFT'}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.brown, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            _product.name,
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.brown,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. RATING ─────────────────────────────────────────────────────────────

  Widget _buildRating() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.md, AppDimensions.xl, 0),
      child: GestureDetector(
        onTap: () {
          // Scroll to reviews section (placeholder)
        },
        child: Row(
          children: [
            Icon(Icons.star_rounded, size: 20, color: AppColors.mustardGold),
            const SizedBox(width: 4),
            Text(
              _product.rating.toString(),
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.mustardGold),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              '${_product.reviews} reviews',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 5. PRICE ──────────────────────────────────────────────────────────────

  Widget _buildPrice() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.lg, AppDimensions.xl, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\u20B9${_product.price}',
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.terracotta,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (_product.oldPrice != null) ...[
            const SizedBox(width: AppDimensions.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                '\u20B9${_product.oldPrice}',
                style: AppTextStyles.bodyLarge.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.oliveGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Text(
                '$_discountPercent% OFF',
                style: AppTextStyles.labelSmall.copyWith(color: AppColors.oliveGreen),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 6. ARTISAN STORY ──────────────────────────────────────────────────────

  Widget _buildArtisanStory() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CRAFTED BY', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, letterSpacing: 1.2)),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.warmBeige,
                    border: Border.all(color: AppColors.mustardGold.withValues(alpha: 0.3), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
                      fit: BoxFit.cover,
                      cacheWidth: 120,
                      cacheHeight: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, color: AppColors.brown, size: 28);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_product.artisan, style: AppTextStyles.titleMedium),
                          const SizedBox(width: 4),
                          Icon(Icons.verified, size: 16, color: AppColors.oliveGreen),
                        ],
                      ),
                      Text(_product.location, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                '"Every pattern carries a story passed down through generations."',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.brown,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            GestureDetector(
              onTap: () {
                // Artisan profile navigation placeholder
              },
              child: Row(
                children: [
                  Text('Meet the Artisan', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.terracotta),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 7. CRAFT STORY ────────────────────────────────────────────────────────

  Widget _buildCraftStory() {
    final shortDesc = _product.description;
    final fullDesc = '$shortDesc\n\nEach piece is unique, reflecting the individual artistry and cultural heritage of the craftsman. '
        'The techniques used have been perfected over centuries, passed from master to apprentice within artisan communities.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About this Craft', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.sm),
          Text(
            _descriptionExpanded ? fullDesc : shortDesc,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.sm),
          GestureDetector(
            onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
            child: Text(
              _descriptionExpanded ? 'Read Less' : 'Read More',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 8. CRAFT DETAILS ──────────────────────────────────────────────────────

  Widget _buildCraftDetails() {
    final details = [
      _DetailRow('Material', 'Handwoven Cotton'),
      _DetailRow('Technique', 'Traditional ${_product.tags.isNotEmpty ? _product.tags.first : 'Handcraft'}'),
      _DetailRow('Craft Region', _product.location),
      _DetailRow('Made By', 'Skilled Artisans'),
      _DetailRow('Care', 'Gentle Hand Wash'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Craft Details', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: details.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 110,
                        child: Text(d.label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                      ),
                      Expanded(
                        child: Text(d.value, style: AppTextStyles.bodyMedium),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 9. PRODUCT HIGHLIGHTS ─────────────────────────────────────────────────

  Widget _buildProductHighlights() {
    final highlights = [
      _Highlight('Handmade', Icons.handyman_outlined),
      _Highlight('Artisan-made', Icons.person_outline),
      _Highlight('Eco-conscious', Icons.eco_outlined),
      _Highlight('Unique piece', Icons.star_outline),
      _Highlight('Made in India', Icons.flag_outlined),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Wrap(
        spacing: AppDimensions.sm,
        runSpacing: AppDimensions.sm,
        children: highlights.map((h) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(h.icon, size: 14, color: AppColors.oliveGreen),
                const SizedBox(width: 4),
                Text(h.label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── 10. DELIVERY INFORMATION ──────────────────────────────────────────────

  Widget _buildDeliveryInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping_outlined, size: 20, color: AppColors.brown),
                const SizedBox(width: AppDimensions.sm),
                Text('Delivery to Mumbai, Maharashtra', style: AppTextStyles.titleSmall),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: Text('Change', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: AppDimensions.sm),
                Text('Estimated delivery: 4\u20136 business days', style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: AppColors.oliveGreen),
                const SizedBox(width: AppDimensions.sm),
                Text('Secure packaging', style: AppTextStyles.bodySmall),
                const SizedBox(width: AppDimensions.xl),
                Icon(Icons.check_circle_outline, size: 16, color: AppColors.oliveGreen),
                const SizedBox(width: AppDimensions.sm),
                Text('Easy support', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── 11. QUANTITY ──────────────────────────────────────────────────────────

  Widget _buildQuantitySelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quantity', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _quantityButton(
                  icon: Icons.remove,
                  onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                ),
                Container(
                  width: 48,
                  alignment: Alignment.center,
                  child: Text('$_quantity', style: AppTextStyles.titleMedium),
                ),
                _quantityButton(
                  icon: Icons.add,
                  onTap: _quantity < 10 ? () => setState(() => _quantity++) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({required IconData icon, VoidCallback? onTap}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.cream : AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? AppColors.charcoal : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ─── 12. REVIEWS ───────────────────────────────────────────────────────────

  Widget _buildReviews() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customer Reviews', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Text('4.8', style: AppTextStyles.displaySmall.copyWith(color: AppColors.mustardGold)),
              const SizedBox(width: AppDimensions.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (i) => Icon(
                      i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                      size: 18,
                      color: AppColors.mustardGold,
                    )),
                  ),
                  Text('${_product.reviews} reviews', style: AppTextStyles.bodySmall),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),
          _reviewCard(
            'Beautiful craftsmanship and the detailing is even better in person.',
            'Ananya',
            5,
          ),
          const SizedBox(height: AppDimensions.sm),
          _reviewCard(
            'Feels genuinely handmade and premium. Loved the packaging too.',
            'Priya',
            5,
          ),
          const SizedBox(height: AppDimensions.sm),
          _reviewCard(
            'Great quality for the price. Will buy more as gifts.',
            'Rahul',
            4,
          ),
          const SizedBox(height: AppDimensions.md),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text('See All Reviews', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, size: 18, color: AppColors.terracotta),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(String text, String name, int stars) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(5, (i) => Icon(
              Icons.star_rounded,
              size: 14,
              color: i < stars ? AppColors.mustardGold : AppColors.border,
            )),
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(text, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
          const SizedBox(height: AppDimensions.sm),
          Text('\u2014 $name', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─── 13. SIMILAR CRAFTS ────────────────────────────────────────────────────

  Widget _buildSimilarCrafts() {
    final similar = MockProducts.all.where((p) => p.id != _product.id).take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppDimensions.xxl, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
            child: Text('You May Also Like', style: AppTextStyles.titleMedium),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: 200,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              scrollDirection: Axis.horizontal,
              itemCount: similar.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.md),
              itemBuilder: (context, index) {
                final p = similar[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: p),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
                          child: Image.network(
                            p.imageUrl,
                            width: 150,
                            height: 110,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            cacheHeight: 220,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 150,
                                height: 110,
                                color: AppColors.warmBeige,
                                child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppDimensions.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name, style: AppTextStyles.labelMedium.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('\u20B9${p.price}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta, fontSize: 14)),
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
      ),
    );
  }

  // ─── 14. BOTTOM PURCHASE BAR ───────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.xl,
        AppDimensions.md,
        AppDimensions.xl,
        MediaQuery.of(context).padding.bottom + AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleWishlist,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(
                _isWished ? Icons.favorite : Icons.favorite_border,
                color: _isWished ? AppColors.terracotta : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: GestureDetector(
              onTap: _addToCart,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.brown),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Center(
                  child: Text('Add to Cart', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.brown)),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: GestureDetector(
              onTap: _buyNow,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Center(
                  child: Text('Buy Now', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 19. TRUST BADGES ──────────────────────────────────────────────────────

  Widget _buildTrustBadges() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.lg),
        decoration: BoxDecoration(
          color: AppColors.warmBeige.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _trustBadge(Icons.verified_outlined, 'Verified\nArtisan'),
            _trustBadge(Icons.lock_outline, 'Secure\nPayment'),
            _trustBadge(Icons.handyman_outlined, 'Handcrafted\nProduct'),
            _trustBadge(Icons.favorite_outline, 'Support\nCommunities'),
          ],
        ),
      ),
    );
  }

  Widget _trustBadge(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.brown),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 9, height: 1.3), textAlign: TextAlign.center),
      ],
    );
  }

  // ─── ACTIONS ───────────────────────────────────────────────────────────────

  void _toggleWishlist() {
    setState(() => _isWished = !_isWished);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWished ? 'Saved to wishlist' : 'Removed from wishlist'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
        backgroundColor: AppColors.charcoal,
      ),
    );
  }

  void _showShareSheet() {
    showModalBottomSheet(
      context: context,
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
                Text('Share this craft', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppDimensions.lg),
                _shareOption(Icons.chat_outlined, 'WhatsApp', () => Navigator.pop(ctx)),
                _shareOption(Icons.camera_alt_outlined, 'Instagram', () => Navigator.pop(ctx)),
                _shareOption(Icons.link, 'Copy Link', () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Link copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                      backgroundColor: AppColors.charcoal,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _shareOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.charcoal),
      title: Text(label, style: AppTextStyles.bodyMedium),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('Added to your cart'),
            const Spacer(),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.pushNamed(context, AppRoutes.cart);
              },
              child: Text('View Cart', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mustardGold)),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
        backgroundColor: AppColors.charcoal,
      ),
    );
  }

  void _buyNow() {
    Navigator.pushNamed(context, AppRoutes.checkout);
  }
}

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
}

class _Highlight {
  final String label;
  final IconData icon;
  const _Highlight(this.label, this.icon);
}
