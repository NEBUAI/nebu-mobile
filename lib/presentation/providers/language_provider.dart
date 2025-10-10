import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// Language state
class LanguageState {
  final Locale locale;
  final String languageCode;

  LanguageState({
    this.locale = const Locale('en'),
    this.languageCode = 'en',
  });

  LanguageState copyWith({
    Locale? locale,
    String? languageCode,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

// Language notifier
class LanguageNotifier extends StateNotifier<LanguageState> {
  final SharedPreferences _prefs;

  LanguageNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(LanguageState()) {
    _loadLanguage();
  }

  // Load language from storage
  Future<void> _loadLanguage() async {
    final languageCode = _prefs.getString(AppConstants.keyLanguage) ??
        AppConstants.languageEnglish;

    if (AppConstants.supportedLanguages.contains(languageCode)) {
      state = state.copyWith(
        locale: Locale(languageCode),
        languageCode: languageCode,
      );
    }
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    if (!AppConstants.supportedLanguages.contains(languageCode)) {
      return;
    }

    await _prefs.setString(AppConstants.keyLanguage, languageCode);

    state = state.copyWith(
      locale: Locale(languageCode),
      languageCode: languageCode,
    );
  }

  // Set to English
  Future<void> setEnglish() async {
    await setLanguage(AppConstants.languageEnglish);
  }

  // Set to Spanish
  Future<void> setSpanish() async {
    await setLanguage(AppConstants.languageSpanish);
  }

  // Toggle between EN and ES
  Future<void> toggleLanguage() async {
    final newLanguage = state.languageCode == AppConstants.languageEnglish
        ? AppConstants.languageSpanish
        : AppConstants.languageEnglish;

    await setLanguage(newLanguage);
  }
}

// Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  throw UnimplementedError('languageProvider must be overridden');
});
