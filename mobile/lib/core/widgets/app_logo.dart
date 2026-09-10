import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

/// The HastKala logo widget.
///
/// Displays the brand logo as an image that can be used
/// in app bars, headers, and authentication screens.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = AppLogoSize.medium,
    this.showTagline = false,
  });

  final AppLogoSize size;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/horizontal-logo.png',
          height: _getImageHeight(),
          fit: BoxFit.contain,
        ),
        if (showTagline) ...[
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Handcrafted with tradition',
            style: TextStyle(
              fontSize: _getTaglineFontSize(),
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ],
    );
  }

  double _getImageHeight() {
    switch (size) {
      case AppLogoSize.small:
        return 24.0;
      case AppLogoSize.medium:
        return 36.0;
      case AppLogoSize.large:
        return 48.0;
    }
  }

  double _getTaglineFontSize() {
    switch (size) {
      case AppLogoSize.small:
        return 10.0;
      case AppLogoSize.medium:
        return 12.0;
      case AppLogoSize.large:
        return 14.0;
    }
  }
}

/// Available sizes for the AppLogo.
enum AppLogoSize { small, medium, large }
