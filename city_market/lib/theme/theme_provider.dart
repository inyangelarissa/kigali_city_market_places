import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadThemeMode();
  }

  static const String _themeKey = 'theme_mode';

  // Load saved theme preference
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme != null) {
        state = _parseThemeMode(savedTheme);
      }
    } catch (e) {
      // Keep default dark theme if loading fails
      state = ThemeMode.dark;
    }
  }

  // Save theme preference
  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.toString());
    } catch (e) {
      // Continue even if saving fails
    }
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newTheme;
    await _saveThemeMode(newTheme);
  }

  // Set specific theme
  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    await _saveThemeMode(themeMode);
  }

  // Parse string to ThemeMode
  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      case 'ThemeMode.system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  // Check if current theme is dark
  bool get isDarkMode => state == ThemeMode.dark;
  
  // Check if current theme is light
  bool get isLightMode => state == ThemeMode.light;
  
  // Check if current theme follows system
  bool get isSystemMode => state == ThemeMode.system;
}
