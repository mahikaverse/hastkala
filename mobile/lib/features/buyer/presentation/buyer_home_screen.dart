import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/adaptive_product_image.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';
import '../../products/presentation/product_details_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _bannerIndex = 0;

  static const _bannerImages = [
    'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=600&h=400&fit=crop',
    'https://images.unsplash.com/photo-1612196808214-b8e1d6145a8c?w=600&h=400&fit=crop',
    'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=600&h=400&fit=crop',
  ];

  static const _categoryImages = [
    'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?w=150&h=150&fit=crop',
    'https://images.unsplash.com/photo-1583391733956-6c78276477e2?w=150&h=150&fit=crop',
    'https://images.unsplash.com/photo-1582561833406-b5cf8b6e381f?w=150&h=150&fit=crop',
    'https://images.unsplash.com/photo-1515562141589-67f0d89d5432?w=150&h=150&fit=crop',
    'https://images.unsplash.com/photo-1513519245088-0e12902e35ca?w=150&h=150&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/horizontal-logo.png',
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Text('HastKala', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.brown, fontWeight: FontWeight.w800));
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_outlined, color: AppColors.charcoal),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.location_on_outlined, color: AppColors.charcoal),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    _buildSearchSection(),
                    _buildAskHastKala(),
                    _buildHeroBanner(),
                    _buildExploreByCraft(),
                    _buildCuratedForYou(),
                    _buildCraftOfTheWeek(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildGreeting() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${lang.t('buyerNamaste')}Ananya', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.charcoal)),
          const SizedBox(height: 2),
          Text(lang.t('buyerSubtitle'), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.productListing),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: AppColors.borderLight),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text(
                        lang.t('buyerSearchHint'),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Icon(Icons.mic, color: AppColors.terracotta, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.warmBeige,
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Icon(Icons.tune, color: AppColors.terracotta, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAskHastKala() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.md, AppDimensions.lg, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.aiProductStudio),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.brown,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 16),
                  const SizedBox(width: 4),
                  Text(lang.t('buyerAskAi'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.cream)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: AppColors.cream, size: 16),
                ],
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_outlined, color: AppColors.terracotta, size: 16),
                  const SizedBox(width: 4),
                  Text(lang.t('buyerFindSpecial'), style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal, fontSize: 10, height: 1.2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppDimensions.xxl, 0, 0),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PageView.builder(
              itemCount: _bannerImages.length,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.warmBeige,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                      image: DecorationImage(
                        image: NetworkImage(_bannerImages[index]),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {},
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.brown.withValues(alpha: 0.85),
                            AppColors.brown.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.cream.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                            ),
                            child: Text(lang.t('buyerCollectionTag'), style: AppTextStyles.labelSmall.copyWith(color: AppColors.cream, fontSize: 9, letterSpacing: 1.2)),
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(lang.t('buyerCollectionHeadline'), style: AppTextStyles.headlineLarge.copyWith(color: AppColors.cream, height: 1.15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            lang.t('buyerCollectionDesc'),
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.85), height: 1.4),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.productListing),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
                              decoration: BoxDecoration(
                                color: AppColors.terracotta,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(lang.t('buyerViewCrafts'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.cream)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.chevron_right, color: AppColors.cream, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_bannerImages.length, (i) {
              return Container(
                width: i == _bannerIndex ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _bannerIndex ? AppColors.terracotta : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreByCraft() {
    final lang = LanguageProvider.of(context);
    final categories = [
      _CatItem(lang.t('buyerPottery'), _categoryImages[0]),
      _CatItem(lang.t('buyerTextiles'), _categoryImages[1]),
      _CatItem(lang.t('buyerWoodwork'), _categoryImages[2]),
      _CatItem(lang.t('buyerJewelry'), _categoryImages[3]),
      _CatItem(lang.t('buyerHomeDecor'), _categoryImages[4]),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppDimensions.xxl, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.t('buyerExploreByCraft'), style: AppTextStyles.titleMedium),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.productListing),
                  child: Row(
                    children: [
                      Text(lang.t('buyerSeeAll'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                      Icon(Icons.chevron_right, color: AppColors.terracotta, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.md),
              itemBuilder: (context, index) {
                final cat = categories[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.productListing),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.warmBeige, width: 3),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            cat.image,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            cacheWidth: 150,
                            cacheHeight: 150,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.warmBeige,
                              child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(cat.name, style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedForYou() {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppDimensions.xxl, 0, 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.t('buyerCuratedForYou'), style: AppTextStyles.titleMedium),
                    Text(lang.t('buyerCuratedDesc'), style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.productListing),
                  child: Row(
                    children: [
                      Text(lang.t('buyerAll'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                      Icon(Icons.chevron_right, color: AppColors.terracotta, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: 220,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.md),
              itemBuilder: (context, index) {
                final product = MockProducts.all[index];
                return _curatedCard(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _curatedCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
              child: AdaptiveProductImage(
                imageUrl: product.imageUrl,
                width: 160,
                height: 120,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: 160,
                  height: 120,
                  color: AppColors.warmBeige,
                  child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.labelMedium.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('\u20B9${product.price}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta, fontSize: 14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 10, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(product.location, style: AppTextStyles.caption.copyWith(fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCraftOfTheWeek() {
    final lang = LanguageProvider.of(context);
    final product = MockProducts.all[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.lg, AppDimensions.xxl, AppDimensions.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lang.t('buyerCraftOfTheWeek'), style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
                  child: Image.network(
                    product.imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    cacheWidth: 500,
                    cacheHeight: 250,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 160,
                      color: AppColors.warmBeige,
                      child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text('\u20B9${product.price}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.terracotta)),
                      const SizedBox(height: 4),
                      Text(product.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppDimensions.md),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
                          decoration: BoxDecoration(
                            color: AppColors.brown,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(lang.t('buyerViewCraft'), style: AppTextStyles.labelMedium.copyWith(color: AppColors.cream)),
                              const SizedBox(width: 4),
                              Icon(Icons.chevron_right, color: AppColors.cream, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return HastKalaBottomNavigation(
      currentIndex: 0,
      onTap: (i) {
        final routes = [
          null,
          AppRoutes.productListing,
          AppRoutes.cart,
          AppRoutes.orderTracking,
          AppRoutes.profile,
        ];
        if (routes[i] != null) {
          Navigator.pushNamed(context, routes[i]!);
        }
      },
      items: HastKalaNavItems.buyer(context),
    );
  }
}

class _CatItem {
  final String name;
  final String image;
  const _CatItem(this.name, this.image);
}
