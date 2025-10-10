import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import '../../core/constants/app_constants.dart';

class BluetoothService {
  final Logger _logger;
  final StreamController<List<ScanResult>> _scanResultsController;
  final StreamController<BluetoothConnectionState> _connectionStateController;

  BluetoothDevice? _connectedDevice;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  BluetoothService({required Logger logger})
      : _logger = logger,
        _scanResultsController = StreamController<List<ScanResult>>.broadcast(),
        _connectionStateController = StreamController<BluetoothConnectionState>.broadcast();

  // Streams
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;
  Stream<BluetoothConnectionState> get connectionState => _connectionStateController.stream;

  // Getters
  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;

  // Request Bluetooth permissions
  Future<bool> requestPermissions() async {
    try {
      if (Platform.isAndroid) {
        final bluetoothScan = await Permission.bluetoothScan.request();
        final bluetoothConnect = await Permission.bluetoothConnect.request();
        final location = await Permission.location.request();

        final granted = bluetoothScan.isGranted &&
            bluetoothConnect.isGranted &&
            location.isGranted;

        if (!granted) {
          _logger.w('Bluetooth permissions not granted');
          return false;
        }
      } else if (Platform.isIOS) {
        final bluetooth = await Permission.bluetooth.request();
        if (!bluetooth.isGranted) {
          _logger.w('Bluetooth permission not granted on iOS');
          return false;
        }
      }

      return true;
    } catch (e) {
      _logger.e('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  // Check if Bluetooth is available and enabled
  Future<bool> isBluetoothAvailable() async {
    try {
      if (Platform.isAndroid) {
        final isSupported = await FlutterBluePlus.isSupported;
        if (!isSupported) {
          _logger.w('Bluetooth not supported on this device');
          return false;
        }
      }

      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      _logger.e('Error checking Bluetooth availability: $e');
      return false;
    }
  }

  // Start scanning for devices
  Future<void> startScan({Duration? timeout}) async {
    try {
      final hasPermissions = await requestPermissions();
      if (!hasPermissions) {
        throw Exception('Bluetooth permissions not granted');
      }

      final isAvailable = await isBluetoothAvailable();
      if (!isAvailable) {
        throw Exception('Bluetooth is not available or not enabled');
      }

      _logger.i('Starting Bluetooth scan...');

      // Cancel previous scan if active
      await stopScan();

      // Start scanning
      await FlutterBluePlus.startScan(
        timeout: timeout ?? AppConstants.scanTimeout,
      );

      // Listen to scan results
      _scanSubscription = FlutterBluePlus.scanResults.listen(
        (results) {
          _logger.d('Found ${results.length} devices');
          _scanResultsController.add(results);
        },
        onError: (error) {
          _logger.e('Scan error: $error');
        },
      );
    } catch (e) {
      _logger.e('Error starting scan: $e');
      rethrow;
    }
  }

  // Stop scanning
  Future<void> stopScan() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      _logger.i('Bluetooth scan stopped');
    } catch (e) {
      _logger.e('Error stopping scan: $e');
    }
  }

  // Connect to a device
  Future<void> connect(BluetoothDevice device) async {
    try {
      _logger.i('Connecting to device: ${device.platformName}');

      // Disconnect from current device if any
      if (_connectedDevice != null) {
        await disconnect();
      }

      // Connect to the device
      await device.connect(
        timeout: AppConstants.connectionTimeout,
        autoConnect: false,
      );

      _connectedDevice = device;

      // Listen to connection state changes
      _connectionSubscription = device.connectionState.listen(
        (state) {
          _logger.d('Connection state changed: $state');
          _connectionStateController.add(state);

          if (state == BluetoothConnectionState.disconnected) {
            _connectedDevice = null;
          }
        },
        onError: (error) {
          _logger.e('Connection state error: $error');
        },
      );

      _logger.i('Connected to device: ${device.platformName}');
    } catch (e) {
      _logger.e('Error connecting to device: $e');
      _connectedDevice = null;
      rethrow;
    }
  }

  // Disconnect from current device
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        _logger.i('Disconnecting from device: ${_connectedDevice!.platformName}');
        await _connectedDevice!.disconnect();
        await _connectionSubscription?.cancel();
        _connectionSubscription = null;
        _connectedDevice = null;
        _logger.i('Disconnected successfully');
      }
    } catch (e) {
      _logger.e('Error disconnecting: $e');
    }
  }

  // Discover services
  Future<List<BluetoothService>> discoverServices() async {
    if (_connectedDevice == null) {
      throw Exception('No device connected');
    }

    try {
      _logger.i('Discovering services...');
      final services = _connectedDevice!.discoverServices();
      _logger.i('Discovered ${services.length} services');
      return services;
    } catch (e) {
      _logger.e('Error discovering services: $e');
      rethrow;
    }
  }

  // Read characteristic
  Future<List<int>> readCharacteristic(
    BluetoothCharacteristic characteristic,
  ) async {
    try {
      _logger.d('Reading characteristic: ${characteristic.uuid}');
      final value = await characteristic.read();
      return value;
    } catch (e) {
      _logger.e('Error reading characteristic: $e');
      rethrow;
    }
  }

  // Write characteristic
  Future<void> writeCharacteristic(
    BluetoothCharacteristic characteristic,
    List<int> value, {
    bool withoutResponse = false,
  }) async {
    try {
      _logger.d('Writing to characteristic: ${characteristic.uuid}');
      await characteristic.write(
        value,
        withoutResponse: withoutResponse,
      );
    } catch (e) {
      _logger.e('Error writing characteristic: $e');
      rethrow;
    }
  }

  // Subscribe to characteristic notifications
  StreamSubscription<List<int>> subscribeToCharacteristic(
    BluetoothCharacteristic characteristic,
    void Function(List<int>) onData,
  ) {
    try {
      _logger.d('Subscribing to characteristic: ${characteristic.uuid}');
      characteristic.setNotifyValue(true);
      return characteristic.lastValueStream.listen(onData);
    } catch (e) {
      _logger.e('Error subscribing to characteristic: $e');
      rethrow;
    }
  }

  // Get connected devices
  Future<List<BluetoothDevice>> getConnectedDevices() async {
    try {
      return FlutterBluePlus.connectedDevices;
    } catch (e) {
      _logger.e('Error getting connected devices: $e');
      return [];
    }
  }

  // Dispose resources
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _scanResultsController.close();
    _connectionStateController.close();
  }
}
