import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// T14: design credit. Replace these with the Figma Community file you chose.
// ---------------------------------------------------------------------------
class DesignCredit {
  static const name = 'YOUR FIGMA FILE NAME';
  static const author = 'AUTHOR NAME';
  static const link = 'https://www.figma.com/community/file/...';
  static const license = 'CC BY 4.0';
}

// ---------------------------------------------------------------------------
// T15: every colour, size and radius lives here. Read these values from your
// Figma file and change them. Screens only use Theme.of(context).
// ---------------------------------------------------------------------------
class AppTheme {
  // Colours from the Figma file
  static const _primary = Color(0xFF4F46E5);
  static const _secondary = Color(0xFF10B981);
  static const _background = Color(0xFFF7F7FB);
  static const _surface = Color(0xFFFFFFFF);
  static const _text = Color(0xFF1F2937);
  static const _error = Color(0xFFDC2626);

  // Shapes and spacing from the Figma file
  static const radius = 16.0;
  static const spacing = 16.0;

  static ThemeData get light {
    final colors = ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      surface: _surface,
      onSurface: _text,
      error: _error,
    );

    final rounded = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: _background,
      fontFamily: 'Roboto', // change to the font in your Figma file

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _text),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _text),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text),
        bodyLarge: TextStyle(fontSize: 16, color: _text),
        bodyMedium: TextStyle(fontSize: 14, color: _text),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
      ),

      cardTheme: CardThemeData(
        color: _surface,
        elevation: 0,
        shape: rounded,
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: rounded,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: rounded,
        ),
      ),

      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      ),

      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _surface,
      ),
    );
  }
}
