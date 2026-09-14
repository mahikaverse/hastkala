import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/localization/language_provider.dart';

/// A single bottom navigation item.
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
}

/// A unified, design-system-aware bottom navigation bar.
///
/// Provides consistent styling across all user roles (Artisan, B2B, Buyer).
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.terracotta,
          unselectedItemColor: AppColors.textSecondary,
          selectedFontSize: 10,
          unselectedFontSize: 9,
          selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.terracotta,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          items: items
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon, size: 22),
                  activeIcon: Icon(item.activeIcon, size: 22),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Pre-defined navigation items for each user role.
abstract class AppBottomNavItems {
  static List<AppBottomNavItem> artisan(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return [
      AppBottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: lang.t('navHome'),
        route: '/artisan/home',
      ),
      AppBottomNavItem(
        icon: Icons.inventory_2_outlined,
        activeIcon: Icons.inventory_2,
        label: lang.t('navProducts'),
        route: '/artisan/products',
      ),
      AppBottomNavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: lang.t('navAddProduct'),
        route: '/artisan/add-product',
      ),
      AppBottomNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: lang.t('navOrders'),
        route: '/artisan/orders',
      ),
      AppBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: lang.t('navProfile'),
        route: '/artisan/profile',
      ),
    ];
  }

  static List<AppBottomNavItem> b2b(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return [
      AppBottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: lang.t('navHome'),
        route: '/b2b/home',
      ),
      AppBottomNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: lang.t('navExplore'),
        route: '/b2b/explore',
      ),
      AppBottomNavItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: lang.t('postRequirement'),
        route: '/b2b/requirements',
      ),
      AppBottomNavItem(
        icon: Icons.forum_outlined,
        activeIcon: Icons.forum,
        label: lang.t('navEnquiries'),
        route: '/b2b/enquiries',
      ),
      AppBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: lang.t('navProfile'),
        route: '/b2b/profile',
      ),
    ];
  }

  static List<AppBottomNavItem> buyer(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return [
      AppBottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: lang.t('navHome'),
        route: '/buyer/home',
      ),
      AppBottomNavItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: lang.t('navExplore'),
        route: '/buyer/explore',
      ),
      AppBottomNavItem(
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: lang.t('navCart'),
        route: '/buyer/cart',
      ),
      AppBottomNavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: lang.t('navOrders'),
        route: '/buyer/orders',
      ),
      AppBottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: lang.t('navProfile'),
        route: '/buyer/profile',
      ),
    ];
  }
}
