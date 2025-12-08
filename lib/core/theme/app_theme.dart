import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ----------------- Color Definitions -----------------

  // Light Theme Colors
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color surfaceLight = Colors.white;
  static const Color errorLight = Color(0xFFEF4444);
  static const Color onPrimaryLight = Colors.white;
  static const Color onBackgroundLight = Color(0xFF1F2937);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFFA78BFA);
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color errorDark = Color(0xFFF87171);
  static const Color onPrimaryDark = Colors.black;
  static const Color onBackgroundDark = Color(0xFFF9FAFB);

  // Gradient Colors
  static const List<Color> primaryGradient = [primaryLight, secondaryLight];
  static const List<Color> secondaryGradient = [
    secondaryLight,
    Color(0xFFEC4899)
  ];

  // ----------------- Color Schemes -----------------

  static ColorScheme get _lightColorScheme => const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        error: errorLight,
        onSecondary: Colors.white,
        onSurface: onBackgroundLight,
      );

  static ColorScheme get _darkColorScheme => const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        surface: surfaceDark,
        error: errorDark,
        onSurface: onBackgroundDark,
      );

  // ----------------- Text Themes -----------------

  static TextTheme get _lightTextTheme => _getTextTheme(onBackgroundLight);
  static TextTheme get _darkTextTheme => _getTextTheme(onBackgroundDark);

  static TextTheme _getTextTheme(Color textColor) => TextTheme(
        displayLarge:
            TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: textColor),
        displayMedium:
            TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: textColor),
        displaySmall:
            TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: textColor),
        headlineLarge:
            TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: textColor),
        headlineMedium:
            TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: textColor),
        headlineSmall:
            TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
        titleLarge:
            TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: textColor),
        titleMedium:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
        titleSmall:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        bodyLarge:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textColor),
        bodyMedium:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
        bodySmall:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
        labelLarge:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
        labelMedium:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor),
        labelSmall:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
      );

  // ----------------- Main Themes -----------------

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: _lightTextTheme,
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceLight,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: onBackgroundLight),
          titleTextStyle:
              _lightTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        cardTheme: const CardThemeData(
          color: surfaceLight,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        elevatedButtonTheme: _getElevatedButtonTheme(_lightColorScheme),
        outlinedButtonTheme: _getOutlinedButtonTheme(_lightColorScheme),
        inputDecorationTheme: _getInputDecorationTheme(_lightColorScheme),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceLight,
          selectedItemColor: primaryLight,
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: _darkTextTheme,
        scaffoldBackgroundColor: backgroundDark,
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceDark,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: onBackgroundDark),
          titleTextStyle:
              _darkTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        cardTheme: const CardThemeData(
          color: surfaceDark,
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
        elevatedButtonTheme: _getElevatedButtonTheme(_darkColorScheme),
        outlinedButtonTheme: _getOutlinedButtonTheme(_darkColorScheme),
        inputDecorationTheme: _getInputDecorationTheme(_darkColorScheme),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surfaceDark,
          selectedItemColor: primaryDark,
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
      );

  // ----------------- Component Themes -----------------

  static ElevatedButtonThemeData _getElevatedButtonTheme(
          ColorScheme colorScheme) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );

  static OutlinedButtonThemeData _getOutlinedButtonTheme(
          ColorScheme colorScheme) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: colorScheme.primary, width: 2),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      );

  static InputDecorationTheme _getInputDecorationTheme(ColorScheme colorScheme) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
      );

  // ----------------- Decorations & Shadows -----------------

  static BoxDecoration get primaryGradientDecoration => const BoxDecoration(
        gradient: LinearGradient(
          colors: primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  static BoxDecoration get secondaryGradientDecoration => const BoxDecoration(
        gradient: LinearGradient(
          colors: secondaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
