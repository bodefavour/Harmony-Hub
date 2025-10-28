import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Design System inspired by Spotify & Apple Music  
/// Features: Glassmorphism, Smooth animations, Beautiful gradients

class AppTheme {
  // ============ COLOR PALETTE ============

  // Primary Brand Colors (Harmony Hub Orange)
  static const Color harmonyOrange = Color(0xFFFF5722); // Main brand color
  static const Color harmonyOrangeDark = Color(0xFFE64A19);
  static const Color harmonyOrangeLight = Color(0xFFFF7043);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF181818);
  static const Color darkCard = Color(0xFF282828);
  static const Color darkElevated = Color(0xFF333333);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFAFAFA);
  static const Color lightElevated = Color(0xFFEEEEEE);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF6A6A6A);

  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF6A6A6A);
  static const Color textTertiaryLight = Color(0xFFB3B3B3);

  // Accent Colors
  static const Color accentBlue = Color(0xFF2E77D0);
  static const Color accentPurple = Color(0xFF8E44AD);
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentOrange = Color(0xFFFF6B35);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ============ GRADIENTS ============

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [harmonyOrange, harmonyOrangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkCard],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF1DB954),
      Color(0xFF1ED760),
      Color(0xFF1FDF64),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x30FFFFFF),
      Color(0x10FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ SPACING ============
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // ============ BORDER RADIUS ============
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull = 999.0;

  // ============ SHADOWS ============
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: harmonyOrange.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  // ============ TEXT STYLES ============
  // Note: Using getters for simplicity in new components
  // Original context-based methods commented out - can be restored if needed

  /*
  static TextStyle displayLarge(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: isDark ? textPrimary : textPrimaryLight,
      letterSpacing: -0.5,
    );
  }

  static TextStyle displayMedium(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: isDark ? textPrimary : textPrimaryLight,
      letterSpacing: -0.5,
    );
  }

  static TextStyle displaySmall(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDark ? textPrimary : textPrimaryLight,
    );
  }

  static TextStyle headlineLarge(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: isDark ? textPrimary : textPrimaryLight,
    );
  }

  static TextStyle headlineMedium(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: isDark ? textPrimary : textPrimaryLight,
    );
  }

  static TextStyle bodyLarge(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: isDark ? textPrimary : textPrimaryLight,
    );
  }

  static TextStyle bodyMedium(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: isDark ? textSecondary : textSecondaryLight,
    );
  }

  static TextStyle bodySmall(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: isDark ? textTertiary : textTertiaryLight,
    );
  }

  static TextStyle caption(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.normal,
      color: isDark ? textTertiary : textTertiaryLight,
    );
  }

  static TextStyle button(BuildContext context, {bool isDark = true}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: isDark ? textPrimary : textPrimaryLight,
      letterSpacing: 0.5,
    );
  }
  */

  // ============ TEXT STYLE GETTERS (Simplified) ============

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // ============ THEME DATA ============

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: harmonyOrange,
      secondary: harmonyOrangeDark,
      surface: darkSurface,
      error: error,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: textPrimary,
    ),
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: harmonyOrange,
      secondary: harmonyOrangeDark,
      surface: lightSurface,
      error: error,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimaryLight,
      onError: textPrimary,
    ),
    cardTheme: CardTheme(
      color: lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimaryLight),
    ),
  );
}
