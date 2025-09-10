import 'package:flutter/material.dart';

class AppTheme {
  // Main colors extracted from the image
  static const Color primaryColor = Color(0xFF0B6E6A); // Dark teal from sidebar
  static const Color highlightColor =
      Color(0xFF0D5956); // Slightly darker for selected items
  static const Color secondaryColor =
      Color(0xFF41C7BD); // Lighter teal from icons
  static const Color accentColor = Color(0xFF1E88E5); // Blue accent for buttons
  static const Color backgroundLightColor =
      Color(0xFFF5F5F5); // Light background
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Colors.black;
  static const Color textSecondaryColor = Colors.white;

  // Spacing following 8px grid
  static const double spacing8 = 8.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;

  // Border radius
  static const double borderRadius8 = 8.0;
  static const double borderRadius16 = 16.0;

  // Create material theme
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: textSecondaryColor,
        secondary: secondaryColor,
        onSecondary: textSecondaryColor,
        error: Colors.red,
        onError: textSecondaryColor,
        surface: cardColor,
        onSurface: textPrimaryColor,
      ),
      // Text theme
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimaryColor,
        ),
      ),
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: textSecondaryColor,
          backgroundColor: accentColor,
          padding: const EdgeInsets.symmetric(
            horizontal: spacing16,
            vertical: spacing8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius8),
          ),
        ),
      ),
      // Card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius8),
        ),
        margin: const EdgeInsets.all(spacing8),
      ),
      // Icon theme
      iconTheme: const IconThemeData(
        color: primaryColor,
        size: 24,
      ),
      scaffoldBackgroundColor: backgroundLightColor,
    );
  }
}
