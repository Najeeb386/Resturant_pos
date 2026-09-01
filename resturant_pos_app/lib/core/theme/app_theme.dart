import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (Orange & White Branded)
  static const Color primaryDark = Color(0xFFFF6B00); // Brand Orange
  static const Color primaryDarkAccent = Color(0xFFE05E00);
  static const Color backgroundDark = Color(0xFFFDFDFD); // Warm White
  static const Color surfaceDark = Color(0xFFFFFFFF); // Pure White
  static const Color borderDark = Color(0xFFF4EBE4); // Light warm grey border
  
  static const Color accentTeal = Color(0xFF0D9488); // Teal
  static const Color accentAmber = Color(0xFFD97706); // Amber
  static const Color accentRose = Color(0xFFE11D48); // Rose / Red
  static const Color accentEmerald = Color(0xFF059669); // Emerald / Green

  // Light Mode Colors (Orange & White Restaurant Theme)
  static const Color primaryLight = Color(0xFFFF6B00); // Brand Orange
  static const Color backgroundLight = Color(0xFFFDFDFD); // Warm White
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFF4EBE4); // Light warm grey border

  static ThemeData get darkTheme {
    return lightTheme;
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: accentTeal,
        surface: surfaceLight,
        background: backgroundLight,
        error: accentRose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF0F172A), // Slate 900
        onBackground: Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: const Color(0xFF0F172A)),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16, color: const Color(0xFF0F172A)),
        bodyLarge: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF334155)), // Slate 700
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF64748B)), // Slate 500
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF0F172A),
          side: const BorderSide(color: borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF64748B)),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
      ),
    );
  }
}
