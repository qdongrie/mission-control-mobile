import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6366F1);      // Indigo
  static const Color success = Color(0xFF22C55E);      // Green
  static const Color warning = Color(0xFFF59E0B);      // Amber
  static const Color danger = Color(0xFFEF4444);        // Red
  static const Color dark = Color(0xFF1E293B);         // Slate 800
  static const Color light = Color(0xFFF8FAFC);        // Slate 50
  static const Color grey = Color(0xFF64748B);         // Slate 500

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: success,
        error: danger,
        surface: light,
      ),
      scaffoldBackgroundColor: light,
      appBarTheme: const AppBarTheme(
        backgroundColor: dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primary,
        unselectedItemColor: grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
