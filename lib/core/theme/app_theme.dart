import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF00579D);
  static const Color primaryLight = Color(0xFF4A9BEA);
  static const Color primaryDark = Color(0xFF003A6D);

  // Secondary / accent
  static const Color accent = Color(
    0xFFFFA000,
  ); // This will be our secondary color

  // Backgrounds
  static const Color background = Color(0xFFF5F5F5);
  static const Color scaffoldBackground =
      Colors.white; // Or AppColors.background if they are the same
  static const Color cardBackground = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary =
      Colors.white; // Text color on primary background
  static const Color textOnAccent =
      Colors.black; // Text color on accent background (example)

  // Error
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFE57373); // Lighter error for dark theme

  // Dark Theme Specific Colors (Optional, but can be useful for consistency)
  static const Color darkScaffoldBackground = Color(0xFF303030);
  static const Color darkBackground = Color(
    0xFF212121,
  ); // A bit darker than scaffold
  static const Color darkCardBackground = Color(0xFF424242);
  static const Color textOnDark = Colors.white;
  static const Color textSecondaryOnDark = Colors.white70;
}

class AppTheme {
  AppTheme._(); // Private constructor

  // --- Light Theme ---
  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    // Still useful for some older widgets or direct access
    primaryColorLight: AppColors.primaryLight,
    primaryColorDark: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    // backgroundColor: AppColors.background, // Use colorScheme.background
    cardColor: AppColors.cardBackground,
    // Use colorScheme.surface
    // errorColor: AppColors.error,             // Use colorScheme.error
    visualDensity: VisualDensity.adaptivePlatformDensity,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      // Text on accent surfaces
      error: AppColors.error,
      onError: Colors.white,
      // Text on error surfaces
      surface: AppColors.background,
      onSurface: AppColors.textPrimary,
      surfaceTint: AppColors.primary.withAlpha(13),
      surfaceContainerLow: AppColors.cardBackground,
    ),

    // App bar theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 1.0, // Added for subtle depth
      backgroundColor: AppColors.primary, // Will be overridden by colorScheme.primary below
      iconTheme: const IconThemeData(color: AppColors.textOnPrimary), // Will be overridden by colorScheme.onPrimary
      titleTextStyle: const TextStyle(
        color: AppColors.textOnPrimary, // Will be overridden by colorScheme.onPrimary
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ).copyWith(
      backgroundColor: AppColors.primary, // Explicitly using AppColors for now, or use scheme
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
      // Often used for AppBar titles if not overridden
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      // For ListTiles
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      // Color will be set by button themes
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      labelSmall: TextStyle(
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textSecondary,
      ),
    ),

    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        // Replaces primary
        foregroundColor: AppColors.textOnPrimary,
        // Replaces onPrimary
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary, // Replaces primary
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        // Replaces primary
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    // Input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background.withAlpha(100), // Made slightly more opaque
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      enabledBorder: OutlineInputBorder(
        // Default border when enabled
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2.0), // Uses AppColors.primary
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.0), // Uses AppColors.error
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2.0), // Uses AppColors.error
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),

    // Floating action button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent, // Will use colorScheme.secondary
      foregroundColor: AppColors.textOnAccent, // Will use colorScheme.onSecondary
      elevation: 4.0,
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color:
          AppColors
              .cardBackground, // Explicitly set, though colorScheme.surface is default
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.cardBackground,
    ),
  );

  // --- Dark Theme ---
  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primaryLight,
    // Use a lighter primary for dark mode contrast
    // scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    // cardColor: AppColors.darkCardBackground,
    visualDensity: VisualDensity.adaptivePlatformDensity,

    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      // Lighter primary for dark theme
      onPrimary: AppColors.textOnPrimary,
      // Or Colors.black if primaryLight is very light
      secondary: AppColors.accent,
      onSecondary: AppColors.textOnAccent,
      error: AppColors.errorDark, // Using the new lighter error color
      onError: Colors.black, // Text on lighter error surfaces (e.g., on errorDark background)
      surface: AppColors.darkScaffoldBackground,
      // Defined in AppColors
      onSurface: AppColors.textOnDark,
      surfaceTint: AppColors.primaryLight.withAlpha(13),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkScaffoldBackground,
      // Or colorScheme.background or colorScheme.surface
      iconTheme: const IconThemeData(color: AppColors.textOnDark),
      titleTextStyle: const TextStyle(
        color: AppColors.textOnDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ).copyWith(
      backgroundColor: AppColors.darkScaffoldBackground, // Explicitly using AppColors for now, or use scheme
      iconTheme: const IconThemeData(color: AppColors.textOnDark),
      titleTextStyle: const TextStyle(
        color: AppColors.textOnDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnDark,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnDark,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnDark,
      ),
      headlineLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textOnDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.textOnDark),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondaryOnDark),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textOnDark,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondaryOnDark,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.textSecondaryOnDark),
      labelSmall: TextStyle(
        fontSize: 10,
        letterSpacing: 0.5,
        color: AppColors.textSecondaryOnDark,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        // Using the dark theme's primary
        foregroundColor: AppColors.textOnPrimary,
        // Assuming textOnPrimary still works well
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryLight,
        side: BorderSide(color: AppColors.primaryLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCardBackground.withAlpha(100), // Made slightly more opaque
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 2.0), // Uses AppColors.primaryLight
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.errorDark, // Using the new AppColors.errorDark
          width: 1.0,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.errorDark, // Using the new AppColors.errorDark
          width: 2.0,
        ),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondaryOnDark),
      hintStyle: const TextStyle(color: AppColors.textSecondaryOnDark),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.textOnAccent,
      elevation: 4.0,
    ),
    cardTheme: CardTheme(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppColors.darkCardBackground,
    ),
    dialogTheme: DialogTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.darkCardBackground,
    ),
  );
}
