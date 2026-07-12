import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFF06292);
  static const Color secondary = Color(0xFFF48FB1);
  static const Color accent = Color(0xFFFCE4EC);
  static const Color background = Color(0xFFFFF8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color income = Color(0xFF81C784);
  static const Color expense = Color(0xFFE57373);
  static const Color textDark = Color(0xFF3D1A24);
  static const Color textLight = Color(0xFF9E7B85);
  static const Color warning = Color(0xFFFFB74D);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
      );
}