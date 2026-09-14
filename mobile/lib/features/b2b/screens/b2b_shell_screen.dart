import 'package:flutter/material.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/widgets/hastkala_bottom_nav.dart';
import 'b2b_home_screen.dart';
import 'b2b_explore_screen.dart';
import 'b2b_requirements_screen.dart';
import 'b2b_enquiries_screen.dart';
import 'b2b_profile_screen.dart';

class B2BShellScreen extends StatefulWidget {
  const B2BShellScreen({super.key});

  @override
  State<B2BShellScreen> createState() => _B2BShellScreenState();
}

class _B2BShellScreenState extends State<B2BShellScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  late final List<Widget> _screens;

  // Screen indices
  static const int _screenHome = 0;
  static const int _screenExplore = 1;
  static const int _screenRequirements = 2;
  static const int _screenEnquiries = 3;
  static const int _screenProfile = 4;

  // Nav item indices → screen index mapping
  // Nav items: Home(0), Explore(1), Enquiries(2), Profile(3)
  static const List<int> _navToScreen = [
    _screenHome,
    _screenExplore,
    _screenEnquiries,
    _screenProfile,
  ];

  /// Returns the nav item index to highlight for a given screen index.
  /// Returns -1 when no nav item should be highlighted (e.g. center button screen).
  int _screenToNav(int screenIndex) {
    switch (screenIndex) {
      case _screenHome:
        return 0;
      case _screenExplore:
        return 1;
      case _screenEnquiries:
        return 2;
      case _screenProfile:
        return 3;
      default:
        return -1;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const B2BHomeScreen(),
      const B2BExploreScreen(),
      B2BRequirementsScreen(onBackToHome: () => _switchScreen(_screenHome)),
      const B2BEnquiriesScreen(),
      const B2BProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Switch to a screen by screen index.
  void _switchScreen(int screenIndex) {
    if (screenIndex == _currentIndex) return;
    setState(() {
      _currentIndex = screenIndex;
    });
    _pageController.jumpToPage(screenIndex);
  }

  /// Called when a nav item is tapped. [navIndex] is the nav item index (0-3).
  void _onNavTapped(int navIndex) {
    final screenIndex = _navToScreen[navIndex];
    _switchScreen(screenIndex);
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return PopScope(
      canPop: _currentIndex == _screenHome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != _screenHome) {
          _switchScreen(_screenHome);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: HastKalaBottomNavigation(
          currentIndex: _currentIndex,
          selectedNavIndex: _screenToNav(_currentIndex),
          onTap: _onNavTapped,
          items: HastKalaNavItems.b2b(context),
          centerButton: HastKalaCenterButton(
            icon: Icons.add_rounded,
            label: lang.t('postRequirement'),
            onTap: () => _switchScreen(_screenRequirements),
          ),
        ),
      ),
    );
  }
}
