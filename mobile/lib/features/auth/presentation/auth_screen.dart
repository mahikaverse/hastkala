import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/user_role.dart';
import '../../../core/widgets/hast_kala_background.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoginTab = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();
  final _signupCraftController = TextEditingController();
  final _signupLocationController = TextEditingController();

  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();
  final _signupNameFocus = FocusNode();
  final _signupEmailFocus = FocusNode();
  final _signupPasswordFocus = FocusNode();
  final _signupConfirmFocus = FocusNode();

  String? _loginEmailError;
  String? _loginPasswordError;
  String? _signupNameError;
  String? _signupEmailError;
  String? _signupPasswordError;
  String? _signupConfirmError;

  bool get _isSeller => widget.role == UserRole.seller;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    _signupCraftController.dispose();
    _signupLocationController.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();
    _signupNameFocus.dispose();
    _signupEmailFocus.dispose();
    _signupPasswordFocus.dispose();
    _signupConfirmFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HastKalaBackground(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Image.asset(
                'assets/horizontal-logo.png',
                width: 140,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'HastKala',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: (_isSeller ? AppColors.terracotta : AppColors.oliveGreen).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSeller ? Icons.store_outlined : Icons.shopping_bag_outlined,
                    size: 12,
                    color: _isSeller ? AppColors.terracotta : AppColors.oliveGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isSeller ? 'SELLER / ARTISAN' : 'BUYER / CUSTOMER',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _isSeller ? AppColors.terracotta : AppColors.oliveGreen,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: _buildCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(),
          const SizedBox(height: 24),
          if (_isLoginTab) _buildLoginForm() else _buildSignUpForm(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(child: _tab('Login', _isLoginTab, () => setState(() => _isLoginTab = true))),
        Expanded(child: _tab('Sign Up', !_isLoginTab, () => setState(() => _isLoginTab = false))),
      ],
    );
  }

  Widget _tab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.titleMedium.copyWith(
              color: isActive ? AppColors.terracotta : AppColors.charcoal,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 2, color: isActive ? AppColors.terracotta : Colors.transparent),
        ],
      ),
    );
  }

  // ─── LOGIN ─────────────────────────────────────────────────────────────────

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isSeller ? 'Welcome, Artisan' : 'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown),
        ),
        const SizedBox(height: 4),
        Text(
          _isSeller ? 'Login to manage your craft business' : 'Login to continue to HastKala',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
        ),
        const SizedBox(height: 24),
        _field(
          controller: _loginEmailController,
          focusNode: _loginEmailFocus,
          label: 'Mobile Number / Email',
          error: _loginEmailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _loginPasswordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _field(
          controller: _loginPasswordController,
          focusNode: _loginPasswordFocus,
          label: 'Password',
          error: _loginPasswordError,
          isPassword: true,
          obscure: !_isPasswordVisible,
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _login(),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Text('Forgot Password?', style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta)),
          ),
        ),
        const SizedBox(height: 24),
        _primaryButton(_isSeller ? 'Login as Artisan' : 'Login', _login),
        const SizedBox(height: 24),
        _divider(),
        const SizedBox(height: 24),
        _outlinedButton('Continue with Google', Icons.g_mobiledata),
        const SizedBox(height: 12),
        _outlinedButton('Continue with Mobile', Icons.phone_android),
        const SizedBox(height: 24),
        _switchAuthPrompt(
          _isSeller ? 'New artisan? ' : 'New to HastKala? ',
          'Create an account',
          () => setState(() => _isLoginTab = false),
        ),
        if (_isSeller) ...[
          const SizedBox(height: 24),
          _artisanInfo(),
        ],
      ],
    );
  }

  // ─── SIGN UP ───────────────────────────────────────────────────────────────

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isSeller ? 'Start Selling Your Craft' : 'Create Your Account',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown),
        ),
        const SizedBox(height: 4),
        if (_isSeller)
          Text(
            'Join HastKala and reach craft lovers worldwide.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
          ),
        const SizedBox(height: 24),
        _field(
          controller: _signupNameController,
          focusNode: _signupNameFocus,
          label: 'Full Name',
          error: _signupNameError,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _signupEmailFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _field(
          controller: _signupEmailController,
          focusNode: _signupEmailFocus,
          label: 'Email / Mobile Number',
          error: _signupEmailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _signupPasswordFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _field(
          controller: _signupPasswordController,
          focusNode: _signupPasswordFocus,
          label: 'Password',
          error: _signupPasswordError,
          isPassword: true,
          obscure: !_isPasswordVisible,
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _signupConfirmFocus.requestFocus(),
        ),
        const SizedBox(height: 16),
        _field(
          controller: _signupConfirmController,
          focusNode: _signupConfirmFocus,
          label: 'Confirm Password',
          error: _signupConfirmError,
          isPassword: true,
          obscure: !_isConfirmPasswordVisible,
          onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signUp(),
        ),
        if (_isSeller) ...[
          const SizedBox(height: 16),
          _field(
            controller: _signupCraftController,
            label: 'Craft / Speciality',
            hint: 'Pottery, Textiles, Woodwork...',
          ),
          const SizedBox(height: 16),
          _field(
            controller: _signupLocationController,
            label: 'Location',
            hint: 'City, State',
          ),
        ],
        const SizedBox(height: 24),
        _primaryButton(_isSeller ? 'Create Seller Account' : 'Create Account', _signUp),
        const SizedBox(height: 24),
        _switchAuthPrompt(
          'Already have an account? ',
          'Login',
          () => setState(() => _isLoginTab = true),
        ),
        if (_isSeller) ...[
          const SizedBox(height: 24),
          _artisanInfo(),
        ],
      ],
    );
  }

  // ─── WIDGETS ───────────────────────────────────────────────────────────────

  Widget _field({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    String? hint,
    String? error,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            errorText: error,
            errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.terracotta),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _primaryButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: AppColors.cream,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: Text(text, style: AppTextStyles.buttonLarge.copyWith(color: AppColors.cream)),
    );
  }

  Widget _outlinedButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: AppColors.charcoal, size: 22),
      label: Text(text, style: AppTextStyles.buttonMedium.copyWith(color: AppColors.charcoal)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('or', style: AppTextStyles.bodySmall),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }

  Widget _switchAuthPrompt(String prefix, String action, VoidCallback onTap) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: RichText(
          text: TextSpan(
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
            children: [
              TextSpan(text: prefix),
              TextSpan(
                text: action,
                style: const TextStyle(color: AppColors.terracotta, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _artisanInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.warmBeige.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your craft deserves a bigger market.',
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.brown),
          ),
          const SizedBox(height: 4),
          Text(
            'HastKala helps artisans create professional listings, discover buyers and grow their business.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ─── VALIDATION & NAVIGATION ───────────────────────────────────────────────

  void _login() {
    setState(() {
      _loginEmailError = null;
      _loginPasswordError = null;
    });

    bool valid = true;

    if (_loginEmailController.text.trim().isEmpty) {
      _loginEmailError = 'Please enter your mobile number or email';
      valid = false;
    }

    if (_loginPasswordController.text.isEmpty) {
      _loginPasswordError = 'Please enter your password';
      valid = false;
    } else if (_loginPasswordController.text.length < 6) {
      _loginPasswordError = 'Password must be at least 6 characters';
      valid = false;
    }

    if (!valid) {
      setState(() {});
      return;
    }

    final homeRoute = _isSeller ? AppRoutes.artisanDashboard : AppRoutes.buyerHome;
    Navigator.pushReplacementNamed(context, homeRoute);
  }

  void _signUp() {
    setState(() {
      _signupNameError = null;
      _signupEmailError = null;
      _signupPasswordError = null;
      _signupConfirmError = null;
    });

    bool valid = true;

    if (_signupNameController.text.trim().isEmpty) {
      _signupNameError = 'Please enter your name';
      valid = false;
    }

    if (_signupEmailController.text.trim().isEmpty) {
      _signupEmailError = 'Please enter your email or mobile number';
      valid = false;
    }

    if (_signupPasswordController.text.isEmpty) {
      _signupPasswordError = 'Please enter a password';
      valid = false;
    } else if (_signupPasswordController.text.length < 6) {
      _signupPasswordError = 'Password must be at least 6 characters';
      valid = false;
    }

    if (_signupConfirmController.text != _signupPasswordController.text) {
      _signupConfirmError = 'Passwords do not match';
      valid = false;
    }

    if (!valid) {
      setState(() {});
      return;
    }

    final homeRoute = _isSeller ? AppRoutes.artisanDashboard : AppRoutes.buyerHome;
    Navigator.pushReplacementNamed(context, homeRoute);
  }
}
