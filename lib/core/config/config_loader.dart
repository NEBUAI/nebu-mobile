import 'package:logger/logger.dart';

import 'config.dart';

/// Helper para cargar configuración
abstract final class ConfigLoader {
  ConfigLoader._();

  static final _logger = Logger();

  /// Inicializar configuración
  /// - En desarrollo: Usa valores por defecto locales (localhost:3000)
  /// - En producción: Usa URL de producción
  static Future<void> initialize() async {
    _logger
      ..i('🔧 Initializing app configuration...')
      ..i('🔧 Environment: ${Config.environment}')
      ..i('🔧 Debug Mode: ${Config.isDevelopment}')
      ..i('🔧 API Base URL: ${Config.apiBaseUrl}');

    // Validar configuración
    try {
      Config.validate();
      _logger.i('✅ Configuration validated successfully');
    } catch (e) {
      _logger.e('❌ Configuration validation failed: $e');
      rethrow;
    }

    // Mostrar info de debug en desarrollo
    if (Config.enableDebugLogs) {
      _logger.i(Config.getDebugInfo());
    }
  }
}
