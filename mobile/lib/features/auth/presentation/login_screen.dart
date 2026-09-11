import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/user_role.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/hast_kala_background.dart';

class LoginScreen extends StatefulWidget {
  final UserRole? initialRole;
  final bool initialIsLoginTab;

  const LoginScreen({
    super.key,
    this.initialRole,
    this.initialIsLoginTab = true,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _isLoginTab;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Selected role for registration
  late UserRole _selectedRole;

  // Text controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();
  final _signupCraftController = TextEditingController();
  final _signupBusinessController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isLoginTab = widget.initialIsLoginTab;
    _selectedRole = widget.initialRole ?? UserRole.seller;
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    _signupCraftController.dispose();
    _signupBusinessController.dispose();
    super.dispose();
  }

  // ─── LOGIN HANDLER ────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
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

  // ─── SIGN UP / CREATE ACCOUNT HANDLER ─────────────────────────────────────
  Future<void> _handleSignUp() async {
    final name = _signupNameController.text.trim();
    final email = _signupEmailController.text.trim();
    final password = _signupPasswordController.text;
    final confirm = _signupConfirmController.text;

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters long');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService().register(
      name: name,
      email: email,
      password: password,
      role: _selectedRole,
      craft: _selectedRole == UserRole.seller ? _signupCraftController.text.trim() : null,
      businessName: _selectedRole == UserRole.b2bSeller ? _signupBusinessController.text.trim() : null,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      final role = result.role ?? _selectedRole;
      final targetRoute = AuthService().getHomeRouteForRole(role);
      Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = result.errorMessage ?? 'Registration failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HastKalaBackground(
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Brand Header Logo
              Center(
                child: Image.asset(
                  'assets/horizontal-logo.png',
                  width: 150,
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
              const SizedBox(height: 4),
              Text(
                'Direct Bridge for Artisans & Handloom',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Main Form Card
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: _buildCard(),
                  ),
                ),
              ),
            ],
          ),
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
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTabs(),
          const SizedBox(height: 20),
          if (_errorMessage != null) ...[
            _buildErrorBanner(_errorMessage!),
            const SizedBox(height: 16),
          ],
          if (_isLoginTab) _buildLoginForm() else _buildSignUpForm(),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isLoginTab = true;
                _errorMessage = null;
              });
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    'Login',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: _isLoginTab ? AppColors.terracotta : AppColors.charcoal,
                      fontWeight: _isLoginTab ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    decoration: BoxDecoration(
                      color: _isLoginTab ? AppColors.terracotta : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isLoginTab = false;
                _errorMessage = null;
              });
            },
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    'Create Account',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: !_isLoginTab ? AppColors.terracotta : AppColors.charcoal,
                      fontWeight: !_isLoginTab ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3,
                    decoration: BoxDecoration(
                      color: !_isLoginTab ? AppColors.terracotta : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGIN FORM ───────────────────────────────────────────────────────────
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.brown,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to access your dashboard and products',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _loginEmailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _loginPasswordController,
          label: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          text: 'Login',
          isLoading: _isLoading,
          onPressed: _handleLogin,
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isLoginTab = false;
                _errorMessage = null;
              });
            },
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                children: const [
                  TextSpan(text: "Don't have an account? "),
                  TextSpan(
                    text: 'Create Account',
                    style: TextStyle(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── SIGN UP FORM ─────────────────────────────────────────────────────────
  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Your Account',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.brown,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Join HastKala to connect directly with India’s craft world',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),

        // ─── ROLE SELECTOR (Artisan, B2B Seller, Buyer) ───────────────────
        Text(
          'I am a / मैं हूँ:',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.brown,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        _buildRoleOptions(),
        const SizedBox(height: 20),

        _buildTextField(
          controller: _signupNameController,
          label: 'Full Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _signupEmailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        if (_selectedRole == UserRole.seller) ...[
          _buildTextField(
            controller: _signupCraftController,
            label: 'Craft Specialization (e.g. Pottery, Handloom)',
            icon: Icons.brush_outlined,
          ),
          const SizedBox(height: 14),
        ],
        if (_selectedRole == UserRole.b2bSeller) ...[
          _buildTextField(
            controller: _signupBusinessController,
            label: 'Enterprise / Business Name',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 14),
        ],
        _buildTextField(
          controller: _signupPasswordController,
          label: 'Password (min 6 characters)',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _signupConfirmController,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          isPassword: true,
          isConfirmPassword: true,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton(
          text: 'Create Account',
          isLoading: _isLoading,
          onPressed: _handleSignUp,
        ),
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () {
              if (_isLoading) return;
              setState(() {
                _isLoginTab = true;
                _errorMessage = null;
              });
            },
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                children: const [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── ROLE CARDS ───────────────────────────────────────────────────────────
  Widget _buildRoleOptions() {
    return Column(
      children: [
        _roleCardTile(
          role: UserRole.seller,
          title: 'Artisan / Maker (कारीगर)',
          subtitle: 'Create smart catalogs & sell handmade crafts',
          icon: Icons.palette_outlined,
        ),
        const SizedBox(height: 8),
        _roleCardTile(
          role: UserRole.b2bSeller,
          title: 'B2B Wholesale Seller (थोक विक्रेता)',
          subtitle: 'Bulk orders, wholesale catalogs & B2B contracts',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 8),
        _roleCardTile(
          role: UserRole.buyer,
          title: 'Buyer / Customer (खरीदार)',
          subtitle: 'Explore authentic Indian crafts directly from makers',
          icon: Icons.shopping_bag_outlined,
        ),
      ],
    );
  }

  Widget _roleCardTile({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        setState(() => _selectedRole = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.terracotta.withValues(alpha: 0.06) : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.terracotta : AppColors.warmBeige,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.cream : AppColors.brown,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isSelected ? AppColors.terracotta : AppColors.brown,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.terracotta : AppColors.borderLight,
                  width: 2,
                ),
                color: isSelected ? AppColors.terracotta : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: AppColors.cream)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ─── TEXT FIELD COMPONENT ─────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    bool obscure = false;
    if (isPassword) {
      obscure = isConfirmPassword ? !_isConfirmPasswordVisible : !_isPasswordVisible;
    }

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirmPassword) {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    } else {
                      _isPasswordVisible = !_isPasswordVisible;
                    }
                  });
                },
              )
            : null,
      ),
    );
  }

  // ─── PRIMARY ACTION BUTTON ────────────────────────────────────────────────
  Widget _buildPrimaryButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          disabledBackgroundColor: AppColors.terracotta.withValues(alpha: 0.6),
          foregroundColor: AppColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.cream),
                ),
              )
            : Text(
                text,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.cream,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
