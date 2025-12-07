import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/iot_device.dart';
import '../../data/services/iot_service.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

// IoT Service Provider
final iotServiceProvider = Provider<IoTService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return IoTService(apiService: apiService, logger: logger);
});

// IoT Devices State
class IoTDevicesState {
  IoTDevicesState({
    this.devices = const [],
    this.isLoading = false,
    this.error,
    this.metrics,
  });

  final List<IoTDevice> devices;
  final bool isLoading;
  final String? error;
  final IoTMetrics? metrics;

  IoTDevicesState copyWith({
    List<IoTDevice>? devices,
    bool? isLoading,
    String? error,
    IoTMetrics? metrics,
  }) =>
      IoTDevicesState(
        devices: devices ?? this.devices,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        metrics: metrics ?? this.metrics,
      );

  // Helper getters
  List<IoTDevice> get onlineDevices =>
      devices.where((d) => d.status == DeviceStatus.online).toList();

  List<IoTDevice> get offlineDevices =>
      devices.where((d) => d.status == DeviceStatus.offline).toList();

  List<IoTDevice> get errorDevices =>
      devices.where((d) => d.status == DeviceStatus.error).toList();

  int get totalDevices => devices.length;
  int get onlineCount => onlineDevices.length;
  int get offlineCount => offlineDevices.length;
  int get errorCount => errorDevices.length;
}

// IoT Devices Notifier
class IoTDevicesNotifier extends Notifier<IoTDevicesState> {
  late IoTService _iotService;

  @override
  IoTDevicesState build() {
    _iotService = ref.watch(iotServiceProvider);
    return IoTDevicesState();
  }

  // Fetch all devices
  Future<void> fetchAllDevices({
    DeviceStatus? status,
    DeviceType? deviceType,
    String? location,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final devices = await _iotService.getAllDevices(
        status: status,
        deviceType: deviceType,
        location: location,
      );

      state = state.copyWith(
        devices: devices,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Fetch devices for current user
  Future<void> fetchUserDevices() async {
    final authState = ref.read(authProvider);
    final userId = authState.user?.id;

    if (userId == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'User not authenticated',
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final devices = await _iotService.getDevicesByUser(userId);

      state = state.copyWith(
        devices: devices,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Fetch online devices only
  Future<void> fetchOnlineDevices() async {
    state = state.copyWith(isLoading: true);

    try {
      final devices = await _iotService.getOnlineDevices();

      state = state.copyWith(
        devices: devices,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Fetch device metrics
  Future<void> fetchMetrics() async {
    try {
      final metrics = await _iotService.getMetrics();
      state = state.copyWith(metrics: metrics);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Create a new device
  Future<IoTDevice?> createDevice(CreateIoTDeviceDto deviceDto) async {
    state = state.copyWith(isLoading: true);

    try {
      final device = await _iotService.createDevice(deviceDto);

      // Add to local state
      state = state.copyWith(
        devices: [...state.devices, device],
        isLoading: false,
      );

      return device;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Update a device
  Future<IoTDevice?> updateDevice(
    String deviceId,
    UpdateIoTDeviceDto updateDto,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final updatedDevice = await _iotService.updateDevice(
        deviceId,
        updateDto,
      );

      // Update in local state
      final updatedDevices = state.devices.map((d) => d.id == deviceId ? updatedDevice : d).toList();

      state = state.copyWith(
        devices: updatedDevices,
        isLoading: false,
      );

      return updatedDevice;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  // Update device status
  Future<IoTDevice?> updateDeviceStatus(
    String deviceId,
    DeviceStatus status,
  ) async {
    try {
      final updatedDevice = await _iotService.updateDeviceStatus(
        deviceId,
        status,
      );

      // Update in local state
      final updatedDevices = state.devices.map((d) => d.id == deviceId ? updatedDevice : d).toList();

      state = state.copyWith(devices: updatedDevices);

      return updatedDevice;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Update sensor data
  Future<IoTDevice?> updateSensorData(
    String deviceId, {
    double? temperature,
    double? humidity,
    int? batteryLevel,
    int? signalStrength,
  }) async {
    try {
      final updatedDevice = await _iotService.updateSensorData(
        deviceId,
        temperature: temperature,
        humidity: humidity,
        batteryLevel: batteryLevel,
        signalStrength: signalStrength,
      );

      // Update in local state
      final updatedDevices = state.devices.map((d) => d.id == deviceId ? updatedDevice : d).toList();

      state = state.copyWith(devices: updatedDevices);

      return updatedDevice;
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  // Delete a device
  Future<bool> deleteDevice(String deviceId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _iotService.deleteDevice(deviceId);

      // Remove from local state
      final updatedDevices = state.devices.where((d) => d.id != deviceId).toList();

      state = state.copyWith(
        devices: updatedDevices,
        isLoading: false,
      );

      return true;
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Refresh devices (reload from backend)
  Future<void> refresh() async {
    await fetchUserDevices();
    await fetchMetrics();
  }

  // Get a specific device by ID
  IoTDevice? getDeviceById(String deviceId) {
    try {
      return state.devices.firstWhere((d) => d.id == deviceId);
    } on StateError {
      return null;
    }
  }

  // Generate LiveKit token for device
  Future<Map<String, dynamic>?> generateLiveKitToken(String deviceId) async {
    try {
      return await _iotService.generateLiveKitToken(deviceId);
    } on Exception catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

// Provider
final iotDevicesProvider = NotifierProvider<IoTDevicesNotifier, IoTDevicesState>(
  IoTDevicesNotifier.new,
);

// Provider for a specific device (auto-updated when devices state changes)
final deviceProvider = Provider.family<IoTDevice?, String>((ref, deviceId) {
  final devicesState = ref.watch(iotDevicesProvider);
  try {
    return devicesState.devices.firstWhere((d) => d.id == deviceId);
  } on StateError {
    return null;
  }
});
