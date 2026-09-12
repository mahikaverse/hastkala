import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../core/services/app_intro_audio_service.dart';
import '../../../core/widgets/hast_kala_background.dart';

/// Splash screen for the HastKala application.
///
/// Displays the brand logo with a tagline and subtle
/// decorative motifs. Checks persistent auth session and navigates.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.cream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    AppIntroAudioService().startIntroMusic();

    _navigationTimer = Timer(const Duration(milliseconds: 2200), () {
      _checkAuthAndNavigate();
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

  void _checkAuthAndNavigate() {
    if (!mounted) return;
    AppIntroAudioService().stopIntroMusic();
    Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HastKalaBackground(
      child: Stack(
        children: [
          // Centered content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BrandLogo(),
                    SizedBox(height: AppDimensions.xxl),
                    _Tagline(),
                  ],
                ),
              ),
            ),
          ),

          // Loading indicator at bottom
          const Positioned(
            bottom: AppDimensions.xxxl,
            left: 0,
            right: 0,
            child: Center(child: _LoadingIndicator()),
          ),
        ],
      ),
    );
  }
}

/// The main brand logo displayed as an image.
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/logo.png',
      width: 180,
      height: 180,
      fit: BoxFit.contain,
    );
  }
}

/// Tagline displayed below the brand logo.
class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Bringing Indian Craft to Every Market',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
        height: 1.5,
      ),
    );
  }
}

/// Subtle loading indicator using the brand palette.
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppColors.terracotta.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}


