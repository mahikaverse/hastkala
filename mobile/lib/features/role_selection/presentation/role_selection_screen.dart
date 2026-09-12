import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/models/user_role.dart';
import '../../../core/widgets/hast_kala_background.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  void _onContinue() {
    if (_selectedRole == null) return;
    Navigator.pushNamed(context, AppRoutes.signup, arguments: _selectedRole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HastKalaBackground(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppDimensions.xxxxl),

                    // Brand logo
                    Center(
                      child: Image.asset(
                        'assets/horizontal-logo.png',
                        height: 48,
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
                      'How will you use HastKala?',
                      style: AppTextStyles.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Choose your role to get started.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.xxl),

                    // Role cards
                    _RoleCard(
                      title: 'Artisan / Seller',
                      subtitle: 'Create and sell your handmade products.',
                      imagePath: 'assets/seller-enum-img.png',
                      isSelected: _selectedRole == UserRole.seller,
                      onTap: () => setState(() => _selectedRole = UserRole.seller),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    _RoleCard(
                      title: 'B2B Buyer',
                      subtitle: 'Source products in bulk from artisans.',
                      imagePath: 'assets/b2b-enum-img.png',
                      isSelected: _selectedRole == UserRole.b2bSeller,
                      onTap: () => setState(() => _selectedRole = UserRole.b2bSeller),
                    ),
                    const SizedBox(height: AppDimensions.md),

                    _RoleCard(
                      title: 'Individual Buyer',
                      subtitle: 'Discover and buy handmade products.',
                      imagePath: 'assets/buyer-enum-img.png',
                      isSelected: _selectedRole == UserRole.buyer,
                      onTap: () => setState(() => _selectedRole = UserRole.buyer),
                    ),
                    const SizedBox(height: AppDimensions.xxxl),
                  ],
                ),
              ),
            ),

            // Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.xxl,
                0,
                AppDimensions.xxl,
                AppDimensions.xxl,
              ),
              child: SizedBox(
                height: AppDimensions.buttonHeightLG,
                child: ElevatedButton(
                  onPressed: _selectedRole != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracotta,
                    foregroundColor: AppColors.textOnPrimary,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.textSecondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                    elevation: _selectedRole != null ? AppDimensions.elevationSM : 0,
                  ),
                  child: Text(
                    'Continue',
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: _selectedRole != null
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xl,
          vertical: AppDimensions.xl,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.terracotta.withAlpha(15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: isSelected ? AppColors.terracotta : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.terracotta.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            // Image or empty space
            if (imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                child: Image.asset(
                  imagePath!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                    ),
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.xl),
            ],

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isSelected ? AppColors.terracotta : AppColors.charcoal,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.terracotta : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.terracotta : AppColors.border,
                  width: 2.0,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
