import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/config.dart';
import '../../core/constants/storage_keys.dart';
import '../../presentation/providers/auth_provider.dart' as auth;

// Language state
class LanguageState {
  LanguageState({this.locale = const Locale('en'), this.languageCode = 'en'});
  final Locale locale;
  final String languageCode;

  LanguageState copyWith({Locale? locale, String? languageCode}) =>
      LanguageState(
        locale: locale ?? this.locale,
        languageCode: languageCode ?? this.languageCode,
      );
}

// Language notifier
class LanguageNotifier extends AsyncNotifier<LanguageState> {
  SharedPreferences? _prefs;

  @override
  Future<LanguageState> build() async {
    _prefs = await ref.read(auth.sharedPreferencesProvider.future);
    return _loadLanguage();
  }

  // Load language from storage
  Future<LanguageState> _loadLanguage() async {
    final languageCode =
        _prefs?.getString(StorageKeys.language) ?? Config.languageEnglish;

    if (Config.supportedLanguages.contains(languageCode)) {
      return LanguageState(
        locale: Locale(languageCode),
        languageCode: languageCode,
      );
    }
    return LanguageState();
  }

  // Set language
  Future<void> setLanguage(String languageCode) async {
    if (!Config.supportedLanguages.contains(languageCode)) {
      return;
    }

    await _prefs?.setString(StorageKeys.language, languageCode);

    state = AsyncValue.data(
      LanguageState(locale: Locale(languageCode), languageCode: languageCode),
    );
  }

  // Set to English
  Future<void> setEnglish() async {
    await setLanguage(Config.languageEnglish);
  }

  // Set to Spanish
  Future<void> setSpanish() async {
    await setLanguage(Config.languageSpanish);
  }

  // Toggle between EN and ES
  Future<void> toggleLanguage() async {
    final currentState = state.value;
    final newLanguage = currentState?.languageCode == Config.languageEnglish
        ? Config.languageSpanish
        : Config.languageEnglish;

    await setLanguage(newLanguage);
  }
}

// Provider
final languageProvider = AsyncNotifierProvider<LanguageNotifier, LanguageState>(
  LanguageNotifier.new,
);
