import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import 'bluetooth_service.dart';

/// Estado de conexión WiFi del ESP32
enum ESP32WifiStatus {
  idle('IDLE'),
  connecting('CONNECTING'),
  connected('CONNECTED'),
  reconnecting('RECONNECTING'),
  failed('FAILED');

  const ESP32WifiStatus(this.value);
  final String value;

  static ESP32WifiStatus fromString(String value) =>
      ESP32WifiStatus.values.firstWhere(
        (status) => status.value == value.toUpperCase(),
        orElse: () => ESP32WifiStatus.idle,
      );
}

/// Resultado de configuración WiFi del ESP32
class ESP32WifiConfigResult {
  const ESP32WifiConfigResult({
    required this.success,
    required this.message,
    this.status,
  });

  final bool success;
  final String message;
  final ESP32WifiStatus? status;
}

/// Servicio para configurar WiFi en dispositivos ESP32 via BLE
class ESP32WifiConfigService {
  ESP32WifiConfigService({
    required BluetoothService bluetoothService,
    required Logger logger,
    required SharedPreferences prefs,
  }) : _bluetoothService = bluetoothService,
       _logger = logger,
       _prefs = prefs,
       _statusController = StreamController<ESP32WifiStatus>.broadcast(),
       _deviceIdController = StreamController<String>.broadcast();

  final BluetoothService _bluetoothService;
  final Logger _logger;
  final SharedPreferences _prefs;
  final StreamController<ESP32WifiStatus> _statusController;
  final StreamController<String> _deviceIdController;

  fbp.BluetoothCharacteristic? _ssidCharacteristic;
  fbp.BluetoothCharacteristic? _passwordCharacteristic;
  fbp.BluetoothCharacteristic? _statusCharacteristic;
  fbp.BluetoothCharacteristic? _deviceIdCharacteristic;
  StreamSubscription<List<int>>? _statusSubscription;
  StreamSubscription<List<int>>? _deviceIdSubscription;
  String? _currentDeviceId;

  /// Stream del estado de conexión WiFi del ESP32
  Stream<ESP32WifiStatus> get statusStream => _statusController.stream;

  /// Stream del Device ID del ESP32
  Stream<String> get deviceIdStream => _deviceIdController.stream;

  /// Device ID actual del ESP32 (null si no se ha recibido aún)
  String? get deviceId => _currentDeviceId;

  /// Conectar a un ESP32 y preparar las características
  Future<void> connectToESP32(fbp.BluetoothDevice device) async {
    try {
      _logger.i(
        '🔵 [ESP32] Connecting to: ${device.platformName} (${device.remoteId})',
      );

      // Conectar al dispositivo usando el servicio principal
      if (!_bluetoothService.isConnected ||
          _bluetoothService.connectedDevice?.remoteId != device.remoteId) {
        _logger.d('🔵 [ESP32] Device not connected, connecting now...');
        await _bluetoothService.connect(device);
        _logger.i('🔵 [ESP32] Device connected successfully');
      } else {
        _logger.d('🔵 [ESP32] Device already connected, reusing connection');
      }

      _logger.d('🔍 [ESP32] Waiting 500ms for ESP32 to prepare services...');
      // Esperar un poco para que el ESP32 prepare sus servicios
      await Future<void>.delayed(const Duration(milliseconds: 500));

      _logger.i('🔍 [ESP32] Starting service discovery (forced refresh)...');
      // Forzar refresh para asegurar que obtenemos servicios actualizados
      final services = await _bluetoothService.discoverServicesForDevice(
        device,
        forceRefresh: true,
      );

      // Log all discovered services for debugging
      _logger.i('✅ [ESP32] Discovered ${services.length} total services:');
      for (final service in services) {
        _logger.i('  📦 Service UUID: ${service.uuid}');
        if (service.characteristics.isNotEmpty) {
          _logger.i(
            '     └─ Characteristics (${service.characteristics.length}):',
          );
          for (final char in service.characteristics) {
            final props = <String>[];
            if (char.properties.read) {
              props.add('READ');
            }
            if (char.properties.write) {
              props.add('WRITE');
            }
            if (char.properties.writeWithoutResponse) {
              props.add('WRITE_NO_RSP');
            }
            if (char.properties.notify) {
              props.add('NOTIFY');
            }
            if (char.properties.indicate) {
              props.add('INDICATE');
            }
            _logger.i('        • ${char.uuid} [${props.join(', ')}]');
          }
        }
      }

      // Buscar el servicio de configuración WiFi
      _logger.i(
        '🔍 [ESP32] Searching for WiFi service: ${AppConstants.esp32WifiServiceUuid}',
      );

      final wifiService = services.firstWhere(
        (service) =>
            service.uuid.toString().toLowerCase() ==
            AppConstants.esp32WifiServiceUuid.toLowerCase(),
        orElse: () {
          _logger.e('❌ [ESP32] WiFi service NOT found!');
          _logger.e(
            '❌ [ESP32] Available services: ${services.map((s) => s.uuid).join(', ')}',
          );
          throw Exception('WiFi configuration service not found');
        },
      );

      _logger.i('✅ [ESP32] Found WiFi configuration service!');

      // Obtener las características
      _logger.d(
        '🔍 [ESP32] Looking for SSID characteristic: ${AppConstants.esp32SsidCharUuid}',
      );
      _ssidCharacteristic = wifiService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            AppConstants.esp32SsidCharUuid.toLowerCase(),
        orElse: () {
          _logger.e('❌ [ESP32] SSID characteristic NOT found!');
          throw Exception('SSID characteristic not found');
        },
      );
      _logger.i('✅ [ESP32] Found SSID characteristic');
      _logger.d(
        '   Properties: READ=${_ssidCharacteristic!.properties.read}, '
        'WRITE=${_ssidCharacteristic!.properties.write}, '
        'WRITE_NO_RSP=${_ssidCharacteristic!.properties.writeWithoutResponse}, '
        'NOTIFY=${_ssidCharacteristic!.properties.notify}',
      );

      _logger.d(
        '🔍 [ESP32] Looking for Password characteristic: ${AppConstants.esp32PasswordCharUuid}',
      );
      _passwordCharacteristic = wifiService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            AppConstants.esp32PasswordCharUuid.toLowerCase(),
        orElse: () {
          _logger.e('❌ [ESP32] Password characteristic NOT found!');
          throw Exception('Password characteristic not found');
        },
      );
      _logger.i('✅ [ESP32] Found Password characteristic');
      _logger.d(
        '   Properties: READ=${_passwordCharacteristic!.properties.read}, '
        'WRITE=${_passwordCharacteristic!.properties.write}, '
        'WRITE_NO_RSP=${_passwordCharacteristic!.properties.writeWithoutResponse}, '
        'NOTIFY=${_passwordCharacteristic!.properties.notify}',
      );

      // Status characteristic es opcional
      _logger.d(
        '🔍 [ESP32] Looking for Status characteristic: ${AppConstants.esp32StatusCharUuid}',
      );
      final statusChars = wifiService.characteristics.where(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            AppConstants.esp32StatusCharUuid.toLowerCase(),
      );
      _statusCharacteristic = statusChars.isNotEmpty ? statusChars.first : null;

      if (_statusCharacteristic != null) {
        _logger.i('✅ [ESP32] Found Status characteristic');
      } else {
        _logger.w('⚠️  [ESP32] Status characteristic not found (optional)');
      }

      // Suscribirse a notificaciones de estado si está disponible
      if (_statusCharacteristic != null &&
          _statusCharacteristic!.properties.notify) {
        _logger.d(
          '🔔 [ESP32] Status characteristic supports NOTIFY, subscribing...',
        );
        await _subscribeToStatus();
      } else if (_statusCharacteristic != null) {
        _logger.w('⚠️  [ESP32] Status characteristic does NOT support NOTIFY');
      }

      // Device ID characteristic
      _logger.d(
        '🔍 [ESP32] Looking for Device ID characteristic: ${AppConstants.esp32DeviceIdCharUuid}',
      );
      final deviceIdChars = wifiService.characteristics.where(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            AppConstants.esp32DeviceIdCharUuid.toLowerCase(),
      );
      _deviceIdCharacteristic =
          deviceIdChars.isNotEmpty ? deviceIdChars.first : null;

      if (_deviceIdCharacteristic != null) {
        _logger.i('✅ [ESP32] Found Device ID characteristic');
        _logger.d(
          '   Properties: READ=${_deviceIdCharacteristic!.properties.read}, '
          'NOTIFY=${_deviceIdCharacteristic!.properties.notify}',
        );

        // Suscribirse a notificaciones de Device ID
        if (_deviceIdCharacteristic!.properties.notify) {
          _logger.d(
            '🔔 [ESP32] Device ID characteristic supports NOTIFY, subscribing...',
          );
          await _subscribeToDeviceId();
        }

        // También leer el Device ID inmediatamente
        if (_deviceIdCharacteristic!.properties.read) {
          _logger.d('📖 [ESP32] Reading Device ID immediately...');
          await readDeviceId();
        }
      } else {
        _logger.w('⚠️  [ESP32] Device ID characteristic not found');
      }

      _logger.i('🎉 [ESP32] ESP32 connected and ready for WiFi configuration!');
    } catch (e, stackTrace) {
      _logger.e('❌ [ESP32] Error connecting to ESP32: $e');
      _logger.e('❌ [ESP32] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Enviar credenciales WiFi al ESP32
  Future<ESP32WifiConfigResult> sendWifiCredentials({
    required String ssid,
    required String password,
  }) async {
    try {
      if (_ssidCharacteristic == null || _passwordCharacteristic == null) {
        _logger.e('❌ [WIFI] Characteristics not ready!');
        throw Exception(
          'Characteristics not ready. Was connectToESP32 called?',
        );
      }

      _logger.i('📡 [WIFI] Sending WiFi credentials to ESP32...');
      _logger.d('📡 [WIFI] SSID: "$ssid" (${ssid.length} chars)');
      _logger.d(
        '📡 [WIFI] Password: [${password.isNotEmpty ? '${password.length} chars (hidden)' : 'empty'}]',
      );

      // Convertir SSID y password a bytes (UTF-8)
      final ssidBytes = utf8.encode(ssid);
      final passwordBytes = utf8.encode(password);

      _logger.d('📡 [WIFI] SSID bytes: ${ssidBytes.length} bytes');
      _logger.d('📡 [WIFI] Password bytes: ${passwordBytes.length} bytes');

      // Determinar el modo de escritura basado en las propiedades
      // Solo usar WRITE_WITHOUT_RESPONSE si la característica lo soporta
      final useWriteWithoutResponse =
          _ssidCharacteristic!.properties.writeWithoutResponse;
      _logger.d(
        '📤 [WIFI] Write mode: ${useWriteWithoutResponse ? 'WRITE_WITHOUT_RESPONSE' : 'WRITE'}',
      );
      _logger.d(
        '📤 [WIFI] Characteristic supports: WRITE=${_ssidCharacteristic!.properties.write}, '
        'WRITE_NO_RSP=${_ssidCharacteristic!.properties.writeWithoutResponse}',
      );

      // Enviar SSID
      _logger.d('📤 [WIFI] Writing SSID to characteristic...');
      await _bluetoothService.writeCharacteristic(
        _ssidCharacteristic!,
        ssidBytes,
        withoutResponse: useWriteWithoutResponse,
      );
      _logger.i('✅ [WIFI] SSID sent successfully');

      // Pequeña pausa entre escrituras
      _logger.d('⏱️  [WIFI] Waiting 100ms before sending password...');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Enviar Password
      _logger.d('📤 [WIFI] Writing Password to characteristic...');
      await _bluetoothService.writeCharacteristic(
        _passwordCharacteristic!,
        passwordBytes,
        withoutResponse: useWriteWithoutResponse,
      );
      _logger.i('✅ [WIFI] Password sent successfully');

      _logger.i(
        '🎉 [WIFI] WiFi credentials sent successfully! ESP32 should now attempt connection.',
      );

      return const ESP32WifiConfigResult(
        success: true,
        message: 'WiFi credentials sent to ESP32',
      );
    } on Exception catch (e, stackTrace) {
      _logger.e('❌ [WIFI] Error sending WiFi credentials: $e');
      _logger.e('❌ [WIFI] Stack trace: $stackTrace');
      return ESP32WifiConfigResult(
        success: false,
        message: 'Failed to send credentials: $e',
      );
    }
  }

  /// Leer el estado actual de conexión WiFi del ESP32
  Future<ESP32WifiStatus> readWifiStatus() async {
    if (_statusCharacteristic == null) {
      _logger.w('⚠️  [STATUS] Status characteristic not available');
      return ESP32WifiStatus.idle;
    }

    try {
      _logger.d('📖 [STATUS] Reading WiFi status from ESP32...');
      final statusBytes = await _bluetoothService.readCharacteristic(
        _statusCharacteristic!,
      );

      if (statusBytes.isEmpty) {
        _logger.w('⚠️  [STATUS] Empty status response');
        return ESP32WifiStatus.idle;
      }

      final statusString = utf8.decode(statusBytes, allowMalformed: true).trim();
      final status = ESP32WifiStatus.fromString(statusString);
      _logger.i('📖 [STATUS] ESP32 WiFi status: $status (value: "$statusString")');
      return status;
    } on Exception catch (e, stackTrace) {
      _logger.e('❌ [STATUS] Error reading WiFi status: $e');
      _logger.e('❌ [STATUS] Stack trace: $stackTrace');
      return ESP32WifiStatus.idle;
    }
  }

  /// Suscribirse a notificaciones de estado del ESP32
  Future<void> _subscribeToStatus() async {
    if (_statusCharacteristic == null) {
      return;
    }

    try {
      _logger.i('🔔 [STATUS] Subscribing to WiFi status notifications...');
      await _statusCharacteristic!.setNotifyValue(true);
      _statusSubscription = _statusCharacteristic!.lastValueStream.listen((
        value,
      ) {
        if (value.isNotEmpty) {
          final statusString = utf8.decode(value, allowMalformed: true).trim();
          final status = ESP32WifiStatus.fromString(statusString);
          _logger.i(
            '🔔 [STATUS] ESP32 WiFi status update: $status (value: "$statusString")',
          );

          switch (status) {
            case ESP32WifiStatus.idle:
              _logger.d('🔔 [STATUS] ESP32 is IDLE');
              break;
            case ESP32WifiStatus.connecting:
              _logger.i('🔔 [STATUS] ESP32 is CONNECTING to WiFi...');
              break;
            case ESP32WifiStatus.connected:
              _logger.i('✅ [STATUS] ESP32 CONNECTED to WiFi successfully!');
              break;
            case ESP32WifiStatus.reconnecting:
              _logger.i('🔄 [STATUS] ESP32 is RECONNECTING to WiFi...');
              break;
            case ESP32WifiStatus.failed:
              _logger.e('❌ [STATUS] ESP32 FAILED to connect to WiFi');
              break;
          }

          _statusController.add(status);
        } else {
          _logger.w('⚠️  [STATUS] Received empty status notification');
        }
      });
      _logger.i('✅ [STATUS] Subscribed to WiFi status notifications');
    } on Exception catch (e, stackTrace) {
      _logger.e('❌ [STATUS] Error subscribing to status notifications: $e');
      _logger.e('❌ [STATUS] Stack trace: $stackTrace');
    }
  }

  /// Leer el Device ID del ESP32
  Future<String?> readDeviceId() async {
    if (_deviceIdCharacteristic == null) {
      _logger.w('⚠️  [DEVICE_ID] Device ID characteristic not available');
      return null;
    }

    try {
      _logger.d('📖 [DEVICE_ID] Reading Device ID from ESP32...');
      final deviceIdBytes = await _bluetoothService.readCharacteristic(
        _deviceIdCharacteristic!,
      );

      if (deviceIdBytes.isEmpty) {
        _logger.w('⚠️  [DEVICE_ID] Empty Device ID response');
        return null;
      }

      final deviceId = utf8.decode(deviceIdBytes, allowMalformed: true).trim();
      _logger.i('📖 [DEVICE_ID] ESP32 Device ID: "$deviceId"');

      // Guardar el Device ID en memoria y persistencia
      _currentDeviceId = deviceId;
      await _saveDeviceId(deviceId);
      _deviceIdController.add(deviceId);

      return deviceId;
    } on Exception catch (e, stackTrace) {
      _logger.e('❌ [DEVICE_ID] Error reading Device ID: $e');
      _logger.e('❌ [DEVICE_ID] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Suscribirse a notificaciones de Device ID del ESP32
  Future<void> _subscribeToDeviceId() async {
    if (_deviceIdCharacteristic == null) {
      return;
    }

    try {
      _logger.i('🔔 [DEVICE_ID] Subscribing to Device ID notifications...');
      await _deviceIdCharacteristic!.setNotifyValue(true);
      _deviceIdSubscription =
          _deviceIdCharacteristic!.lastValueStream.listen((value) async {
        if (value.isNotEmpty) {
          final deviceId = utf8.decode(value, allowMalformed: true).trim();
          _logger.i('🔔 [DEVICE_ID] Device ID notification: "$deviceId"');

          // Guardar el Device ID en memoria y persistencia
          _currentDeviceId = deviceId;
          await _saveDeviceId(deviceId);
          _deviceIdController.add(deviceId);
        } else {
          _logger.w('⚠️  [DEVICE_ID] Received empty Device ID notification');
        }
      });
      _logger.i('✅ [DEVICE_ID] Subscribed to Device ID notifications');
    } on Exception catch (e, stackTrace) {
      _logger.e('❌ [DEVICE_ID] Error subscribing to Device ID: $e');
      _logger.e('❌ [DEVICE_ID] Stack trace: $stackTrace');
    }
  }

  /// Guardar Device ID en SharedPreferences
  Future<void> _saveDeviceId(String deviceId) async {
    try {
      await _prefs.setString(AppConstants.keyCurrentDeviceId, deviceId);
      _logger.d('💾 [DEVICE_ID] Device ID saved to local storage: "$deviceId"');
    } on Exception catch (e) {
      _logger.e('❌ [DEVICE_ID] Error saving Device ID: $e');
    }
  }

  /// Recuperar Device ID almacenado localmente
  String? getSavedDeviceId() {
    try {
      final deviceId = _prefs.getString(AppConstants.keyCurrentDeviceId);
      if (deviceId != null) {
        _logger.d('📂 [DEVICE_ID] Retrieved saved Device ID: "$deviceId"');
      }
      return deviceId;
    } on Exception catch (e) {
      _logger.e('❌ [DEVICE_ID] Error retrieving Device ID: $e');
      return null;
    }
  }

  /// Limpiar Device ID almacenado
  Future<void> clearSavedDeviceId() async {
    try {
      await _prefs.remove(AppConstants.keyCurrentDeviceId);
      _currentDeviceId = null;
      _logger.d('🗑️  [DEVICE_ID] Device ID cleared from local storage');
    } on Exception catch (e) {
      _logger.e('❌ [DEVICE_ID] Error clearing Device ID: $e');
    }
  }

  /// Desconectar del ESP32
  Future<void> disconnect() async {
    try {
      _logger.i('🔌 [ESP32] Disconnecting from ESP32...');

      await _statusSubscription?.cancel();
      _statusSubscription = null;

      await _deviceIdSubscription?.cancel();
      _deviceIdSubscription = null;

      _ssidCharacteristic = null;
      _passwordCharacteristic = null;
      _statusCharacteristic = null;
      _deviceIdCharacteristic = null;
      _currentDeviceId = null;

      await _bluetoothService.disconnect();
      _logger.i('✅ [ESP32] Disconnected from ESP32');
    } on Exception catch (e, stackTrace) {
      _logger.e('❌ [ESP32] Error disconnecting from ESP32: $e');
      _logger.e('❌ [ESP32] Stack trace: $stackTrace');
    }
  }

  /// Limpiar recursos
  void dispose() {
    _statusSubscription?.cancel();
    _deviceIdSubscription?.cancel();
    _statusController.close();
    _deviceIdController.close();
  }
}
