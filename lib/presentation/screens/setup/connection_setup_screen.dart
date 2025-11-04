import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import 'wifi_setup_screen.dart';

class ConnectionSetupScreen extends ConsumerStatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  ConsumerState<ConnectionSetupScreen> createState() =>
      _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends ConsumerState<ConnectionSetupScreen> {
  final _logger = Logger();
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isBluetoothEnabled = false;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  List<fbp.ScanResult> _scanResults = [];
  fbp.BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  @override
  void dispose() {
    _stopScan();
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _logger.close();
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    _adapterStateSubscription = fbp.FlutterBluePlus.adapterState.listen((state) {
      _logger.d('Bluetooth adapter state changed: $state');
      if (mounted) {
        setState(() {
          _isBluetoothEnabled = state == fbp.BluetoothAdapterState.on;
        });
      }
    });

    final state = await fbp.FlutterBluePlus.adapterState.first;
    if (mounted) {
      setState(() {
        _isBluetoothEnabled = state == fbp.BluetoothAdapterState.on;
      });
    }
  }

  Future<void> _checkPermissionsAndStartScan() async {
    final hasPermissions = await _requestPermissions();
    if (hasPermissions && _isBluetoothEnabled) {
      await _startScan();
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      _logger.i('Requesting Bluetooth permissions...');
      final permissions = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
      final granted = permissions.values.every((status) => status.isGranted);
      _logger.i('All permissions granted: $granted');
      if (!granted && mounted) {
        _logger.w('Permissions denied, showing dialog');
        _showPermissionsDeniedDialog();
      }
      return granted;
    } on Exception catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) {
      _logger.d('Scan already in progress');
      return;
    }

    _logger.i('Starting Bluetooth scan...');
    setState(() {
      _isScanning = true;
      _scanResults = [];
      _selectedDevice = null;
    });

    try {
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        _logger.d('Scan results: ${results.length} devices found');
        final filteredResults = results
            .where((r) =>
                r.device.platformName.isNotEmpty &&
                (r.device.platformName.toLowerCase().contains('nebu') ||
                    r.device.platformName.toLowerCase().contains('esp32')))
            .toList();

        if (mounted) {
          setState(() {
            _scanResults = filteredResults;
          });
        }

        _logger.d('Filtered results: ${_scanResults.length} Nebu/ESP32 devices');
      });

      Future<void>.delayed(const Duration(seconds: 15), () {
        if (mounted) {
          _stopScan();
        }
      });
    } on Exception catch (e) {
      _logger.e('Error starting scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _stopScan() async {
    _logger.i('Stopping Bluetooth scan...');
    try {
      await fbp.FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    } on Exception catch (e) {
      _logger.e('Error stopping scan: $e');
    }
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    _logger.i('Attempting to connect to ${device.platformName} (${device.remoteId})');
    final messenger = ScaffoldMessenger.of(context);
    final esp32service = ref.read(esp32WifiConfigServiceProvider);

    setState(() {
      _isConnecting = true;
    });

    try {
      // This now connects and discovers services for WiFi config
      await esp32service.connectToESP32(device);

      if (!mounted) return;

      _logger.i('Successfully connected and prepared device: ${device.platformName}');
      messenger.showSnackBar(
        SnackBar(
          content: Text('Connected to ${device.platformName}'),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {
        _selectedDevice = device;
      });

    } on Exception catch (e) {
      _logger.e('Failed to connect and prepare device ${device.platformName}: $e');
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to connect: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  void _showEnableBluetoothDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Bluetooth'),
        content: const Text('Please enable Bluetooth to connect to your Nebu device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (await fbp.FlutterBluePlus.isSupported) {
                  await fbp.FlutterBluePlus.turnOn();
                }
              } on Exception catch (e) {
                _logger.e('Error turning on Bluetooth: $e');
              }
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showSkipSetupDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Device Setup?'),
        content: const Text(
          'You can set up your Nebu device later from the home screen.\n\n'
          'Are you sure you want to skip the setup now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _logger.i('User skipped setup');
              Navigator.pop(context);
              context.go(AppConstants.routeHome);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryLight,
              foregroundColor: Colors.white,
            ),
            child: const Text('Skip Setup'),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDeniedDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Bluetooth and location permissions are required to connect to your device. Please enable them in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canProceed = _selectedDevice != null;

    return Scaffold(
        body: DecoratedBox(
          decoration: AppTheme.primaryGradientDecoration,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildTitle(theme),
                  const SizedBox(height: 32),
                  Expanded(
                    child: _isScanning
                        ? _buildScanningView(theme)
                        : _buildDevicesList(theme),
                  ),
                  ElevatedButton(
                    onPressed: canProceed && !_isConnecting
                        ? () => context.push(AppConstants.routeWifiSetup)
                        : () {
                            if (_isScanning) return;
                            if (!_isBluetoothEnabled) {
                              _showEnableBluetoothDialog();
                            } else {
                              _checkPermissionsAndStartScan();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryLight,
                      disabledBackgroundColor: Colors.white.withAlpha(128),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isScanning
                          ? 'Scanning...'
                          : canProceed
                              ? 'Next'
                              : 'Start Scan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _showSkipSetupDialog,
                    child: Text(
                      'Skip Setup',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        const Spacer(),
        _buildProgressIndicator(1, 7),
        const Spacer(),
        const Opacity(
          opacity: 0,
          child: IconButton(icon: Icon(Icons.arrow_back), onPressed: null),
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Connect Your Device',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _isScanning
              ? 'Searching for your Nebu device...'
              : "Let's connect your Nebu toy to get started",
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withAlpha(230),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(int current, int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index < current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index < current ? Colors.white : Colors.white.withAlpha(77),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildScanningView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scanning for devices...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(230),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Make sure your Nebu device is turned on',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(ThemeData theme) {
    final bool hasResults = _scanResults.isNotEmpty;

    if (!hasResults && !_isScanning) {
      return _buildNoDevicesPlaceholder(theme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasResults)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Available Devices (${_scanResults.length})',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white.withAlpha(230),
              ),
            ),
          ),
        if (hasResults)
          Expanded(
            child: ListView.builder(
              itemCount: _scanResults.length,
              itemBuilder: (context, index) {
                final result = _scanResults[index];
                final device = result.device;
                final isSelected = _selectedDevice?.remoteId == device.remoteId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withAlpha(51) : Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white.withAlpha(51),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: _isConnecting && isSelected ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.bluetooth, color: Colors.white),
                    title: Text(
                      device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Signal: ${result.rssi} dBm',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(179)),
                    ),
                    onTap: _isConnecting ? null : () => _connectToDevice(device),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNoDevicesPlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 80,
            color: Colors.white.withAlpha(179),
          ),
          const SizedBox(height: 24),
          Text(
            'No devices found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withAlpha(230),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap "Start Scan" to search for your Nebu device',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
