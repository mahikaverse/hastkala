import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/product_model.dart';
import '../../../core/widgets/app_bottom_nav.dart';

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
              _buildArtisanStatus(),
              _buildAIHero(context),
              _buildAIQuickActions(context),
              _buildBusinessSnapshot(),
              _buildMarketOpportunity(context),
              _buildYourProducts(context),
              _buildRecentOrders(context),
              _buildAIAssistant(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ─── 1. HEADER ─────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.lg, AppDimensions.xl, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Namaste, Sita Devi \u{1F44B}', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 2),
                Text("Let's grow your craft business.", style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined, color: AppColors.charcoal, size: 22),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.artisanProfile),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.warmBeige,
              child: Icon(Icons.person, color: AppColors.brown, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. ARTISAN STATUS ─────────────────────────────────────────────────────

  Widget _buildArtisanStatus() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.md, AppDimensions.xl, 0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: AppColors.oliveGreen, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.sm),
          Text('Artisan Profile Active', style: AppTextStyles.labelMedium.copyWith(color: AppColors.oliveGreen)),
          const SizedBox(width: AppDimensions.md),
          Icon(Icons.verified, size: 14, color: AppColors.oliveGreen),
          const SizedBox(width: 4),
          Text('Verified Artisan', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ─── 3. PRIMARY AI HERO ────────────────────────────────────────────────────

  Widget _buildAIHero(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.artisanAddProduct),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.xl),
          decoration: BoxDecoration(
            color: AppColors.brown,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 20),
                  const SizedBox(width: AppDimensions.sm),
                  Text('AI-Powered', style: AppTextStyles.labelMedium.copyWith(color: AppColors.mustardGold)),
                ],
              ),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Turn Your Craft Into a\nMarket-Ready Product',
                style: AppTextStyles.headlineLarge.copyWith(color: AppColors.cream, height: 1.2),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Just show us your craft. HastKala AI helps create\nthe listing, suggest a price and find the right market.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.cream.withValues(alpha: 0.7), height: 1.5),
              ),
              const SizedBox(height: AppDimensions.xl),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppColors.cream, size: 20),
                    const SizedBox(width: AppDimensions.sm),
                    Text('Add Product with AI', style: AppTextStyles.buttonMedium.copyWith(color: AppColors.cream)),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              // AI Workflow Visual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _workflowStep(Icons.camera_alt_outlined, 'Photo'),
                    _workflowDot(),
                    _workflowStep(Icons.auto_awesome, 'AI Catalog'),
                    _workflowDot(),
                    _workflowStep(Icons.attach_money, 'Smart Price'),
                    _workflowDot(),
                    _workflowStep(Icons.public, 'Market'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workflowStep(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.cream.withValues(alpha: 0.8), size: 18),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.cream.withValues(alpha: 0.7), fontSize: 9)),
      ],
    );
  }

  Widget _workflowDot() {
    return Icon(Icons.chevron_right, color: AppColors.cream.withValues(alpha: 0.3), size: 14);
  }

  // ─── 4. AI QUICK ACTIONS ───────────────────────────────────────────────────

  Widget _buildAIQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.lg, AppDimensions.xl, 0),
      child: Row(
        children: [
          Expanded(
            child: _quickActionCard(
              context: context,
              icon: Icons.edit_outlined,
              title: 'Create Listing',
              subtitle: 'Turn photo + voice into a catalog',
              route: AppRoutes.artisanAddProduct,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _quickActionCard(
              context: context,
              icon: Icons.attach_money,
              title: 'Smart Pricing',
              subtitle: 'Know what your craft is worth',
              route: AppRoutes.aiPricing,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: _quickActionCard(
              context: context,
              icon: Icons.public,
              title: 'Find Markets',
              subtitle: 'Discover better buyers',
              route: AppRoutes.marketLinkage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.terracotta, size: 22),
            const SizedBox(height: AppDimensions.sm),
            Text(title, style: AppTextStyles.labelMedium.copyWith(color: AppColors.charcoal)),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 10, height: 1.3)),
          ],
        ),
      ),
    );
  }

  // ─── 5. BUSINESS SNAPSHOT ──────────────────────────────────────────────────

  Widget _buildBusinessSnapshot() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Business', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppDimensions.md),
          Container(
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
                _compactStat('12', 'Products'),
                _statDivider(),
                _compactStat('356', 'Views'),
                _statDivider(),
                _compactStat('48', 'Orders'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.brown)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.borderLight,
    );
  }

  // ─── 6. MARKET OPPORTUNITY ─────────────────────────────────────────────────

  Widget _buildMarketOpportunity(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Container(
        width: double.infinity,
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
                Text('Market Opportunity', style: AppTextStyles.titleMedium),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.mustardGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, size: 10, color: AppColors.mustardGold),
                      const SizedBox(width: 3),
                      Text('AI Insight', style: AppTextStyles.labelSmall.copyWith(color: AppColors.mustardGold, fontSize: 9)),
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
                color: AppColors.warmBeige.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
              ),
              child: Text(
                'Terracotta home d\u00E9cor is seeing high demand among urban buyers.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.brown, height: 1.5),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                _marketIndicator('Demand', 'HIGH', AppColors.terracotta),
                const SizedBox(width: AppDimensions.md),
                _marketIndicator('Competition', 'MEDIUM', AppColors.mustardGold),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            _marketIndicator('Potential Market', 'Home Decor Buyers', AppColors.oliveGreen),
            const SizedBox(height: AppDimensions.lg),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.marketLinkage),
              child: Row(
                children: [
                  Text('Find Better Markets', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
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

  Widget _marketIndicator(String label, String value, Color color) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyles.bodySmall),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          ),
          child: Text(value, style: AppTextStyles.labelSmall.copyWith(color: color, fontSize: 10)),
        ),
      ],
    );
  }

  // ─── 7. YOUR PRODUCTS ──────────────────────────────────────────────────────

  Widget _buildYourProducts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppDimensions.xxl, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your Products', style: AppTextStyles.titleMedium),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.manageProducts),
                  child: Row(
                    children: [
                      Text('View All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                      Icon(Icons.chevron_right, size: 16, color: AppColors.terracotta),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl),
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.md),
              itemBuilder: (context, index) {
                final product = MockProducts.all[index];
                final isDraft = index == 1;
                return _productCard(context, product, isDraft);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, Product product, bool isDraft) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.manageProducts),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMD)),
                  child: Image.network(
                    product.imageUrl,
                    width: 160,
                    height: 90,
                    fit: BoxFit.cover,
                    cacheWidth: 320,
                    cacheHeight: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 90,
                        color: AppColors.warmBeige,
                        child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDraft ? AppColors.mustardGold : AppColors.oliveGreen,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      isDraft ? 'Draft' : 'Published',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.cream, fontSize: 9),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: AppTextStyles.labelMedium.copyWith(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('\u20B9${product.price}', style: AppTextStyles.titleSmall.copyWith(color: AppColors.terracotta, fontSize: 13)),
                  if (isDraft) ...[
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: 0.7,
                                  backgroundColor: AppColors.warmBeige,
                                  valueColor: AlwaysStoppedAnimation(AppColors.terracotta),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('70%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary, fontSize: 9)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Complete Listing', style: AppTextStyles.labelSmall.copyWith(color: AppColors.terracotta, fontSize: 9)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 8. RECENT ORDERS ──────────────────────────────────────────────────────

  Widget _buildRecentOrders(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: AppTextStyles.titleMedium),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.artisanOrders),
                child: Row(
                  children: [
                    Text('View All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.terracotta),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          _orderCard('#HK12568', MockProducts.all[0], 1, 'Packed', AppColors.mustardGold),
          const SizedBox(height: AppDimensions.sm),
          _orderCard('#HK12572', MockProducts.all[1], 2, 'Shipped', AppColors.oliveGreen),
        ],
      ),
    );
  }

  Widget _orderCard(String id, Product product, int qty, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.borderLight),
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 44,
                  height: 44,
                  color: AppColors.warmBeige,
                  child: Icon(Icons.shopping_bag_outlined, color: AppColors.brown, size: 20),
                );
              },
            ),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                Text(product.name, style: AppTextStyles.titleSmall),
                Text('\u20B9${product.price} \u00D7 $qty', style: AppTextStyles.bodySmall.copyWith(color: AppColors.terracotta)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            ),
            child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: statusColor, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // ─── 9. AI BUSINESS ASSISTANT ──────────────────────────────────────────────

  Widget _buildAIAssistant(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.xl, AppDimensions.xxl, AppDimensions.xl, 0),
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
                Icon(Icons.auto_awesome, color: AppColors.mustardGold, size: 18),
                const SizedBox(width: AppDimensions.sm),
                Text('Ask HastKala', style: AppTextStyles.titleMedium.copyWith(color: AppColors.brown)),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Need help growing your craft business?',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.md),
            Wrap(
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: [
                _assistantChip('Improve My Listing', AppRoutes.smartCatalog, context),
                _assistantChip('Suggest a Price', AppRoutes.aiPricing, context),
                _assistantChip('Find Buyers', AppRoutes.marketLinkage, context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _assistantChip(String label, String route, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.charcoal)),
      ),
    );
  }

  // ─── 10. BOTTOM NAV ────────────────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return AppBottomNav(
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
      items: AppBottomNavItems.artisan,
    );
  }
}
