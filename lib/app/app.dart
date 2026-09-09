import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

/// The root widget of the HastKala application.
///
/// Configures the MaterialApp with the design system theme,
/// centralized routing, and other global settings.
class HastKalaApp extends StatelessWidget {
  const HastKalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HastKala',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
