import 'package:flutter/material.dart';

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
    return const AppScaffold(
      appBar: HastKalaAppBar(title: 'HastKala'),
      body: Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
