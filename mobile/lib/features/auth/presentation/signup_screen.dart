import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/hast_kala_background.dart';

class SignupScreen extends StatefulWidget {
  final UserRole role;

  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  String? _errorMessage;

  UserRole get _role => widget.role;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return LanguageProvider.of(context).t('nameRequired');
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return LanguageProvider.of(context).t('emailRequired');
    final email = v.trim();
    if (!email.contains('@') || !email.contains('.')) {
      return LanguageProvider.of(context).t('validEmail');
    }
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return LanguageProvider.of(context).t('phoneRequired');
    final phone = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(phone)) {
      return LanguageProvider.of(context).t('validPhone');
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return LanguageProvider.of(context).t('passwordRequired');
    if (v.length < 6) return LanguageProvider.of(context).t('passwordMin');
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return LanguageProvider.of(context).t('confirmPasswordRequired');
    if (v != _passwordController.text) return LanguageProvider.of(context).t('passwordsNoMatch');
    return null;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      final role = result.role ?? _role;
      final targetRoute = AuthService().getHomeRouteForRole(role);
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage =
            result.errorMessage ?? LanguageProvider.of(context).t('registrationFailed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final lang = LanguageProvider.of(context);

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
                    AppDimensions.xxl,
                    AppDimensions.xxl,
                    bottomPadding + AppDimensions.xxl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppDimensions.xl),

                        // Brand
                        Center(
                          child: Image.asset(
                            'assets/horizontal-logo.png',
                            height: 44,
                            errorBuilder: (_, __, ___) => Text(
                              'HastKala',
                              style: AppTextStyles.headlineLarge.copyWith(
                                color: AppColors.terracotta,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xxxl),

                        // Title
                        Text(
                          lang.t('createAccount'),
                          style: AppTextStyles.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.sm),

                        // Role badge
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.md,
                              vertical: AppDimensions.xs + 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta.withAlpha(12),
                              borderRadius:
                                  BorderRadius.circular(AppDimensions.radiusFull),
                              border: Border.all(
                                color: AppColors.terracotta.withAlpha(40),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _roleIcon,
                                  size: 14,
                                  color: AppColors.terracotta,
                                ),
                                const SizedBox(width: AppDimensions.xs),
                                Text(
                                  _role.displayName,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.terracotta,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.xxl),

                        // Form card
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.xxl),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusLG),
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

                              // Full Name
                              _AuthField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                label: lang.t('fullName'),
                                hint: lang.t('enterFullName'),
                                icon: Icons.person_outline_rounded,
                                textInputAction: TextInputAction.next,
                                validator: _validateName,
                                onSubmitted: (_) =>
                                    _emailFocus.requestFocus(),
                              ),
                              const SizedBox(height: AppDimensions.md),

                              // Email
                              _AuthField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: lang.t('emailAddress'),
                                hint: lang.t('emailHint'),
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: _validateEmail,
                                onSubmitted: (_) =>
                                    _phoneFocus.requestFocus(),
                              ),
                              const SizedBox(height: AppDimensions.md),

                              // Phone
                              _AuthField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                label: lang.t('phoneNumber'),
                                hint: lang.t('phoneHint'),
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: _validatePhone,
                                onSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                              ),
                              const SizedBox(height: AppDimensions.md),

                              // Password
                              _AuthField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                label: lang.t('password'),
                                hint: lang.t('minChars'),
                                icon: Icons.lock_outline_rounded,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.next,
                                validator: _validatePassword,
                                onSubmitted: (_) =>
                                    _confirmFocus.requestFocus(),
                                suffix: GestureDetector(
                                  onTap: () => setState(
                                      () => _isPasswordVisible = !_isPasswordVisible),
                                  child: Icon(
                                    _isPasswordVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.md),

                              // Confirm Password
                              _AuthField(
                                controller: _confirmController,
                                focusNode: _confirmFocus,
                                label: lang.t('confirmPassword'),
                                hint: lang.t('reEnterPassword'),
                                icon: Icons.lock_outline_rounded,
                                obscureText: !_isConfirmVisible,
                                textInputAction: TextInputAction.done,
                                validator: _validateConfirm,
                                onSubmitted: (_) => _handleSignup(),
                                suffix: GestureDetector(
                                  onTap: () => setState(
                                      () => _isConfirmVisible = !_isConfirmVisible),
                                  child: Icon(
                                    _isConfirmVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                    color: AppColors.textSecondary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.xxl),

                              // Create Account button
                              _AuthButton(
                                label: lang.t('createAccountBtn'),
                                isLoading: _isLoading,
                                onPressed: _handleSignup,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                        lang.t('alreadyHaveAccount'),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        ),
                        child: Text(
                          lang.t('login'),
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

  IconData get _roleIcon {
    switch (_role) {
      case UserRole.seller:
        return Icons.palette_outlined;
      case UserRole.b2bSeller:
        return Icons.business_outlined;
      case UserRole.buyer:
        return Icons.shopping_bag_outlined;
    }
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
  final String? Function(String?)? validator;
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
    this.validator,
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
      validator: validator,
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
