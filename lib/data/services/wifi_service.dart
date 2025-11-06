import 'dart:async';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

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

      // TODO: Implementar escaneo real de redes WiFi usando un plugin nativo
      // Por ahora, retornar lista vacía hasta que se implemente
      // Se necesita un plugin como 'wifi_scan' o 'wifi_iot' para funcionalidad real

      _logger.w('WiFi scanning not implemented - requires native plugin');

      final networks = <WiFiNetwork>[];
      _networksController.add(networks);

      throw UnimplementedError(
        'WiFi scanning requires a native plugin. '
        'Please implement using wifi_scan or wifi_iot package.',
      );
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
      _logger.i('Attempting to connect to WiFi: ${credentials.ssid}');

      // TODO: Implementar conexión real a WiFi usando un plugin nativo
      // Esta funcionalidad requiere permisos de sistema y un plugin adecuado

      _logger.w('WiFi connection not implemented - requires native plugin');

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
