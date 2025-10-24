import 'package:flutter/material.dart';

class AppTheme {
  // 🌞 Aydınlık Tema
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F7),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6750A4),
      secondary: Color(0xFF8E7CC3),
      tertiary: Color(0xFFB39DDB),
      surface: Colors.white,
      onSurface: Colors.black87,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // 🌙 Karanlık Tema
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E0E10),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8A80F9),       // Mor neon
      secondary: Color(0xFF00C9A7),     // Turkuaz / Mint yeşili
      tertiary: Color(0xFFFF6F61),      // Sıcak vurgu
      surface: Color(0xFF1A1A1C),
      onSurface: Colors.white70,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1F1F22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
