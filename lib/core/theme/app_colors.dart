// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary colors from Palette-02 (blues/teals)
  static const Color primaryDarkest = Color(0xFF023336); // Dark teal
  static const Color primaryDark = Color(0xFF0C6478); // Dark blue
  static const Color primaryMedium = Color(0xFF15919B); // Medium teal
  static const Color primaryLight = Color(0xFF09D1C7); // Bright teal
  static const Color primaryLightest = Color(0xFF46DFB1); // Light teal-green

  // Primary gradient (blue to teal)
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryDark, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary colors from first palette (greens)
  static const Color secondaryDark = Color(0xFF4DA674); // Medium green
  static const Color secondaryMedium = Color(0xFF80EE98); // Light green
  static const Color secondaryLight = Color(0xFFC1E6BA); // Very light green
  static const Color secondaryLightest = Color(0xFFEAF8E7); // Pale green

  // Secondary gradient (green)
  static const Gradient secondaryGradient = LinearGradient(
    colors: [secondaryDark, secondaryMedium],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background colors
  static const Color backgroundLight = Color(0xFFEAF8E7); // Pale green
  static const Color backgroundDark = Color(0xFF023336); // Dark teal

  // Background gradients
  static const Gradient lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFEAF8E7), Color(0xFFC1E6BA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF023336), Color(0xFF0C6478)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // UI elements
  static const Color scaffoldBackground = Color(0xFFEAF8E7); // Light background
  static const Color cardBackground = Colors.white; // Cards
  static const Color dividerColor = Color(0xFFC1E6BA); // Light green divider

  // Text colors
  static const Color textPrimary = Color(0xFF023336); // Dark teal
  static const Color textSecondary = Color(0xFF0C6478); // Dark blue
  static const Color textLight = Color(0xFFEAF8E7); // Light text for dark backgrounds
  static const Color textOnPrimary = Colors.white; // Text on primary colors
  static const Color textOnSecondary = Color(0xFF023336); // Text on secondary colors

  // Status colors
  static const Color success = Color(0xFF4DA674); // Green
  static const Color warning = Color(0xFFFFC107); // Amber
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color info = Color(0xFF1976D2); // Blue

  // Dark theme specific
  static const Color darkScaffoldBackground = Color(0xFF023336); // Dark teal
  static const Color darkCardBackground = Color(0xFF0C6478); // Dark blue
  static const Color darkDividerColor = Color(0xFF15919B); // Teal divider
}