import 'package:flutter/material.dart';

/// App theme configuration
class AppTheme {
  AppTheme._();

  static const Color _seedColor = Color(0xFF43A047);
  static const Color _scaffoldBackground = Color(0xFFF6FFF8);

  static ColorScheme _buildColorScheme(Brightness brightness) {
    return ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
  }

  static ThemeData lightTheme() {
    final colorScheme = _buildColorScheme(Brightness.light);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: _scaffoldBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.black.withValues(alpha: 0.1),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData.fromDefaults(
        secondaryColor: colorScheme.primary,
        brightness: Brightness.light,
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ).copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: const Color(0xFFE9F7EE),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        indicatorColor: colorScheme.secondaryContainer,
      ),
      textTheme: const TextTheme().apply(
        fontFamily: 'Roboto',
        bodyColor: Color(0xFF1B4332),
        displayColor: Color(0xFF1B4332),
      ),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = _buildColorScheme(Brightness.dark);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surfaceContainerHighest,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        margin: EdgeInsets.zero,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      // Add other dark theme customizations as needed
    );
  }
}

