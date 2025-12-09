/// Configuración de la aplicación
///
/// Usa dart-define en producción y .env en desarrollo
///
/// Build de producción:
/// ```bash
/// flutter build apk --dart-define=ENV=production \
///   --dart-define=API_URL=https://api.nebu.ai \
///   --dart-define=API_KEY=your_api_key
/// ```
class AppConfig {
  // Environment
  static const environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  // API Configuration
  static const apiUrl = String.fromEnvironment(
    'API_URL',
  );

  static const apiKey = String.fromEnvironment(
    'API_KEY',
  );

  // WebSocket Configuration
  static const wsUrl = String.fromEnvironment(
    'WS_URL',
  );

  // Feature Flags
  static const enableDebugLogs = String.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: 'true',
  );

  static const enableCrashReporting = String.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: 'false',
  );

  // Computed properties
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';

  static bool get shouldShowDebugLogs =>
      enableDebugLogs.toLowerCase() == 'true' && !isProduction;

  static bool get shouldEnableCrashReporting =>
      enableCrashReporting.toLowerCase() == 'true';

  // Runtime values (loaded from .env in development)
  static String? _runtimeApiUrl;
  static String? _runtimeApiKey;
  static String? _runtimeWsUrl;

  /// Obtener la URL de la API (prioriza dart-define sobre .env)
  static String getApiUrl() {
    if (apiUrl.isNotEmpty) return apiUrl;
    if (_runtimeApiUrl != null && _runtimeApiUrl!.isNotEmpty) {
      return _runtimeApiUrl!;
    }
    throw Exception('API_URL not configured. Check .env or dart-define');
  }

  /// Obtener la API Key (prioriza dart-define sobre .env)
  static String getApiKey() {
    if (apiKey.isNotEmpty) return apiKey;
    if (_runtimeApiKey != null && _runtimeApiKey!.isNotEmpty) {
      return _runtimeApiKey!;
    }
    // API Key es opcional, retornar vacío si no está configurado
    return '';
  }

  /// Obtener la URL de WebSocket (prioriza dart-define sobre .env)
  static String getWsUrl() {
    if (wsUrl.isNotEmpty) return wsUrl;
    if (_runtimeWsUrl != null && _runtimeWsUrl!.isNotEmpty) {
      return _runtimeWsUrl!;
    }
    // WS URL es opcional, retornar vacío si no está configurado
    return '';
  }

  /// Configurar valores en runtime (usado con flutter_dotenv en desarrollo)
  static void setRuntimeConfig({
    String? apiUrl,
    String? apiKey,
    String? wsUrl,
  }) {
    _runtimeApiUrl = apiUrl;
    _runtimeApiKey = apiKey;
    _runtimeWsUrl = wsUrl;
  }

  /// Validar configuración (útil en desarrollo)
  static void validate() {
    final errors = <String>[];

    try {
      getApiUrl();
    } catch (e) {
      errors.add('❌ API_URL no configurada');
    }

    if (errors.isNotEmpty) {
      throw Exception(
        'Configuración inválida:\n${errors.join('\n')}\n\n'
        'En desarrollo: Verifica tu archivo .env\n'
        'En producción: Usa --dart-define en el build',
      );
    }
  }

  /// Información de debug
  static String getDebugInfo() => '''
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📱 App Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Environment: $environment
API URL: ${_maskUrl(getApiUrl())}
API Key: ${getApiKey().isNotEmpty ? '[SET]' : '[NOT SET]'}
WS URL: ${getWsUrl().isNotEmpty ? _maskUrl(getWsUrl()) : '[NOT SET]'}
Debug Logs: $shouldShowDebugLogs
Crash Reporting: $shouldEnableCrashReporting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

  static String _maskUrl(String url) {
    if (url.isEmpty) return '[NOT SET]';
    if (isProduction) {
      // En producción, ocultar parte de la URL
      final uri = Uri.parse(url);
      return '${uri.scheme}://***${uri.host.substring(uri.host.length - 10)}';
    }
    return url;
  }
}
