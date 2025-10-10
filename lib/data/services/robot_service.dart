import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Dispositivo Robot
class RobotDevice {
  final String id;
  final String name;
  final String model;
  final String serialNumber;
  final String firmwareVersion;
  final String bluetoothId;
  final String status; // 'online' | 'offline' | 'setup' | 'error'
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RobotDevice({
    required this.id,
    required this.name,
    required this.model,
    required this.serialNumber,
    required this.firmwareVersion,
    required this.bluetoothId,
    required this.status,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'model': model,
    'serialNumber': serialNumber,
    'firmwareVersion': firmwareVersion,
    'bluetoothId': bluetoothId,
    'status': status,
    'lastSeen': lastSeen.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory RobotDevice.fromJson(Map<String, dynamic> json) =>
      RobotDevice(
        id: json['id'] as String,
        name: json['name'] as String,
        model: json['model'] as String,
        serialNumber: json['serialNumber'] as String,
        firmwareVersion: json['firmwareVersion'] as String,
        bluetoothId: json['bluetoothId'] as String,
        status: json['status'] as String,
        lastSeen: DateTime.parse(json['lastSeen'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}

/// Solicitud de validación del robot
class RobotValidationRequest {
  final String deviceId;
  final String deviceName;
  final String bluetoothId;
  final String? model;
  final String? serialNumber;

  const RobotValidationRequest({
    required this.deviceId,
    required this.deviceName,
    required this.bluetoothId,
    this.model,
    this.serialNumber,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'bluetoothId': bluetoothId,
    'model': model,
    'serialNumber': serialNumber,
  };
}

/// Respuesta de validación del robot
class RobotValidationResponse {
  final bool isValid;
  final RobotDevice? device;
  final String message;
  final bool requiresUpdate;

  const RobotValidationResponse({
    required this.isValid,
    this.device,
    required this.message,
    this.requiresUpdate = false,
  });

  factory RobotValidationResponse.fromJson(Map<String, dynamic> json) =>
      RobotValidationResponse(
        isValid: json['isValid'] as bool,
        device: json['device'] != null 
            ? RobotDevice.fromJson(json['device']) 
            : null,
        message: json['message'] as String,
        requiresUpdate: json['requiresUpdate'] as bool? ?? false,
      );
}

/// Solicitud de configuración WiFi
class WiFiConfigurationRequest {
  final String deviceId;
  final String wifiSSID;
  final String wifiPassword;
  final String? encryptionType;

  const WiFiConfigurationRequest({
    required this.deviceId,
    required this.wifiSSID,
    required this.wifiPassword,
    this.encryptionType,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'wifiSSID': wifiSSID,
    'wifiPassword': wifiPassword,
    'encryptionType': encryptionType,
  };
}

/// Respuesta de configuración WiFi
class WiFiConfigurationResponse {
  final bool success;
  final String message;
  final ConnectionTest? connectionTest;

  const WiFiConfigurationResponse({
    required this.success,
    required this.message,
    this.connectionTest,
  });

  factory WiFiConfigurationResponse.fromJson(Map<String, dynamic> json) =>
      WiFiConfigurationResponse(
        success: json['success'] as bool,
        message: json['message'] as String,
        connectionTest: json['connectionTest'] != null
            ? ConnectionTest.fromJson(json['connectionTest'])
            : null,
      );
}

/// Prueba de conexión
class ConnectionTest {
  final bool success;
  final double ping;
  final double downloadSpeed;
  final double uploadSpeed;

  const ConnectionTest({
    required this.success,
    required this.ping,
    required this.downloadSpeed,
    required this.uploadSpeed,
  });

  factory ConnectionTest.fromJson(Map<String, dynamic> json) =>
      ConnectionTest(
        success: json['success'] as bool,
        ping: (json['ping'] as num).toDouble(),
        downloadSpeed: (json['downloadSpeed'] as num).toDouble(),
        uploadSpeed: (json['uploadSpeed'] as num).toDouble(),
      );
}

/// Comando del robot
class RobotCommand {
  final String deviceId;
  final String command;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  const RobotCommand({
    required this.deviceId,
    required this.command,
    required this.parameters,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'command': command,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Servicio de Robot
class RobotService {
  final Logger _logger;
  final Dio _dio;

  final List<RobotDevice> _devices = [];
  
  // Streams para notificaciones
  final StreamController<List<RobotDevice>> _devicesController = 
      StreamController<List<RobotDevice>>.broadcast();
  final StreamController<RobotDevice> _deviceStatusController = 
      StreamController<RobotDevice>.broadcast();

  RobotService({
    required Logger logger,
    required Dio dio,
  }) : _logger = logger,
       _dio = dio;

  /// Validar dispositivo robot
  Future<RobotValidationResponse> validateDevice(RobotValidationRequest request) async {
    try {
      _logger.i('Validating robot device: ${request.deviceName}');

      final response = await _dio.post(
        '/robots/validate',
        data: request.toJson(),
      );

      final validationResponse = RobotValidationResponse.fromJson(response.data);
      
      if (validationResponse.isValid && validationResponse.device != null) {
        _updateDeviceInList(validationResponse.device!);
      }

      _logger.i('Device validation result: ${validationResponse.isValid}');
      return validationResponse;
    } catch (e) {
      _logger.e('Error validating robot device: $e');
      
      // Simular respuesta de error para desarrollo
      return RobotValidationResponse(
        isValid: false,
        message: 'Validation failed: $e',
      );
    }
  }

  /// Obtener dispositivos robot del usuario
  Future<List<RobotDevice>> getUserDevices() async {
    try {
      _logger.i('Fetching user robot devices');

      final response = await _dio.get('/robots');

      final devicesJson = response.data['devices'] as List;
      final devices = devicesJson
          .map((json) => RobotDevice.fromJson(json))
          .toList();

      _devices.clear();
      _devices.addAll(devices);
      _devicesController.add(List.unmodifiable(_devices));

      _logger.i('Found ${devices.length} robot devices');
      return devices;
    } catch (e) {
      _logger.e('Error fetching robot devices: $e');
      
      // Simular datos de prueba para desarrollo
      final mockDevices = <RobotDevice>[
        RobotDevice(
          id: 'robot-1',
          name: 'Nebu Robot Alpha',
          model: 'NR-1000',
          serialNumber: 'NR1000-001',
          firmwareVersion: '1.2.3',
          bluetoothId: '00:11:22:33:44:55',
          status: 'online',
          lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        RobotDevice(
          id: 'robot-2',
          name: 'Nebu Robot Beta',
          model: 'NR-2000',
          serialNumber: 'NR2000-002',
          firmwareVersion: '2.1.0',
          bluetoothId: '00:11:22:33:44:66',
          status: 'offline',
          lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

      _devices.clear();
      _devices.addAll(mockDevices);
      _devicesController.add(List.unmodifiable(_devices));

      return mockDevices;
    }
  }

  /// Configurar WiFi en el robot
  Future<WiFiConfigurationResponse> configureWiFi(WiFiConfigurationRequest request) async {
    try {
      _logger.i('Configuring WiFi for robot: ${request.deviceId}');

      final response = await _dio.post(
        '/robots/${request.deviceId}/wifi',
        data: request.toJson(),
      );

      final configResponse = WiFiConfigurationResponse.fromJson(response.data);
      
      _logger.i('WiFi configuration result: ${configResponse.success}');
      return configResponse;
    } catch (e) {
      _logger.e('Error configuring WiFi: $e');
      
      // Simular respuesta para desarrollo
      return WiFiConfigurationResponse(
        success: false,
        message: 'WiFi configuration failed: $e',
      );
    }
  }

  /// Enviar comando al robot
  Future<bool> sendCommand(RobotCommand command) async {
    try {
      _logger.i('Sending command to robot: ${command.deviceId} - ${command.command}');

      await _dio.post(
        '/robots/${command.deviceId}/commands',
        data: command.toJson(),
      );

      _logger.i('Command sent successfully');
      return true;
    } catch (e) {
      _logger.e('Error sending command to robot: $e');
      return false;
    }
  }

  /// Mover robot
  Future<bool> moveRobot({
    required String deviceId,
    required String direction,
    required double speed,
    required Duration duration,
  }) async {
    final command = RobotCommand(
      deviceId: deviceId,
      command: 'move',
      parameters: {
        'direction': direction,
        'speed': speed,
        'duration': duration.inMilliseconds,
      },
      timestamp: DateTime.now(),
    );

    return await sendCommand(command);
  }

  /// Detener robot
  Future<bool> stopRobot(String deviceId) async {
    final command = RobotCommand(
      deviceId: deviceId,
      command: 'stop',
      parameters: {},
      timestamp: DateTime.now(),
    );

    return await sendCommand(command);
  }

  /// Actualizar firmware del robot
  Future<bool> updateFirmware(String deviceId) async {
    try {
      _logger.i('Updating firmware for robot: $deviceId');

      await _dio.post('/robots/$deviceId/firmware/update');
      
      _logger.i('Firmware update initiated');
      return true;
    } catch (e) {
      _logger.e('Error updating firmware: $e');
      return false;
    }
  }

  /// Obtener estado del robot
  Future<RobotDevice?> getDeviceStatus(String deviceId) async {
    try {
      final response = await _dio.get('/robots/$deviceId/status');
      
      final device = RobotDevice.fromJson(response.data);
      _updateDeviceInList(device);
      
      return device;
    } catch (e) {
      _logger.e('Error getting device status: $e');
      return null;
    }
  }

  /// Actualizar dispositivo en la lista
  void _updateDeviceInList(RobotDevice device) {
    final index = _devices.indexWhere((d) => d.id == device.id);
    
    if (index != -1) {
      _devices[index] = device;
    } else {
      _devices.add(device);
    }
    
    _devicesController.add(List.unmodifiable(_devices));
    _deviceStatusController.add(device);
  }

  /// Obtener dispositivos actuales
  List<RobotDevice> get devices => List.unmodifiable(_devices);

  /// Obtener dispositivo por ID
  RobotDevice? getDeviceById(String deviceId) {
    try {
      return _devices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Stream de dispositivos
  Stream<List<RobotDevice>> get devicesStream => _devicesController.stream;

  /// Stream de estado de dispositivo
  Stream<RobotDevice> get deviceStatusStream => _deviceStatusController.stream;

  /// Cerrar servicio
  Future<void> dispose() async {
    await _devicesController.close();
    await _deviceStatusController.close();
    _logger.i('Robot Service disposed');
  }
}
