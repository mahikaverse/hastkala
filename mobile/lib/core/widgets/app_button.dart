import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// Variants of the AppButton.
enum AppButtonVariant { filled, outlined, text }

/// A reusable, design-system-aware button.
///
/// Supports filled, outlined, and text variants with consistent
/// sizing and theming across the application.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.isEnabled = true,
    this.height,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isEnabled;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;

  bool get _isEffectiveEnabled => isEnabled && !isLoading && onPressed != null;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? AppDimensions.buttonHeightMD;
    final effectiveOnPressed = _isEffectiveEnabled ? onPressed : null;

    switch (variant) {
      case AppButtonVariant.filled:
        return _buildFilledButton(context, effectiveHeight, effectiveOnPressed);
      case AppButtonVariant.outlined:
        return _buildOutlinedButton(context, effectiveHeight, effectiveOnPressed);
      case AppButtonVariant.text:
        return _buildTextButton(context, effectiveHeight, effectiveOnPressed);
    }
  }

  Widget _buildFilledButton(
    BuildContext context,
    double effectiveHeight,
    VoidCallback? effectiveOnPressed,
  ) {
    return SizedBox(
      height: effectiveHeight,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: effectiveOnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.terracotta,
          foregroundColor: foregroundColor ?? AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.warmBeige,
          disabledForegroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          elevation: AppDimensions.elevationXS,
        ),
        child: _buildChild(
          color: foregroundColor ?? AppColors.textOnPrimary,
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    BuildContext context,
    double effectiveHeight,
    VoidCallback? effectiveOnPressed,
  ) {
    return SizedBox(
      height: effectiveHeight,
      width: width ?? double.infinity,
      child: OutlinedButton(
        onPressed: effectiveOnPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.terracotta,
          disabledForegroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
          side: BorderSide(
            color: _isEffectiveEnabled
                ? (foregroundColor ?? AppColors.terracotta)
                : AppColors.border,
            width: AppDimensions.borderWidth,
          ),
        ),
        child: _buildChild(
          color: foregroundColor ?? AppColors.terracotta,
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }

  Widget _buildTextButton(
    BuildContext context,
    double effectiveHeight,
    VoidCallback? effectiveOnPressed,
  ) {
    return SizedBox(
      height: effectiveHeight,
      width: width,
      child: TextButton(
        onPressed: effectiveOnPressed,
        style: TextButton.styleFrom(
          foregroundColor: foregroundColor ?? AppColors.terracotta,
          disabledForegroundColor: AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingLG,
            vertical: AppDimensions.paddingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          ),
        ),
        child: _buildChild(
          color: foregroundColor ?? AppColors.terracotta,
          style: AppTextStyles.buttonMedium,
        ),
      ),
    );
  }

  Widget _buildChild({required Color color, required TextStyle style}) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconSM),
          const SizedBox(width: AppDimensions.sm),
          Text(label, style: style.copyWith(color: color)),
        ],
      );
    }

    return Text(label, style: style.copyWith(color: color));
  }
}
