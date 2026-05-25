import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CorporateTheme {
  // Brand Colors (Material Design 3 Palette)
  static const Color background = Color(0xFFF7F9FB); // Slate Gray Base
  static const Color primary = Color(0xFF051125);    // Dark Navy
  static const Color primaryContainer = Color(0xFF1B263B); // Deep Navy Blue
  static const Color onPrimaryContainer = Color(0xFF828DA7);

  // Status & Semantic Colors
  static const Color success = Color(0xFF2C694E);    // Normal Workload (Green)
  static const Color successContainer = Color(0xFFaeeecb);
  static const Color onSuccessContainer = Color(0xFF316e52);

  static const Color warning = Color(0xFFD57401);    // High Workload (Orange)
  static const Color warningContainer = Color(0xFFffdcc3);
  static const Color onWarningContainer = Color(0xFF6e3900);

  static const Color error = Color(0xFFBA1A1A);      // Critical Risk (Red)
  static const Color errorContainer = Color(0xFFffdad6);
  static const Color onErrorContainer = Color(0xFF93000a);

  // Neutral Grays / Borders
  static const Color surface = Color(0xFFFFFFFF);     // Pure White Cards
  static const Color outlineVariant = Color(0xFFC5C6CD); // Border Slate-200
  static const Color outline = Color(0xFF75777D);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF45474D); // Secondary Text
  static const Color surfaceContainerLow = Color(0xFFF2F4F6); // Hover state

  // Font Family: Inter Text Theme Configuration
  static TextTheme buildTextTheme(TextTheme base) {
    return TextTheme(
      // Headline Large (24px, Bold, -0.02em letterSpacing)
      headlineLarge: GoogleFonts.inter(
        textStyle: base.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.02 * 24,
          color: primary,
        ),
      ),
      // Headline Medium (20px, Semi-Bold, -0.01em)
      headlineMedium: GoogleFonts.inter(
        textStyle: base.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01 * 20,
          color: primary,
        ),
      ),
      // Headline Small (18px, Semi-Bold)
      headlineSmall: GoogleFonts.inter(
        textStyle: base.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
      // Body Large (16px, Regular)
      bodyLarge: GoogleFonts.inter(
        textStyle: base.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: onSurface,
        ),
      ),
      // Body Medium (14px, Regular) - Main workhorse text
      bodyMedium: GoogleFonts.inter(
        textStyle: base.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: onSurface,
        ),
      ),
      // Label Caps (12px, Bold, 0.05em spacing, UPPERCASE handled at widget level)
      labelLarge: GoogleFonts.inter(
        textStyle: base.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.05 * 12,
          color: onSurfaceVariant,
        ),
      ),
    );
  }

  // Data Display Style (32px, Bold, -0.03em letterSpacing)
  static TextStyle dataDisplay({Color color = primary}) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.03 * 32,
      color: color,
    );
  }

  // Main Light Theme Definition
  static ThemeData get lightTheme {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.light(
        primary: primary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: success,
        secondaryContainer: successContainer,
        onSecondaryContainer: onSuccessContainer,
        error: error,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      textTheme: buildTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: primary),
        titleTextStyle: TextStyle(
          color: primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          borderRadius: BorderRadius.circular(8), // 0.5rem (8px) shapes
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.05 * 12,
          color: onSurfaceVariant,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainer,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48), // 48px height tap-target
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
