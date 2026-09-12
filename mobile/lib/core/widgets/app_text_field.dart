import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';

/// A reusable, design-system-aware text field.
///
/// Provides consistent styling with the HastKala design system,
/// supporting labels, hints, validation, and optional icons.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: AppDimensions.iconMD, color: AppColors.textSecondary)
            : null,
        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixIconTap,
                child: Icon(suffixIcon, size: AppDimensions.iconMD, color: AppColors.textSecondary),
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLG,
          vertical: AppDimensions.paddingMD,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(color: AppColors.terracotta),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.charcoal),
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      autofocus: autofocus,
      textCapitalization: textCapitalization,
    );
  }
}
