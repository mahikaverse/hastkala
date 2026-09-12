import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_nav.dart';
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

  final List<Widget> _screens = [
    const B2BHomeScreen(),
    const B2BExploreScreen(),
    const B2BRequirementsScreen(),
    const B2BEnquiriesScreen(),
    const B2BProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
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
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: AppBottomNavItems.b2b,
      ),
    );
  }
}
