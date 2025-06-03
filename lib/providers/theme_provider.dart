import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for Theme Modes
enum ThemeModeOption { light, dark, system }

// Provider for managing the current theme mode
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeModeOption>((ref) {
      return ThemeModeNotifier();
    });

class ThemeModeNotifier extends StateNotifier<ThemeModeOption> {
  ThemeModeNotifier()
    : super(ThemeModeOption.system); // Default to system theme

  void setThemeMode(ThemeModeOption themeMode) {
    state = themeMode;
  }

  void toggleTheme() {
    final currentBrightness = PlatformDispatcher.instance.platformBrightness;
    if (state == ThemeModeOption.system) {
      // If system theme is active, toggle based on current system brightness
      if (currentBrightness == Brightness.dark) {
        state = ThemeModeOption.light; // Switch to light mode
      } else {
        state = ThemeModeOption.dark; // Switch to dark mode
      }
    } else if (state == ThemeModeOption.light) {
      state = ThemeModeOption.dark;
    } else {
      // state == ThemeModeOption.dark
      state = ThemeModeOption.light;
    }
  }
}

// Provider for the actual ThemeData based on the theme mode
final appThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final brightness = PlatformDispatcher.instance.platformBrightness;

  switch (themeMode) {
    case ThemeModeOption.light:
      return _buildLightTheme();
    case ThemeModeOption.dark:
      return _buildDarkTheme();
    case ThemeModeOption.system:
      return brightness == Brightness.dark
          ? _buildDarkTheme()
          : _buildLightTheme();
  }
});

ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    // primarySwatch: Colors.teal, // Consider removing if using ColorScheme fully
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF00796B), // Teal
      secondary: const Color(0xFFFFC107), // Amber
      surface: const Color(0xFFF5F5F5), // Lighter Grey
      surfaceContainer: const Color(0xFFFFFFFF), // White
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: const Color(0xFF212121), // Dark Grey
      error: const Color(0xFFD32F2F), // Red
      onError: Colors.white,
    ),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF00796B), // Teal
      foregroundColor: Colors.white,
      elevation: 0, // Flatter design
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
    ),
    // Add other theme properties as needed
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    // primarySwatch: Colors.cyan, // Consider removing if using ColorScheme fully
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF00ACC1), // Cyan
      secondary: const Color(0xFFFFAB00), // Orange
      surface: const Color(0xFF212121), // Darker Grey
      surfaceContainer: const Color(0xFF303030), // Dark Grey
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: const Color(0xFFE0E0E0), // Light Grey
      error: const Color(0xFFEF5350), // Light Red
      onError: Colors.black,
    ),
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF212121), // Darker Grey
      foregroundColor: const Color(0xFFE0E0E0), // Light Grey
      elevation: 0, // Flatter design
      titleTextStyle: const TextStyle(color: Color(0xFFE0E0E0), fontSize: 20, fontWeight: FontWeight.w500),
    ),
    // Add other theme properties as needed
  );
}
