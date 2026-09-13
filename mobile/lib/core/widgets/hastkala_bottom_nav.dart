import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class HastKalaBottomNavItem {
  const HastKalaBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class HastKalaCenterButton {
  const HastKalaCenterButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class HastKalaBottomNavigation extends StatelessWidget {
  const HastKalaBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerButton,
    this.selectedNavIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<HastKalaBottomNavItem> items;
  final HastKalaCenterButton? centerButton;

  /// When set, this index is used for highlighting nav items instead of [currentIndex].
  /// Useful when a center button occupies a screen slot that doesn't correspond to any nav item.
  /// Pass -1 or null to deselect all nav items (e.g. when center button screen is active).
  final int? selectedNavIndex;

  bool get hasCenterButton => centerButton != null;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final centerOverhang = hasCenterButton ? 20.0 : 0.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8 + bottomPadding),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: EdgeInsets.only(top: centerOverhang),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildItems(),
            ),
          ),
          if (hasCenterButton) _buildFloatingCenterButton(),
        ],
      ),
    );
  }

  List<Widget> _buildItems() {
    if (!hasCenterButton) {
      return List.generate(items.length, (index) {
        return Expanded(child: _buildNavItem(index));
      });
    }

    final half = items.length ~/ 2;
    final leftItems = <Widget>[];
    for (var i = 0; i < half; i++) {
      leftItems.add(Expanded(child: _buildNavItem(i)));
    }

    final rightItems = <Widget>[];
    for (var i = half; i < items.length; i++) {
      rightItems.add(Expanded(child: _buildNavItem(i)));
    }

    return [
      ...leftItems,
      SizedBox(width: 72),
      ...rightItems,
    ];
  }

  Widget _buildNavItem(int index) {
    final effectiveIndex = selectedNavIndex ?? currentIndex;
    final isSelected = effectiveIndex == index;
    final item = items[index];

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(6),
            decoration: isSelected
                ? BoxDecoration(
                    color: AppColors.terracotta.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  )
                : null,
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 22,
              color: isSelected ? AppColors.terracotta : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.terracotta : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCenterButton() {
    final btn = centerButton!;
    return Positioned(
      top: -4,
      child: GestureDetector(
        onTap: btn.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.terracotta, AppColors.brown],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.terracotta.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(btn.icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              btn.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.terracotta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

abstract class HastKalaNavItems {
  static const artisan = [
    HastKalaBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    HastKalaBottomNavItem(
      icon: Icons.festival_outlined,
      activeIcon: Icons.festival_rounded,
      label: 'Schemes',
    ),
    HastKalaBottomNavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Market',
    ),
    HastKalaBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const artisanLegacy = [
    HastKalaBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    HastKalaBottomNavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Products',
    ),
    HastKalaBottomNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    HastKalaBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const b2b = [
    HastKalaBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    HastKalaBottomNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    HastKalaBottomNavItem(
      icon: Icons.forum_outlined,
      activeIcon: Icons.forum_rounded,
      label: 'Enquiries',
    ),
    HastKalaBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  static const buyer = [
    HastKalaBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    HastKalaBottomNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Explore',
    ),
    HastKalaBottomNavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      label: 'Cart',
    ),
    HastKalaBottomNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    HastKalaBottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];
}
