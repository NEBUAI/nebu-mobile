/// Constantes para comunicación BLE (Bluetooth Low Energy)
///
/// Este archivo contiene todos los UUIDs y configuraciones para la comunicación
/// BLE con dispositivos ESP32.
class BleConstants {
  BleConstants._(); // Constructor privado para prevenir instanciación

  // ============================================================================
  // TIMEOUTS Y CONFIGURACIÓN
  // ============================================================================

  /// Tiempo máximo para escanear dispositivos BLE
  static const Duration scanTimeout = Duration(seconds: 10);

  /// Tiempo máximo para establecer conexión con dispositivo BLE
  static const Duration connectionTimeout = Duration(seconds: 15);

  // ============================================================================
  // SERVICIOS BLE ESTÁNDAR (Bluetooth SIG)
  // ============================================================================

  /// UUID del servicio de batería estándar (0x180F)
  /// Servicio definido por Bluetooth SIG para nivel de batería
  static const String batteryServiceUuid =
      '0000180f-0000-1000-8000-00805f9b34fb';

  /// UUID de la característica de nivel de batería (0x2A19)
  /// Retorna un valor entre 0-100 representando el porcentaje de batería
  static const String batteryLevelCharUuid =
      '00002a19-0000-1000-8000-00805f9b34fb';

  // ============================================================================
  // SERVICIO CUSTOM: CONFIGURACIÓN WIFI ESP32
  // ============================================================================

  /// UUID del servicio principal de configuración WiFi del ESP32
  ///
  /// Nombre visible en escaneo BLE: "ESP32-WiFi-Config"
  /// Base UUID: 0000bc9a-7856-3412-3412-xxxxxxxxxxxx
  ///
  /// Este servicio permite configurar credenciales WiFi y obtener información
  /// del dispositivo ESP32 via BLE.
  static const String esp32WifiServiceUuid =
      '0000bc9a-7856-3412-3412-341278563412';

  /// Característica SSID - Enviar nombre de red WiFi
  ///
  /// **Propiedades:** READ | WRITE_NO_RESPONSE
  /// **Formato:** String UTF-8
  /// **Longitud máxima:** 32 bytes (límite WiFi estándar)
  /// **Ejemplo:** "Mi_WiFi_Casa"
  ///
  /// Envía el nombre de la red WiFi a la que el ESP32 debe conectarse.
  static const String esp32SsidCharUuid =
      '0000bd9a-7856-3412-3412-341278563412';

  /// Característica Password - Enviar contraseña WiFi
  ///
  /// **Propiedades:** READ | WRITE_NO_RESPONSE
  /// **Formato:** String UTF-8
  /// **Longitud máxima:** 64 bytes (límite WPA2)
  /// **Ejemplo:** "MiPassword123"
  ///
  /// Envía la contraseña de la red WiFi. Para redes abiertas, enviar string vacío.
  static const String esp32PasswordCharUuid =
      '0000be9a-7856-3412-3412-341278563412';

  /// Característica Status - Monitorear estado de conexión WiFi
  ///
  /// **Propiedades:** READ | NOTIFY
  /// **Formato:** String UTF-8
  /// **Valores posibles:**
  /// - `"IDLE"` - Esperando configuración
  /// - `"CONNECTING"` - Intentando conectar a WiFi
  /// - `"CONNECTED"` - WiFi conectado exitosamente (obtener IP)
  /// - `"RECONNECTING"` - Reintentando conexión
  /// - `"FAILED"` - Conexión fallida (credenciales incorrectas o red no disponible)
  ///
  /// El ESP32 notifica automáticamente cambios de estado.
  static const String esp32StatusCharUuid =
      '0000bf9a-7856-3412-3412-341278563412';

  /// Característica Device ID - Identificador único del ESP32
  ///
  /// **Propiedades:** READ | NOTIFY
  /// **Formato:** String UTF-8
  /// **Longitud:** 24 bytes fijos
  /// **Formato:** "ESP32_XXXXXXXXXXXX"
  /// **Ejemplo:** "ESP32_8CBFEA877D0C"
  ///
  /// **Generación:** Basado en la MAC address del ESP32 (único por dispositivo)
  ///
  /// **Flujo:**
  /// 1. ESP32 envía Device ID automáticamente al conectar (NOTIFY)
  /// 2. App guarda localmente el Device ID
  /// 3. Cuando WiFi conecta, app registra Device ID en backend
  ///
  /// **Importante:** Este ID es permanente y único - usarlo para vincular
  /// el dispositivo físico con la cuenta del usuario.
  static const String esp32DeviceIdCharUuid =
      '0000c09a-7856-3412-3412-341278563412';

  // ============================================================================
  // NOMBRES DE DISPOSITIVOS
  // ============================================================================

  /// Nombre BLE del dispositivo ESP32 durante configuración WiFi
  /// Usado para filtrar dispositivos durante escaneo BLE
  static const String esp32DeviceName = 'ESP32-WiFi-Config';

  // ============================================================================
  // DESCRIPTOR ESTÁNDAR (CCCD)
  // ============================================================================

  /// UUID del descriptor CCCD (Client Characteristic Configuration Descriptor)
  /// Usado para habilitar/deshabilitar notificaciones en características BLE
  static const String cccdDescriptorUuid =
      '00002902-0000-1000-8000-00805f9b34fb';
}
