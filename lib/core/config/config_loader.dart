import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'config.dart';

/// Helper para cargar configuración desde .env en desarrollo
abstract final class ConfigLoader {
  ConfigLoader._();

  static final _logger = Logger();

  /// Inicializar configuración
  /// - En desarrollo: Carga desde .env
  /// - En producción: Usa valores de dart-define
  static Future<void> initialize() async {
    _logger
      ..i('🔧 Initializing app configuration...')
      ..i('🔧 Environment: ${Config.environment}');

    if (Config.isDevelopment || Config.isStaging) {
      try {
        _logger.d(
          '📂 Loading .env file for ${Config.environment} (optional)...',
        );
        await dotenv.load(isOptional: true);
        _logger
          ..i('✅ .env file loaded (if present)')
          ..i('✅ Configuration loaded from .env (if present)');
      } on Exception catch (e) {
        _logger
          ..e('❌ Error loading .env file: $e')
          ..e('⚠️  .env is optional; ensure dart-define values are set');
      }
    } else {
      _logger.i('🏭 Production mode: Using dart-define values');
    }

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
