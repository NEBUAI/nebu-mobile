import 'dart:async';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

/// Red WiFi
class WiFiNetwork {
  const WiFiNetwork({
    required this.ssid,
    required this.rssi,
    required this.security,
    required this.frequency,
    this.isConnected = false,
  });

  factory WiFiNetwork.fromJson(Map<String, dynamic> json) => WiFiNetwork(
    ssid: json['ssid'] as String,
    rssi: json['rssi'] as int,
    security: json['security'] as String,
    frequency: json['frequency'] as int,
    isConnected: json['isConnected'] as bool? ?? false,
  );
  final String ssid;
  final int rssi;
  final String security; // 'Open' | 'WPA' | 'WPA2' | 'WPA3' | 'WEP'
  final int frequency;
  final bool isConnected;

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'rssi': rssi,
    'security': security,
    'frequency': frequency,
    'isConnected': isConnected,
  };
}

/// Credenciales WiFi
class WiFiCredentials {
  const WiFiCredentials({required this.ssid, required this.password});

  factory WiFiCredentials.fromJson(Map<String, dynamic> json) =>
      WiFiCredentials(
        ssid: json['ssid'] as String,
        password: json['password'] as String,
      );
  final String ssid;
  final String password;

  Map<String, dynamic> toJson() => {'ssid': ssid, 'password': password};
}

/// Resultado de conexión WiFi
class WiFiConnectionResult {
  const WiFiConnectionResult({
    required this.success,
    required this.message,
    this.connectedNetwork,
  });

  factory WiFiConnectionResult.fromJson(Map<String, dynamic> json) =>
      WiFiConnectionResult(
        success: json['success'] as bool,
        message: json['message'] as String,
        connectedNetwork: json['connectedNetwork'] != null
            ? WiFiNetwork.fromJson(
                json['connectedNetwork'] as Map<String, dynamic>,
              )
            : null,
      );
  final bool success;
  final String message;
  final WiFiNetwork? connectedNetwork;

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'connectedNetwork': connectedNetwork?.toJson(),
  };
}

/// Servicio WiFi
class WiFiService {
  WiFiService({required Logger logger}) : _logger = logger;
  final Logger _logger;

  bool _isScanning = false;
  WiFiNetwork? _currentNetwork;

  // Streams para notificaciones
  final StreamController<List<WiFiNetwork>> _networksController =
      StreamController<List<WiFiNetwork>>.broadcast();
  final StreamController<WiFiConnectionResult> _connectionController =
      StreamController<WiFiConnectionResult>.broadcast();

  /// Escanear redes WiFi disponibles
  Future<List<WiFiNetwork>> scanNetworks() async {
    if (_isScanning) {
      _logger.w('WiFi scan already in progress');
      return [];
    }

    try {
      _isScanning = true;

      // Solicitar permisos de ubicación (necesario para escanear WiFi en Android)
      final locationPermission = await Permission.location.request();
      if (!locationPermission.isGranted) {
        throw Exception('Location permission required for WiFi scanning');
      }

      final wifiScan = WiFiScan.instance;

      // Verificar si el escaneo esta soportado
      final canStartScan = await wifiScan.canStartScan();
      if (canStartScan != CanStartScan.yes) {
        _logger.w('WiFi scan not supported: $canStartScan');
        throw Exception('WiFi scanning is not supported on this device');
      }

      // Iniciar escaneo
      final startResult = await wifiScan.startScan();
      if (!startResult) {
        _logger.w('WiFi scan failed to start');
        throw Exception('Failed to start WiFi scan');
      }

      // Esperar a que el OS complete el escaneo
      await Future<void>.delayed(const Duration(seconds: 3));

      // Obtener resultados
      final canGetResults = await wifiScan.canGetScannedResults();
      if (canGetResults != CanGetScannedResults.yes) {
        _logger.w('Cannot get scan results: $canGetResults');
        throw Exception('Cannot retrieve WiFi scan results');
      }

      final accessPoints = await wifiScan.getScannedResults();

      // Mapear a WiFiNetwork, filtrar SSIDs vacios, 5GHz y deduplicar
      final networkMap = <String, WiFiNetwork>{};
      for (final ap in accessPoints) {
        if (ap.ssid.isEmpty) {
          continue;
        }
        // ESP32 solo soporta 2.4GHz (frecuencias < 3000 MHz)
        if (ap.frequency >= 3000) {
          continue;
        }
        final existing = networkMap[ap.ssid];
        if (existing == null || ap.level > existing.rssi) {
          networkMap[ap.ssid] = WiFiNetwork(
            ssid: ap.ssid,
            rssi: ap.level,
            security: ap.capabilities.contains('WPA3')
                ? 'WPA3'
                : ap.capabilities.contains('WPA2')
                    ? 'WPA2'
                    : ap.capabilities.contains('WPA')
                        ? 'WPA'
                        : ap.capabilities.contains('WEP')
                            ? 'WEP'
                            : 'Open',
            frequency: ap.frequency,
          );
        }
      }

      final networks = networkMap.values.toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));

      _logger.i('Found ${networks.length} WiFi networks');
      _networksController.add(networks);
      return networks;
    } catch (e) {
      _logger.e('Error scanning WiFi networks: $e');
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  /// Conectar a una red WiFi
  Future<WiFiConnectionResult> connectToNetwork(
    WiFiCredentials credentials,
  ) async {
    try {
      // TODO(dev): Implement actual WiFi connection using a native plugin
      // This functionality requires system permissions and appropriate plugin
      _logger
        ..i('Attempting to connect to WiFi: ${credentials.ssid}')
        ..w('WiFi connection not implemented - requires native plugin');

      const result = WiFiConnectionResult(
        success: false,
        message:
            'WiFi connection not implemented. Use backend API to configure robot WiFi.',
      );

      _connectionController.add(result);

      throw UnimplementedError(
        'WiFi connection requires a native plugin or should be handled via backend API. '
        'For robot WiFi configuration, use RobotService.configureWiFi() instead.',
      );
    } on Exception catch (e) {
      _logger.e('Error connecting to WiFi: $e');
      final result = WiFiConnectionResult(
        success: false,
        message: 'Connection failed: $e',
      );

      _connectionController.add(result);
      return result;
    }
  }

  /// Desconectar de la red actual
  Future<void> disconnect() async {
    try {
      _logger.i('Disconnecting from WiFi');

      // Simular desconexión
      await Future<void>.delayed(const Duration(seconds: 1));

      _currentNetwork = null;

      const result = WiFiConnectionResult(
        success: true,
        message: 'Disconnected from WiFi',
      );

      _connectionController.add(result);
      _logger.i('WiFi disconnected');
    } catch (e) {
      _logger.e('Error disconnecting from WiFi: $e');
      rethrow;
    }
  }

  /// Obtener red actual conectada
  WiFiNetwork? get currentNetwork => _currentNetwork;

  /// Verificar si está conectado
  bool get isConnected => _currentNetwork != null;

  /// Verificar si está escaneando
  bool get isScanning => _isScanning;

  /// Obtener información de la red actual
  Map<String, dynamic>? get currentNetworkInfo {
    if (_currentNetwork == null) {
      return null;
    }

    return {
      'ssid': _currentNetwork!.ssid,
      'rssi': _currentNetwork!.rssi,
      'security': _currentNetwork!.security,
      'frequency': _currentNetwork!.frequency,
      'signalStrength': _getSignalStrength(_currentNetwork!.rssi),
      'isConnected': true,
    };
  }

  /// Calcular fuerza de señal basada en RSSI
  String _getSignalStrength(int rssi) {
    if (rssi >= -30) {
      return 'Excelente';
    }
    if (rssi >= -50) {
      return 'Buena';
    }
    if (rssi >= -70) {
      return 'Regular';
    }
    if (rssi >= -80) {
      return 'Débil';
    }
    return 'Muy débil';
  }

  /// Stream de redes encontradas
  Stream<List<WiFiNetwork>> get networksStream => _networksController.stream;

  /// Stream de resultados de conexión
  Stream<WiFiConnectionResult> get connectionStream =>
      _connectionController.stream;

  /// Verificar permisos necesarios
  Future<bool> checkPermissions() async {
    try {
      final locationPermission = await Permission.location.status;

      return locationPermission.isGranted;
    } on Exception catch (e) {
      _logger.e('Error checking permissions: $e');
      return false;
    }
  }

  /// Solicitar permisos necesarios
  Future<bool> requestPermissions() async {
    try {
      final locationStatus = await Permission.location.request();

      if (!locationStatus.isGranted) {
        _logger.w('Location permission was not granted');
      }

      return locationStatus.isGranted;
    } on Exception catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  /// Cerrar servicio
  Future<void> dispose() async {
    await _networksController.close();
    await _connectionController.close();
    _logger.i('WiFi Service disposed');
  }
}
