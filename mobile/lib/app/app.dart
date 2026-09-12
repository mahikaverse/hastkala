import 'package:flutter/material.dart';

import '../core/localization/language_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class HastKalaApp extends StatefulWidget {
  const HastKalaApp({super.key});

  @override
  State<HastKalaApp> createState() => _HastKalaAppState();
}

class _HastKalaAppState extends State<HastKalaApp> {
  final _langProvider = LanguageProvider();

  @override
  void dispose() {
    _langProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LanguageScope(
      provider: _langProvider,
      child: MaterialApp(
        title: 'HastKala',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
