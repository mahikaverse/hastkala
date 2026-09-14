import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(lang.t('navProfile'), style: AppTextStyles.headlineSmall.copyWith(color: AppColors.cream)),
        backgroundColor: AppColors.brown,
        foregroundColor: AppColors.cream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppDimensions.lg),
            _buildMenu(context),
            const SizedBox(height: AppDimensions.xxl),
            _buildLogout(context),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.xxl),
      color: AppColors.surface,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.warmBeige,
            child: Icon(Icons.person, size: 40, color: AppColors.brown),
          ),
          const SizedBox(height: AppDimensions.md),
          Text('Ananya Sharma', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {},
            child: Text('View Profile', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.terracotta)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final lang = LanguageProvider.of(context);
    final items = [
      _MenuItem(Icons.shopping_bag_outlined, lang.t('myOrders'), AppRoutes.orderTracking),
      _MenuItem(Icons.favorite_outline, lang.t('wishlist'), null),
      _MenuItem(Icons.location_on_outlined, lang.t('savedAddresses'), null),
      _MenuItem(Icons.payment_outlined, lang.t('paymentMethods'), null),
      _MenuItem(Icons.help_outline, lang.t('helpSupport'), null),
      _MenuItem(Icons.settings_outlined, lang.t('settings'), null),
      _MenuItem(Icons.info_outline, lang.t('aboutHastkala'), null),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon, color: AppColors.charcoal),
                title: Text(item.title, style: AppTextStyles.bodyMedium),
                trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
                onTap: () {
                  if (item.route != null) {
                    Navigator.pushNamed(context, item.route!);
                  }
                },
              ),
              if (i < items.length - 1) const Divider(height: 1, indent: 56),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(lang.t('logout'), style: AppTextStyles.titleMedium),
                content: Text(lang.t('logoutConfirm'), style: AppTextStyles.bodyMedium),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: Text(lang.t('cancel'), style: AppTextStyles.buttonMedium.copyWith(color: AppColors.textSecondary))),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                      }
                    },
                    child: Text(lang.t('logout'), style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
                  ),
                ],
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.terracotta),
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
          ),
          child: Text(lang.t('logout'), style: AppTextStyles.buttonMedium.copyWith(color: AppColors.terracotta)),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return HastKalaBottomNavigation(
      currentIndex: 4,
      onTap: (i) {
        final routes = [
          AppRoutes.buyerHome,
          AppRoutes.productListing,
          AppRoutes.cart,
          AppRoutes.orderTracking,
          null,
        ];
        if (routes[i] != null) {
          Navigator.pushNamed(context, routes[i]!);
        }
      },
      items: HastKalaNavItems.buyer(context),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? route;
  const _MenuItem(this.icon, this.title, this.route);
}
