import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Colors
  static const Color primary = Color(0xFF7C6EF6);
  static const Color secondary = Color(0xFF53C68C);

  static const Color backgroundLight = Color(0xFFF7F8FC);
  static const Color backgroundDark = Color(0xFF141518);

  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF23252B);

  static const Color textLight = Color(0xFF202124);
  static const Color textDark = Colors.white;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: secondary,
          surface: surfaceLight,
        ),

        scaffoldBackgroundColor: backgroundLight,

        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundLight,
          foregroundColor: textLight,
          centerTitle: true,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: surfaceLight,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surfaceDark,
        ),

        scaffoldBackgroundColor: backgroundDark,

        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundDark,
          foregroundColor: textDark,
          centerTitle: true,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceDark,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
        ),
      );
}