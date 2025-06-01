import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // --- Light Theme ---
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primaryMedium,
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    cardColor: AppColors.cardBackground,
    dividerColor: AppColors.dividerColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    colorScheme: ColorScheme.light(
      primary: AppColors.primaryMedium,
      primaryContainer: AppColors.primaryDark,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.secondaryMedium,
      secondaryContainer: AppColors.secondaryDark,
      onSecondary: AppColors.textOnSecondary,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.backgroundLight,
      // replaced deprecated background
      surfaceTint: AppColors.primaryLight.withAlpha(30),
      onSurface: AppColors.textPrimary,
    ),

    // App bar theme with gradient
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1.0,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
      titleTextStyle: const TextStyle(
        color: AppColors.textOnPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textOnPrimary,
      ),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      labelSmall: TextStyle(
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    ),

    // Button themes with gradients
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textOnPrimary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          return Colors.transparent;
        }),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(
          AppColors.primaryLight.withValues(alpha: (0.2 * 255).toDouble()),
        ),
        foregroundColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryMedium,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryMedium,
        side: const BorderSide(color: AppColors.primaryMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: (0.8 * 255).toDouble()),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.secondaryLight.withValues(
            alpha: (0.5 * 255).toDouble(),
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.secondaryLight.withValues(
            alpha: (0.5 * 255).toDouble(),
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.primaryMedium,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(
          alpha: (0.7 * 255).toDouble(),
        ),
      ),
    ),

    // Floating action button with gradient
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4.0,
      shape: const CircleBorder(),
    ),

    // Card Theme
    cardTheme: const CardThemeData(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
    ),

    // Dialog Theme
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      backgroundColor: AppColors.cardBackground,
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryDark,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white.withValues(
        alpha: (0.6 * 255).toDouble(),
      ),
    ),
  );

  // --- Dark Theme ---
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    primaryColorLight: AppColors.primaryLightest,
    primaryColorDark: AppColors.primaryMedium,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    cardColor: AppColors.darkCardBackground,
    dividerColor: AppColors.darkDividerColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primaryMedium,
      onPrimary: AppColors.textLight,
      secondary: AppColors.secondaryMedium,
      secondaryContainer: AppColors.secondaryDark,
      onSecondary: AppColors.textLight,
      error: AppColors.error,
      onError: Colors.black,
      surface: AppColors.darkScaffoldBackground,
      // replaced deprecated background
      surfaceTint: AppColors.primaryLight.withAlpha(30),
      onSurface: AppColors.textLight,
    ),

    // App bar theme with gradient
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: AppColors.textLight),
      titleTextStyle: const TextStyle(
        color: AppColors.textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textLight,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textLight),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textLight),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textLight,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.textLight,
      ),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textLight),
      labelSmall: TextStyle(
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textLight,
      ),
    ),

    // Button themes with gradients
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.textOnPrimary,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.disabled)) {
            return Colors.grey;
          }
          return Colors.transparent;
        }),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.all(
          AppColors.primaryLight.withValues(alpha: (0.2 * 255).toDouble()),
        ),
        foregroundColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: const BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCardBackground.withValues(
        alpha: (0.5 * 255).toDouble(),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryMedium.withValues(
            alpha: (0.5 * 255).toDouble(),
          ),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryMedium.withValues(
            alpha: (0.5 * 255).toDouble(),
          ),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0),
      ),
      labelStyle: TextStyle(
        color: AppColors.textLight.withValues(alpha: (0.8 * 255).toDouble()),
      ),
      hintStyle: TextStyle(
        color: AppColors.textLight.withValues(alpha: (0.6 * 255).toDouble()),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 4.0,
      shape: const CircleBorder(),
    ),

    cardTheme: const CardThemeData(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.darkCardBackground,
      surfaceTintColor: Colors.transparent,
    ),

    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      backgroundColor: AppColors.darkCardBackground,
    ),

    // Bottom navigation bar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.primaryDarkest,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.primaryLight.withValues(
        alpha: (0.6 * 255).toDouble(),
      ),
    ),
  );
}
