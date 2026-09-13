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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const B2BHomeScreen(),
      const B2BExploreScreen(),
      B2BRequirementsScreen(onBackToHome: () => _onTabTapped(0)),
      const B2BEnquiriesScreen(),
      const B2BProfileScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          _onTabTapped(0);
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
          onTap: _onTabTapped,
          items: HastKalaNavItems.b2b,
          centerButton: HastKalaCenterButton(
            icon: Icons.add_rounded,
            label: lang.t('postRequirement'),
            onTap: () => _onTabTapped(2),
          ),
        ),
      ),
    );
  }
}
