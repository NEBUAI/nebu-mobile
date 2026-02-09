import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración centralizada de la aplicación
/// Úsala en lugar de EnvConfig o AppConfig

/// Configuración única y centralizada
abstract final class Config {
  Config._();

  // ============================================
  // Environment
  // ============================================
  static String get environment => dotenv.get('ENV', fallback: 'development');
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';

  // ============================================
  // App Constants
  // ============================================
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
  static const String privacyPolicyUrl = 'https://flow-telligence.com/privacy';
  static const String deleteAccountUrl =
      'https://flow-telligence.com/privacy#delete-account';
  static const String deleteDataUrl =
      'https://flow-telligence.com/privacy#delete-data';

  // ============================================
  // Backend API
  // ============================================
  static String get apiBaseUrl => dotenv.get(
    'API_URL',
    fallback: isProduction
        ? 'https://default-api.com'
        : 'http://localhost:3000',
  );

  static String get apiKey => dotenv.get('API_KEY', fallback: '');
  static String get wsUrl => dotenv.get('WS_URL', fallback: '');

  // ============================================
  // LiveKit
  // ============================================
  static String get livekitUrl => dotenv.get('LIVEKIT_URL', fallback: '');
  static String get livekitApiKey =>
      dotenv.get('LIVEKIT_API_KEY', fallback: '');
  static String get livekitApiSecret =>
      dotenv.get('LIVEKIT_API_SECRET', fallback: '');

  // ============================================
  // Social Auth
  // ============================================
  static String get googleWebClientId =>
      dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');
  static String get googleIosClientId =>
      dotenv.get('GOOGLE_IOS_CLIENT_ID', fallback: '');
  static String get facebookAppId =>
      dotenv.get('FACEBOOK_APP_ID', fallback: '');

  // ============================================
  // Debug & Logging
  // ============================================
  static bool get enableDebugLogs =>
      dotenv.get('ENABLE_DEBUG_LOGS', fallback: 'true') == 'true' &&
      !isProduction;
  static bool get enableCrashReporting =>
      dotenv.get('ENABLE_CRASH_REPORTING', fallback: 'false') == 'true';

  // ============================================
  // Validation
  // ============================================
  /// Validar que la configuración esencial está presente
  static void validate() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('❌ API_URL no configurada');
    }

    if (isProduction && apiKey.isEmpty) {
      errors.add('❌ API_KEY requerida en producción');
    }

    if (errors.isNotEmpty) {
      throw Exception(
        'Configuración inválida:\n${errors.join('\n')}\n\n'
        'En desarrollo: Verifica tu archivo .env\n'
        'En producción: Usa --dart-define en el build',
      );
    }
  }

  /// Información de debug para logs
  static String getDebugInfo() =>
      '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 Nebu Mobile Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
App: $appName v$appVersion
Environment: $environment
API URL: $apiBaseUrl
Debug Logs: $enableDebugLogs
Crash Reporting: $enableCrashReporting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';
}
