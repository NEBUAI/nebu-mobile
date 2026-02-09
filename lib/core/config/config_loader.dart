import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

import 'app_config.dart';

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
      ..i('🔧 Environment: ${AppConfig.environment}');

    if (AppConfig.isDevelopment || AppConfig.isStaging) {
      try {
        _logger.d('📂 Loading .env file for ${AppConfig.environment}...');
        await dotenv.load();
        _logger.i('✅ .env file loaded successfully');

        // Configurar valores en runtime desde .env
        AppConfig.setRuntimeConfig(
          apiUrl: dotenv.env['API_URL'],
          apiKey: dotenv.env['API_KEY'],
          wsUrl: dotenv.env['WS_URL'],
        );

        _logger.i('✅ Runtime config set from .env');
      } catch (e) {
        _logger
          ..e('❌ Error loading .env file: $e')
          ..e('⚠️  Make sure .env exists (copy from .env.example)');
        rethrow;
      }
    } else {
      _logger.i('🏭 Production mode: Using dart-define values');
    }

    // Validar configuración
    try {
      AppConfig.validate();
      _logger.i('✅ Configuration validated successfully');
    } catch (e) {
      _logger.e('❌ Configuration validation failed: $e');
      rethrow;
    }

    // Mostrar info de debug en desarrollo
    if (AppConfig.shouldShowDebugLogs) {
      _logger.i(AppConfig.getDebugInfo());
    }
  }
}
