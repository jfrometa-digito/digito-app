import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const _brandPrimary = Color(0xFF4317C0); // Digito Primary Purple
  // static const _brandSecondary = Color(0xFF10B981); // Emerald 500 - Unused for now

  // Semantic Colors - Light
  static const _lightSurface = Color(0xFFFFFFFF);
  static const _lightBackground = Color(0xFFF9FAFB); // Gray 50
  static const _lightText = Color(0xFF111827); // Gray 900
  static const _lightTextSecondary = Color(0xFF6B7280); // Gray 500
  static const _lightBorder = Color(0xFFE5E7EB); // Gray 200

  // Semantic Colors - Dark
  static const _darkSurface = Color(0xFF1F2937); // Gray 800
  static const _darkBackground = Color(0xFF111827); // Gray 900
  static const _darkText = Color(0xFFF9FAFB); // Gray 50
  static const _darkTextSecondary = Color(0xFF9CA3AF); // Gray 400
  static const _darkBorder = Color(0xFF374151); // Gray 700

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      primary: _brandPrimary,
      surface: _lightSurface,
      background: _lightBackground,
      text: _lightText,
      textSecondary: _lightTextSecondary,
      border: _lightBorder,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      primary: _brandPrimary,
      surface: _darkSurface,
      background: _darkBackground,
      text: _darkText,
      textSecondary: _darkTextSecondary,
      border: _darkBorder,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color primary,
    required Color surface,
    required Color background,
    required Color text,
    required Color textSecondary,
    required Color border,
  }) {
    final baseTextTheme = brightness == Brightness.light
        ? GoogleFonts.interTextTheme(ThemeData.light().textTheme)
        : GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        onPrimary: Colors.white,
        brightness: brightness,
        surface: surface,
        onSurface: text,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: GoogleFonts.inter(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: GoogleFonts.inter(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.inter(color: textSecondary, fontSize: 16),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: text),
      textTheme: baseTextTheme.apply(bodyColor: text, displayColor: text),
    );
  }
}
