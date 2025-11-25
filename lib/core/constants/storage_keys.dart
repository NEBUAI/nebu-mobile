/// Claves de almacenamiento local
///
/// Este archivo define todas las claves usadas para almacenar datos
/// en SharedPreferences y FlutterSecureStorage.
///
/// **IMPORTANTE - Seguridad:**
/// - Datos sensibles (tokens, passwords) → FlutterSecureStorage
/// - Datos no sensibles (preferencias, cache) → SharedPreferences
class StorageKeys {
  StorageKeys._(); // Constructor privado para prevenir instanciación

  // ============================================================================
  // SECURE STORAGE (FlutterSecureStorage)
  // ============================================================================
  // ⚠️ SOLO para datos sensibles que requieren encriptación

  /// Access token JWT para autenticación
  /// **Almacenamiento:** FlutterSecureStorage (encriptado)
  /// **Sensibilidad:** ALTA - permite acceso a la cuenta del usuario
  static const String secureAccessToken = 'secure_access_token';

  /// Refresh token JWT para renovar access token
  /// **Almacenamiento:** FlutterSecureStorage (encriptado)
  /// **Sensibilidad:** ALTA - permite obtener nuevos access tokens
  static const String secureRefreshToken = 'secure_refresh_token';

  // ============================================================================
  // SHARED PREFERENCES (Datos no sensibles)
  // ============================================================================
  // ✅ Para preferencias de usuario, cache, configuración

  /// Datos del usuario en formato JSON
  /// **Almacenamiento:** SharedPreferences
  /// **Sensibilidad:** MEDIA - información de perfil (nombre, email, etc.)
  /// **Nota:** No contiene passwords ni tokens
  static const String user = 'user';

  /// Idioma seleccionado por el usuario
  /// **Valores:** 'en', 'es'
  /// **Default:** 'en'
  static const String language = 'language';

  /// Modo de tema seleccionado
  /// **Valores:** 'light', 'dark', 'system'
  /// **Default:** 'system'
  static const String themeMode = 'theme_mode';

  /// Device ID del ESP32 actualmente configurado
  /// **Formato:** "ESP32_XXXXXXXXXXXX"
  /// **Uso:** Almacenar temporalmente el Device ID del último ESP32 conectado
  /// **Nota:** Se limpia al registrar el dispositivo en el backend
  static const String currentDeviceId = 'current_device_id';

  /// Indica si es la primera vez que el usuario abre la app
  /// **Valores:** true/false
  /// **Uso:** Mostrar tutorial o welcome screen solo la primera vez
  static const String isFirstLaunch = 'is_first_launch';

  /// Timestamp de la última sincronización con el backend
  /// **Formato:** ISO 8601 string
  /// **Uso:** Determinar si se necesita sincronizar datos
  static const String lastSyncTimestamp = 'last_sync_timestamp';

  // ============================================================================
  // LEGACY KEYS (Deprecados - mantener por compatibilidad)
  // ============================================================================

  /// @deprecated Usar [secureAccessToken] en su lugar
  /// Migrar a SecureStorage para mejor seguridad
  @Deprecated('Use secureAccessToken instead')
  static const String keyAccessToken = 'access_token';

  /// @deprecated Usar [secureRefreshToken] en su lugar
  /// Migrar a SecureStorage para mejor seguridad
  @Deprecated('Use secureRefreshToken instead')
  static const String keyRefreshToken = 'refresh_token';

  /// @deprecated Usar [user] en su lugar
  @Deprecated('Use user instead')
  static const String keyUser = 'user';

  /// @deprecated Usar [language] en su lugar
  @Deprecated('Use language instead')
  static const String keyLanguage = 'language';

  /// @deprecated Usar [themeMode] en su lugar
  @Deprecated('Use themeMode instead')
  static const String keyThemeMode = 'theme_mode';

  /// @deprecated Usar [currentDeviceId] en su lugar
  @Deprecated('Use currentDeviceId instead')
  static const String keyCurrentDeviceId = 'current_device_id';
}
