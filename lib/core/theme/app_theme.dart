import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // Color System Palette (Mockup & Specification):
  // Primary Blue: #1D4ED8
  static const Color primary = Color(0xFF1D4ED8);
  static const Color primaryBlue = Color(0xFF1D4ED8);
  static const Color primaryButton = Color(0xFF1D4ED8);
  static const Color iconActive = Color(0xFF1D4ED8);

  // Secondary Blue: #3B82F6
  static const Color secondary = Color(0xFF3B82F6);
  static const Color secondaryBlue = Color(0xFF3B82F6);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color progressBar = Color(0xFF3B82F6);

  // Tertiary Soft Blue: #EFF6FF
  static const Color tertiary = Color(0xFFEFF6FF);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color secondaryButton = Color(0xFFEFF6FF);
  static const Color onSecondaryButton = Color(0xFF1D4ED8);

  // Neutral: #64748B
  static const Color neutral = Color(0xFF64748B);
  static const Color bodyText = Color(0xFF64748B);
  static const Color onSurfaceVariant = Color(0xFF64748B);
  static const Color iconInactive = Color(0xFF94A3B8);

  // Dark & Headings: #0F172A
  static const Color text = Color(0xFF0F172A);
  static const Color heading = Color(0xFF0F172A);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color darkButton = Color(0xFF0F172A);

  // Background: #FFFFFF & #F8FAFC
  static const Color background = Color(0xFFFFFFFF);
  static const Color appBackground = Color(0xFFFFFFFF);

  // Surface & Card: #FFFFFF
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);

  // Border & Dividers
  static const Color outline = Color(0xFFE2E8F0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Gradient Container
  static const Color primaryContainer = Color(0xFF1D4ED8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: appBackground,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryContainer,
        secondary: secondary,
        onSecondary: onSecondaryButton,
        surface: surface,
        onSurface: heading,
        onSurfaceVariant: bodyText,
        outline: outline,
        error: error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: heading,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: heading,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: heading,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: heading,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: bodyText,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: iconInactive,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: heading),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: heading,
        ),
      ),
    );
  }
}
