import 'package:flutter/material.dart';

import '../../../core/models/user_role.dart';
import 'login_screen.dart';

/// Legacy entry point for role-specific auth screens.
/// Now wraps the unified real Supabase [LoginScreen] with [initialRole] preselected.
class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    return LoginScreen(initialRole: role);
  }
}
