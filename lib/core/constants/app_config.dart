/// Configuración general de la aplicación
///
/// Contiene constantes de configuración que no pertenecen a dominios
/// específicos como BLE, Storage o Rutas.
class AppConfig {
  AppConfig._(); // Constructor privado para prevenir instanciación

  // ============================================================================
  // INFORMACIÓN DE LA APLICACIÓN
  // ============================================================================

  /// Nombre de la aplicación
  static const String appName = 'Nebu Mobile';

  /// Versión actual de la aplicación
  /// Formato: MAJOR.MINOR.PATCH
  static const String appVersion = '1.0.1';

  // ============================================================================
  // CONFIGURACIÓN DE API
  // ============================================================================

  /// Tiempo máximo de espera para llamadas HTTP
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Número máximo de reintentos para llamadas fallidas
  static const int maxRetries = 3;

  // ============================================================================
  // IDIOMAS SOPORTADOS
  // ============================================================================

  /// Código de idioma inglés
  static const String languageEnglish = 'en';

  /// Código de idioma español
  static const String languageSpanish = 'es';

  /// Lista de idiomas soportados por la aplicación
  static const List<String> supportedLanguages = [
    languageEnglish,
    languageSpanish,
  ];

  // ============================================================================
  // DURACIONES DE ANIMACIONES
  // ============================================================================

  /// Duración corta para animaciones rápidas
  /// Usar para transiciones simples como fade in/out
  static const Duration animationShort = Duration(milliseconds: 200);

  /// Duración media para animaciones estándar
  /// Usar para la mayoría de transiciones y animaciones
  static const Duration animationMedium = Duration(milliseconds: 300);

  /// Duración larga para animaciones complejas
  /// Usar para transiciones elaboradas o secuencias múltiples
  static const Duration animationLong = Duration(milliseconds: 500);

  // ============================================================================
  // LÍMITES Y VALIDACIONES
  // ============================================================================

  /// Longitud mínima para contraseñas
  static const int minPasswordLength = 8;

  /// Longitud máxima para nombres de usuario
  static const int maxUsernameLength = 50;

  /// Longitud máxima para nombres de juguetes
  static const int maxToyNameLength = 30;

  /// Tamaño máximo de archivo para imágenes de perfil (5 MB)
  static const int maxProfileImageSize = 5 * 1024 * 1024;

  // ============================================================================
  // CONFIGURACIÓN DE CACHÉ
  // ============================================================================

  /// Tiempo de vida del caché de datos de usuario
  static const Duration userCacheDuration = Duration(hours: 24);

  /// Tiempo de vida del caché de datos de juguetes
  static const Duration toyCacheDuration = Duration(hours: 1);

  /// Número máximo de dispositivos BLE a mantener en caché
  static const int maxCachedDevices = 10;

  // ============================================================================
  // CONFIGURACIÓN DE DESARROLLO
  // ============================================================================

  /// Habilitar logs detallados en modo debug
  static const bool enableVerboseLogs = true;

  /// Habilitar analytics en producción
  static const bool enableAnalytics = false; // TODO: Habilitar en producción

  /// Habilitar crash reporting
  static const bool enableCrashReporting = false; // TODO: Habilitar en producción
}
