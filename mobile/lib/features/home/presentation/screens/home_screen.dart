import 'package:flutter/material.dart';

import '../../../../core/localization/language_provider.dart';
import '../../../../core/widgets/app_scaffold.dart';

/// Placeholder home screen.
///
/// This screen will be implemented as the main dashboard
/// when the home feature is developed. For now, it serves
/// as the initial route to verify routing works correctly.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageProvider.of(context);
    return AppScaffold(
      appBar: HastKalaAppBar(title: lang.t('appName')),
      body: Center(
        child: Text(lang.t('homeScreen')),
      ),
    );
  }
}
