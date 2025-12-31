import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static const String appName = 'Nebu Mobile';
  static const String appVersion = '1.0.1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const String languageEnglish = 'en';
  static const String languageSpanish = 'es';
  static const List<String> supportedLanguages = ['en', 'es'];
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  // Environment variables
  static String get apiBaseUrl =>
      dotenv.env['API_URL'] ?? 'https://default-api.com';
  static String get apiKey => dotenv.env['API_KEY'] ?? 'default-api-key';
}
