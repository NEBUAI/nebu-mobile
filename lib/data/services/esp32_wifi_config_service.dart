import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import 'bluetooth_service.dart';

/// Estado de conexión WiFi del ESP32
enum ESP32WifiStatus {
  idle(0),
  connecting(1),
  connected(2),
  failed(3);

  const ESP32WifiStatus(this.value);
  final int value;

  static ESP32WifiStatus fromValue(int value) =>
      ESP32WifiStatus.values.firstWhere(
        (status) => status.value == value,
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
  })  : _bluetoothService = bluetoothService,
        _logger = logger,
        _statusController = StreamController<ESP32WifiStatus>.broadcast();

  final BluetoothService _bluetoothService;
  final Logger _logger;
  final StreamController<ESP32WifiStatus> _statusController;

  fbp.BluetoothCharacteristic? _ssidCharacteristic;
  fbp.BluetoothCharacteristic? _passwordCharacteristic;
  fbp.BluetoothCharacteristic? _statusCharacteristic;
  StreamSubscription<List<int>>? _statusSubscription;

  /// Stream del estado de conexión WiFi del ESP32
  Stream<ESP32WifiStatus> get statusStream => _statusController.stream;

  /// Escanear dispositivos ESP32 con servicio de configuración WiFi
  Future<List<fbp.BluetoothDevice>> scanForESP32Devices({
    Duration? timeout,
  }) async {
    try {
      _logger.i('Scanning for ESP32 devices with WiFi config service...');

      // Iniciar escaneo normal
      await _bluetoothService.startScan(timeout: timeout);

      // Esperar a que termine el escaneo
      await Future<void>.delayed(
        timeout ?? AppConstants.scanTimeout,
      );

      // Obtener todos los resultados del escaneo
      final scanResults = await fbp.FlutterBluePlus.scanResults.first;

      // Filtrar dispositivos que tengan el servicio de configuración WiFi
      final esp32Devices = <fbp.BluetoothDevice>[];

      for (final result in scanResults) {
        // Verificar si el dispositivo tiene el servicio UUID del ESP32
        final hasWifiService = result.advertisementData.serviceUuids.any(
          (uuid) =>
              uuid.toString().toLowerCase() ==
              AppConstants.esp32WifiServiceUuid.toLowerCase(),
        );

        if (hasWifiService) {
          _logger.d(
            'Found ESP32 device: ${result.device.platformName} (${result.device.remoteId})',
          );
          esp32Devices.add(result.device);
        }
      }

      await _bluetoothService.stopScan();

      _logger.i('Found ${esp32Devices.length} ESP32 devices with WiFi config service');

      return esp32Devices;
    } catch (e) {
      _logger.e('Error scanning for ESP32 devices: $e');
      rethrow;
    }
  }

  /// Conectar a un ESP32 y preparar las características
  Future<void> connectToESP32(fbp.BluetoothDevice device) async {
    try {
      _logger.i('Connecting to ESP32: ${device.platformName}');

      // Conectar al dispositivo
      await _bluetoothService.connect(device);

      // Descubrir servicios
      final services = await _bluetoothService.discoverServices();

      // Buscar el servicio de configuración WiFi
      final wifiService = services.firstWhere(
        (service) =>
            service.uuid.toString().toLowerCase() ==
            AppConstants.esp32WifiServiceUuid.toLowerCase(),
        orElse: () => throw Exception('WiFi configuration service not found'),
      );

      _logger.d('Found WiFi configuration service');

      // Obtener las características
      for (final characteristic in wifiService.characteristics) {
        final uuid = characteristic.uuid.toString().toLowerCase();

        if (uuid == AppConstants.esp32SsidCharUuid.toLowerCase()) {
          _ssidCharacteristic = characteristic;
          _logger.d('Found SSID characteristic');
        } else if (uuid == AppConstants.esp32PasswordCharUuid.toLowerCase()) {
          _passwordCharacteristic = characteristic;
          _logger.d('Found Password characteristic');
        } else if (uuid == AppConstants.esp32StatusCharUuid.toLowerCase()) {
          _statusCharacteristic = characteristic;
          _logger.d('Found Status characteristic');

          // Suscribirse a notificaciones de estado si está disponible
          if (characteristic.properties.notify) {
            await _subscribeToStatus();
          }
        }
      }

      // Verificar que todas las características necesarias están disponibles
      if (_ssidCharacteristic == null || _passwordCharacteristic == null) {
        throw Exception('Required characteristics not found');
      }

      _logger.i('ESP32 connected and ready for WiFi configuration');
    } catch (e) {
      _logger.e('Error connecting to ESP32: $e');
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
        throw Exception('Not connected to ESP32 or characteristics not found');
      }

      _logger
        ..i('Sending WiFi credentials to ESP32...')
        ..d('SSID: $ssid');

      // Convertir SSID y password a bytes (UTF-8)
      final ssidBytes = utf8.encode(ssid);
      final passwordBytes = utf8.encode(password);

      // Enviar SSID
      _logger.d('Writing SSID to characteristic...');
      await _bluetoothService.writeCharacteristic(
        _ssidCharacteristic!,
        ssidBytes,
      );

      // Pequeña pausa entre escrituras
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Enviar Password
      _logger.d('Writing password to characteristic...');
      await _bluetoothService.writeCharacteristic(
        _passwordCharacteristic!,
        passwordBytes,
      );

      _logger.i('WiFi credentials sent successfully');

      return const ESP32WifiConfigResult(
        success: true,
        message: 'WiFi credentials sent to ESP32',
      );
    } on Exception catch (e) {
      _logger.e('Error sending WiFi credentials: $e');
      return ESP32WifiConfigResult(
        success: false,
        message: 'Failed to send credentials: $e',
      );
    }
  }

  /// Leer el estado actual de conexión WiFi del ESP32
  Future<ESP32WifiStatus> readWifiStatus() async {
    try {
      if (_statusCharacteristic == null) {
        _logger.w('Status characteristic not available');
        return ESP32WifiStatus.idle;
      }

      _logger.d('Reading WiFi status from ESP32...');

      final statusBytes = await _bluetoothService.readCharacteristic(
        _statusCharacteristic!,
      );

      if (statusBytes.isEmpty) {
        _logger.w('Empty status response');
        return ESP32WifiStatus.idle;
      }

      final statusValue = statusBytes[0];
      final status = ESP32WifiStatus.fromValue(statusValue);

      _logger.d('ESP32 WiFi status: $status');

      return status;
    } on Exception catch (e) {
      _logger.e('Error reading WiFi status: $e');
      return ESP32WifiStatus.idle;
    }
  }

  /// Suscribirse a notificaciones de estado del ESP32
  Future<void> _subscribeToStatus() async {
    try {
      if (_statusCharacteristic == null) {
        _logger.w('Status characteristic not available for subscription');
        return;
      }

      _logger.d('Subscribing to WiFi status notifications...');

      _statusSubscription = _bluetoothService.subscribeToCharacteristic(
        _statusCharacteristic!,
        (value) {
          if (value.isNotEmpty) {
            final statusValue = value[0];
            final status = ESP32WifiStatus.fromValue(statusValue);

            _logger.d('ESP32 WiFi status update: $status');
            _statusController.add(status);
          }
        },
      );

      _logger.i('Subscribed to WiFi status notifications');
    } on Exception catch (e) {
      _logger.e('Error subscribing to status notifications: $e');
    }
  }

  /// Desconectar del ESP32
  Future<void> disconnect() async {
    try {
      await _statusSubscription?.cancel();
      _statusSubscription = null;

      _ssidCharacteristic = null;
      _passwordCharacteristic = null;
      _statusCharacteristic = null;

      await _bluetoothService.disconnect();

      _logger.i('Disconnected from ESP32');
    } on Exception catch (e) {
      _logger.e('Error disconnecting from ESP32: $e');
    }
  }

  /// Limpiar recursos
  void dispose() {
    _statusSubscription?.cancel();
    _statusController.close();
  }
}
