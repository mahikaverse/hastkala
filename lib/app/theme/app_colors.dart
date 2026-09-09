import 'package:flutter/material.dart';

/// HastKala Design System - Color Palette
///
/// Colors inspired by Indian traditional aesthetics:
/// earthy browns, warm terracotta, rich gold, and natural greens.
abstract final class AppColors {
  // Primary Palette
  static const Color brown = Color(0xFF4A2518);
  static const Color terracotta = Color(0xFFB84E2F);
  static const Color mustardGold = Color(0xFFC88927);
  static const Color oliveGreen = Color(0xFF4F6530);

  // Neutral Palette
  static const Color cream = Color(0xFFF8F1E3);
  static const Color warmBeige = Color(0xFFE8D8BE);
  static const Color charcoal = Color(0xFF2D2722);

  // Extended Palette (derived from primary)
  static const Color brownLight = Color(0xFF6B3A26);
  static const Color brownDark = Color(0xFF331A0F);
  static const Color terracottaLight = Color(0xFFD4704F);
  static const Color terracottaDark = Color(0xFF8C3A20);
  static const Color mustardGoldLight = Color(0xFFD9A84F);
  static const Color mustardGoldDark = Color(0xFF9E6B1C);
  static const Color oliveGreenLight = Color(0xFF6B8548);
  static const Color oliveGreenDark = Color(0xFF3A4A24);

  // Surface & Background
  static const Color background = cream;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = warmBeige;

  // Text Colors
  static const Color textPrimary = charcoal;
  static const Color textSecondary = Color(0xFF5C4F45);
  static const Color textOnDark = cream;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color error = Color(0xFFB3261E);
  static const Color success = oliveGreen;
  static const Color warning = mustardGold;
  static const Color info = Color(0xFF4A6FA5);

  // Divider & Border
  static const Color divider = Color(0xFFD6C9BA);
  static const Color border = Color(0xFFC4B5A3);
  static const Color borderLight = Color(0xFFE0D5C8);
}
