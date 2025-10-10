import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Backend API
  static String get urlBackend => dotenv.get('URL_BACKEND', fallback: '');
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost:3000');
  static int get apiTimeout =>
      int.tryParse(dotenv.get('API_TIMEOUT', fallback: '30000')) ?? 30000;

  // OpenAI
  static String get openaiApiKey =>
      dotenv.get('OPENAI_API_KEY', fallback: '');

  // LiveKit
  static String get livekitUrl => dotenv.get('LIVEKIT_URL', fallback: '');
  static String get livekitApiKey =>
      dotenv.get('LIVEKIT_API_KEY', fallback: '');
  static String get livekitApiSecret =>
      dotenv.get('LIVEKIT_API_SECRET', fallback: '');

  // Social Auth - Google
  static String get googleWebClientId =>
      dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');
  static String get googleIosClientId =>
      dotenv.get('GOOGLE_IOS_CLIENT_ID', fallback: '');

  // Social Auth - Facebook
  static String get facebookAppId =>
      dotenv.get('FACEBOOK_APP_ID', fallback: '');

  // Environment
  static String get appEnv =>
      dotenv.get('APP_ENV', fallback: 'development');
  static bool get isDevelopment => appEnv == 'development';
  static bool get isDebugMode =>
      dotenv.get('DEBUG_MODE', fallback: 'true') == 'true';

  // Validation
  static bool get isConfigured {
    return urlBackend.isNotEmpty && openaiApiKey.isNotEmpty;
  }
}
