import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);

  static ThemeData get theme => ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: primary,
          surface: surface,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      );
}