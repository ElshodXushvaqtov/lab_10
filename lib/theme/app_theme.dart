import 'package:flutter/material.dart';

class DesignCredit {
  static const name = 'TimePad Time Tracker UI Kit';
  static const author = 'Rizki Mulyawan';
  static const link =
      'https://www.figma.com/community/file/877861267642234232/timepad-time-tracker-ui-kit';
  static const license = 'CC BY 4.0';
}

class AppTheme {
  static const _primary = Color(0xFF7012CE);
  static const _secondary = Color(0xFFFF4D8D);
  static const _background = Color(0xFFF5F6FA);
  static const _surface = Color(0xFFFFFFFF);
  static const _text = Color(0xFF070417);
  static const _error = Color(0xFFE53950);

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
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        headlineMedium:
            TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _text),
        titleLarge:
            TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _text),
        titleMedium:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
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
