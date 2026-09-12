import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/hast_kala_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      _emailFocus.requestFocus();
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      _passwordFocus.requestFocus();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService().login(email: email, password: password);

    if (!mounted) return;

    if (result.isSuccess) {
      final role = result.role ?? AuthService().userRole;
      final targetRoute = AuthService().getHomeRouteForRole(role);
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage ?? 'Login failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: HastKalaBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppDimensions.xxl,
                    AppDimensions.xxxl,
                    AppDimensions.xxl,
                    bottomPadding + AppDimensions.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppDimensions.xl),

                      // Brand
                      Center(
                        child: Image.asset(
                          'assets/horizontal-logo.png',
                          height: 52,
                          errorBuilder: (_, __, ___) => Text(
                            'HastKala',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.terracotta,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Center(
                        child: Text(
                          'Direct Bridge for Artisans & Handloom',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xxxxl),

                      // Welcome section
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.xs),
                      Text(
                        'Sign in to your account',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppDimensions.xxl),

                      // Form card
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.xxl),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.charcoal.withAlpha(12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Error banner
                            if (_errorMessage != null) ...[
                              _ErrorBanner(message: _errorMessage!),
                              const SizedBox(height: AppDimensions.lg),
                            ],

                            // Email
                            _AuthField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              label: 'Email address',
                              hint: 'you@example.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) => _passwordFocus.requestFocus(),
                            ),
                            const SizedBox(height: AppDimensions.lg),

                            // Password
                            _AuthField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              label: 'Password',
                              hint: 'Enter your password',
                              icon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleLogin(),
                              suffix: GestureDetector(
                                onTap: () =>
                                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                                child: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.xxxl),

                            // Login button
                            _AuthButton(
                              label: 'Login',
                              isLoading: _isLoading,
                              onPressed: _handleLogin,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom link
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.roleSelection),
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable widgets ────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
        border: Border.all(color: AppColors.error.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const _AuthField({
    required this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.only(right: AppDimensions.sm),
                child: suffix,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(maxWidth: 40, maxHeight: 40),
        filled: true,
        fillColor: AppColors.cream.withAlpha(80),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.border.withAlpha(120)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.border.withAlpha(120)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: BorderSide(color: AppColors.error.withAlpha(150)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary.withAlpha(120),
        ),
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColors.error,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.terracotta.withAlpha(100),
          disabledForegroundColor: AppColors.textOnPrimary.withAlpha(180),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 3,
          shadowColor: AppColors.terracotta.withAlpha(60),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.textOnPrimary,
                ),
              )
            : Text(
                label,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}
