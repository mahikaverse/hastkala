import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/hast_kala_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoginTab = true;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return HastKalaBackground(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            // Top Logo
            Padding(
              padding: const EdgeInsets.only(top: 45.0),
              child: Image.asset(
                'assets/horizontal-logo.png',
                width: 160,
              ),
            ),
            // Login / Sign Up Card
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: _buildCard(),
                ),
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
      padding: const EdgeInsets.all(24.0),
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
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isLoginTab = true),
            child: Container(
              color: Colors.transparent, // Ensures the whole area is tappable
              child: Column(
                children: [
                  Text(
                    'Login',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: _isLoginTab ? AppColors.terracotta : AppColors.charcoal,
                      fontWeight: _isLoginTab ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: _isLoginTab ? AppColors.terracotta : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isLoginTab = false),
            child: Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Text(
                    'Sign Up',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: !_isLoginTab ? AppColors.terracotta : AppColors.charcoal,
                      fontWeight: !_isLoginTab ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: !_isLoginTab ? AppColors.terracotta : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown),
        ),
        const SizedBox(height: 4),
        Text(
          'Login to continue to HastKala',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
        ),
        const SizedBox(height: 24),
        _buildTextField('Email / Mobile Number'),
        const SizedBox(height: 16),
        _buildTextField('Password', isPassword: true),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.terracotta),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Login', () {
          // Navigate to Role Selection (if it existed) or Home
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }),
        const SizedBox(height: 24),
        _buildDivider(),
        const SizedBox(height: 24),
        _buildOutlinedButton('Continue with Google', Icons.g_mobiledata),
        const SizedBox(height: 12),
        _buildOutlinedButton('Continue with Mobile', Icons.phone_android),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isLoginTab = false),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                children: const [
                  TextSpan(text: 'New to HastKala? '),
                  TextSpan(
                    text: 'Create an account',
                    style: TextStyle(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSignUpForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Create Your Account',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.brown),
        ),
        const SizedBox(height: 24),
        _buildTextField('Name'),
        const SizedBox(height: 16),
        _buildTextField('Email / Mobile Number'),
        const SizedBox(height: 16),
        _buildTextField('Password', isPassword: true),
        const SizedBox(height: 16),
        _buildTextField(
          'Confirm Password',
          isPassword: true,
          isConfirmPassword: true,
        ),
        const SizedBox(height: 24),
        _buildPrimaryButton('Create Account', () {}),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isLoginTab = true),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
                children: const [
                  TextSpan(text: 'Already have an account? '),
                  TextSpan(
                    text: 'Login',
                    style: TextStyle(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTextField(
    String label, {
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    bool obscure = false;
    if (isPassword) {
      obscure = isConfirmPassword ? !_isConfirmPasswordVisible : !_isPasswordVisible;
    }

    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
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

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.terracotta,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildOutlinedButton(String text, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: AppColors.charcoal, size: 22),
      label: Text(
        text,
        style: AppTextStyles.buttonMedium.copyWith(color: AppColors.charcoal),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDivider() {
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
}
