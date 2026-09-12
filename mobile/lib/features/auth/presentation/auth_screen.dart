import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../core/models/user_role.dart';
import 'login_screen.dart';

/// Legacy entry point for role-specific auth screens.
/// Navigates to the signup flow with the given role preselected.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRoutes.signup, arguments: role);
    });
    return const LoginScreen();
  }
}
