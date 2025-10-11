import 'dart:async';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

/// Red WiFi
class WiFiNetwork {
  final String ssid;
  final int rssi;
  final String security; // 'Open' | 'WPA' | 'WPA2' | 'WPA3' | 'WEP'
  final int frequency;
  final bool isConnected;

  const WiFiNetwork({
    required this.ssid,
    required this.rssi,
    required this.security,
    required this.frequency,
    this.isConnected = false,
  });

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'rssi': rssi,
    'security': security,
    'frequency': frequency,
    'isConnected': isConnected,
  };

  factory WiFiNetwork.fromJson(Map<String, dynamic> json) =>
      WiFiNetwork(
        ssid: json['ssid'] as String,
        rssi: json['rssi'] as int,
        security: json['security'] as String,
        frequency: json['frequency'] as int,
        isConnected: json['isConnected'] as bool? ?? false,
      );
}

/// Credenciales WiFi
class WiFiCredentials {
  final String ssid;
  final String password;

  const WiFiCredentials({
    required this.ssid,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'password': password,
  };

  factory WiFiCredentials.fromJson(Map<String, dynamic> json) =>
      WiFiCredentials(
        ssid: json['ssid'] as String,
        password: json['password'] as String,
      );
}

/// Resultado de conexión WiFi
class WiFiConnectionResult {
  final bool success;
  final String message;
  final WiFiNetwork? connectedNetwork;

  const WiFiConnectionResult({
    required this.success,
    required this.message,
    this.connectedNetwork,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'connectedNetwork': connectedNetwork?.toJson(),
  };

  factory WiFiConnectionResult.fromJson(Map<String, dynamic> json) =>
      WiFiConnectionResult(
        success: json['success'] as bool,
        message: json['message'] as String,
        connectedNetwork: json['connectedNetwork'] != null
            ? WiFiNetwork.fromJson(json['connectedNetwork'])
            : null,
      );
}

/// Servicio WiFi
class WiFiService {
  final Logger _logger;

  bool _isScanning = false;
  WiFiNetwork? _currentNetwork;
  
  // Streams para notificaciones
  final StreamController<List<WiFiNetwork>> _networksController = 
      StreamController<List<WiFiNetwork>>.broadcast();
  final StreamController<WiFiConnectionResult> _connectionController = 
      StreamController<WiFiConnectionResult>.broadcast();

  WiFiService({required Logger logger}) : _logger = logger;

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

      // Simular escaneo de redes WiFi (en una implementación real usaríamos
      // un plugin nativo para acceder a las APIs de WiFi)
      await Future.delayed(const Duration(seconds: 2));

      final mockNetworks = <WiFiNetwork>[
        const WiFiNetwork(
          ssid: 'Mi Casa WiFi',
          rssi: -30,
          security: 'WPA2',
          frequency: 2400,
        ),
        const WiFiNetwork(
          ssid: 'Vecino WiFi',
          rssi: -60,
          security: 'WPA3',
          frequency: 5000,
        ),
        const WiFiNetwork(
          ssid: 'WiFi Gratis',
          rssi: -45,
          security: 'Open',
          frequency: 2400,
        ),
        const WiFiNetwork(
          ssid: 'Oficina Corp',
          rssi: -35,
          security: 'WPA2',
          frequency: 5000,
          isConnected: true,
        ),
        const WiFiNetwork(
          ssid: 'Guest Network',
          rssi: -55,
          security: 'WPA2',
          frequency: 2400,
        ),
      ];

      _networksController.add(mockNetworks);
      _logger.i('Found ${mockNetworks.length} WiFi networks');
      
      return mockNetworks;
    } catch (e) {
      _logger.e('Error scanning WiFi networks: $e');
      rethrow;
    } finally {
      _isScanning = false;
    }
  }

  /// Conectar a una red WiFi
  Future<WiFiConnectionResult> connectToNetwork(WiFiCredentials credentials) async {
    try {
      _logger.i('Attempting to connect to WiFi: ${credentials.ssid}');

      // Simular proceso de conexión
      await Future.delayed(const Duration(seconds: 3));

      // Simular diferentes resultados basados en la red
      WiFiConnectionResult result;
      
      if (credentials.ssid == 'WiFi Gratis') {
        // Red abierta - conexión exitosa
        final network = WiFiNetwork(
          ssid: credentials.ssid,
          rssi: -45,
          security: 'Open',
          frequency: 2400,
          isConnected: true,
        );
        
        result = WiFiConnectionResult(
          success: true,
          message: 'Connected successfully to ${credentials.ssid}',
          connectedNetwork: network,
        );
        
        _currentNetwork = network;
      } else if (credentials.ssid == 'Mi Casa WiFi') {
        // Verificar contraseña
        if (credentials.password == 'password123') {
          final network = WiFiNetwork(
            ssid: credentials.ssid,
            rssi: -30,
            security: 'WPA2',
            frequency: 2400,
            isConnected: true,
          );
          
          result = WiFiConnectionResult(
            success: true,
            message: 'Connected successfully to ${credentials.ssid}',
            connectedNetwork: network,
          );
          
          _currentNetwork = network;
        } else {
          result = WiFiConnectionResult(
            success: false,
            message: 'Invalid password for ${credentials.ssid}',
          );
        }
      } else if (credentials.ssid == 'Oficina Corp') {
        // Ya conectado
        result = WiFiConnectionResult(
          success: true,
          message: 'Already connected to ${credentials.ssid}',
          connectedNetwork: _currentNetwork,
        );
      } else {
        // Error genérico
        result = WiFiConnectionResult(
          success: false,
          message: 'Failed to connect to ${credentials.ssid}. Check password and try again.',
        );
      }

      _connectionController.add(result);
      _logger.i('WiFi connection result: ${result.success ? 'Success' : 'Failed'}');
      
      return result;
    } catch (e) {
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
      await Future.delayed(const Duration(seconds: 1));
      
      _currentNetwork = null;
      
      final result = WiFiConnectionResult(
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
    if (_currentNetwork == null) return null;
    
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
    if (rssi >= -30) return 'Excelente';
    if (rssi >= -50) return 'Buena';
    if (rssi >= -70) return 'Regular';
    if (rssi >= -80) return 'Débil';
    return 'Muy débil';
  }

  /// Stream de redes encontradas
  Stream<List<WiFiNetwork>> get networksStream => _networksController.stream;

  /// Stream de resultados de conexión
  Stream<WiFiConnectionResult> get connectionStream => _connectionController.stream;

  /// Verificar permisos necesarios
  Future<bool> checkPermissions() async {
    try {
      final locationPermission = await Permission.location.status;

      return locationPermission.isGranted;
    } catch (e) {
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
    } catch (e) {
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
