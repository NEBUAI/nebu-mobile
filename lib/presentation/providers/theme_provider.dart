import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// Theme state
class ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;

  ThemeState({
    this.themeMode = ThemeMode.system,
    this.isDarkMode = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

// Theme notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences _prefs;

  ThemeNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(ThemeState()) {
    _loadTheme();
  }

  // Load theme from storage
  Future<void> _loadTheme() async {
    final themeModeString = _prefs.getString(AppConstants.keyThemeMode);

    ThemeMode themeMode;
    bool isDarkMode;

    if (themeModeString == null) {
      themeMode = ThemeMode.system;
      isDarkMode = false;
    } else {
      switch (themeModeString) {
        case 'dark':
          themeMode = ThemeMode.dark;
          isDarkMode = true;
          break;
        case 'light':
          themeMode = ThemeMode.light;
          isDarkMode = false;
          break;
        default:
          themeMode = ThemeMode.system;
          isDarkMode = false;
      }
    }

    state = state.copyWith(
      themeMode: themeMode,
      isDarkMode: isDarkMode,
    );
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newIsDarkMode = !state.isDarkMode;
    final newThemeMode = newIsDarkMode ? ThemeMode.dark : ThemeMode.light;

    await _saveTheme(newThemeMode);

    state = state.copyWith(
      themeMode: newThemeMode,
      isDarkMode: newIsDarkMode,
    );
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _saveTheme(themeMode);

    state = state.copyWith(
      themeMode: themeMode,
      isDarkMode: themeMode == ThemeMode.dark,
    );
  }

  // Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(ThemeMode.system);
  }

  // Save theme to storage
  Future<void> _saveTheme(ThemeMode themeMode) async {
    String themeModeString;
    switch (themeMode) {
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }

    await _prefs.setString(AppConstants.keyThemeMode, themeModeString);
  }
}

// Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  throw UnimplementedError('themeProvider must be overridden');
});
