import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/app_intro_audio_service.dart';
import '../../../core/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with WidgetsBindingObserver {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = AppIntroAudioService();
      if (!audio.isPlaying) {
        audio.startIntroMusic();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audio = AppIntroAudioService();
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      audio.pause();
    } else if (state == AppLifecycleState.resumed) {
      audio.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await AppIntroAudioService().stopIntroMusic();
      if (!mounted) return;
      _navigateAfterOnboarding();
    }
  }

  void _navigateAfterOnboarding() {
    final auth = AuthService();
    if (auth.isLoggedIn) {
      final targetRoute = auth.getHomeRouteForRole();
      Navigator.pushReplacementNamed(context, targetRoute);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildScreenOne(context),
                  _buildScreenTwo(context),
                  _buildScreenThree(context),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenOne(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/onboarding1.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 160),
            // Main heading
            Text(
              "India's Crafts\nDeserve a Bigger Stage",
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.brown,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // Supporting text
            Text(
              "Discover, showcase, and sell\ntraditional crafts to the world.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenTwo(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/onboarding2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 160),
            Text(
              "Support Local Artisans",
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.brown,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Explore a curated collection of authentic crafts.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenThree(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/onboarding3.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 160),
            Text(
              "Start Your Journey",
              textAlign: TextAlign.center,
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.brown,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Join thousands of artisans and buyers\nbuilding India's craft economy.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.charcoal,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Three onboarding page indicators
          Row(
            children: List.generate(3, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: isActive ? 24 : 8,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.terracotta : AppColors.warmBeige,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          // Circular next button
          InkWell(
            onTap: _nextPage,
            borderRadius: BorderRadius.circular(26),
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: AppColors.terracotta,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
