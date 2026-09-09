import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/user_role.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 48),
                _buildTitle(),
                const SizedBox(height: 40),
                _buildRoleCards(),
                const SizedBox(height: 40),
                _buildContinueButton(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/horizontal-logo.png',
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'HastKala',
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.brown,
              fontWeight: FontWeight.w800,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'I am a',
          style: AppTextStyles.displaySmall.copyWith(
            color: AppColors.brown,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose how you want to use HastKala',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildRoleCards() {
    return Column(
      children: [
        _roleCard(
          role: UserRole.seller,
          title: 'Seller / Artisan',
          subtitle: 'Sell your handmade products\nand grow your craft business.',
          icon: Icons.palette_outlined,
          selectedColor: AppColors.terracotta,
        ),
        const SizedBox(height: AppDimensions.lg),
        _roleCard(
          role: UserRole.buyer,
          title: 'Buyer / Customer',
          subtitle: 'Discover and shop unique\nhandmade Indian crafts.',
          icon: Icons.shopping_bag_outlined,
          selectedColor: AppColors.terracotta,
        ),
      ],
    );
  }

  Widget _roleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color selectedColor,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.xl),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(
            color: isSelected ? selectedColor : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? selectedColor.withValues(alpha: 0.1) : AppColors.warmBeige,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected ? selectedColor : AppColors.brown,
              ),
            ),
            const SizedBox(width: AppDimensions.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.brown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selectedColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 16, color: AppColors.cream),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final isEnabled = _selectedRole != null;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                final route = _selectedRole == UserRole.seller
                    ? AppRoutes.sellerAuth
                    : AppRoutes.buyerAuth;
                Navigator.pushNamed(context, route, arguments: _selectedRole);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.terracotta,
          disabledBackgroundColor: AppColors.warmBeige,
          foregroundColor: AppColors.cream,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: AppTextStyles.buttonLarge.copyWith(
            color: isEnabled ? AppColors.cream : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
