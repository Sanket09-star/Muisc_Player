import 'package:flutter/material.dart';
import 'package:music_player/screens/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/theme_provider.dart'; // Import the theme provider

void main() {
  runApp(const ProviderScope(child: MyApp())); // MyApp is now a ConsumerWidget
}

class MyApp extends ConsumerWidget {
  // Changed to ConsumerWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef
    final theme = ref.watch(appThemeProvider); // Watch the theme provider

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music Player',
      theme: theme, // Apply the dynamic theme
      darkTheme:
          _buildDarkTheme(), // Optionally define a specific dark theme if different from provider logic
      themeMode:
          ref
              .watch(themeModeProvider)
              .toMaterialThemeMode(), // Sync with provider
      home: const HomeScreen(),
    );
  }
}

// Helper extension to convert custom enum to Material ThemeMode
extension ThemeModeOptionExtension on ThemeModeOption {
  ThemeMode toMaterialThemeMode() {
    switch (this) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
      // No default needed as all enum cases are handled
    }
  }
}

// It's good practice to keep theme definitions consistent.
// If _buildDarkTheme is used here, it should ideally be the same as in theme_provider.dart
// or imported from there if made public.
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
      titleTextStyle: const TextStyle(
        color: Color(0xFFE0E0E0),
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
