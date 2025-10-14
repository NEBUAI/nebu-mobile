import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class ConnectionSetupScreen extends StatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  State<ConnectionSetupScreen> createState() => _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends State<ConnectionSetupScreen> {
  bool _isScanning = false;
  bool _isBluetoothEnabled = false;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  List<fbp.ScanResult> _scanResults = [];

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
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    // Listen to Bluetooth adapter state changes
    _adapterStateSubscription = fbp.FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _isBluetoothEnabled = state == fbp.BluetoothAdapterState.on;
      });
    });

    // Check initial state
    final state = await fbp.FlutterBluePlus.adapterState.first;
    setState(() {
      _isBluetoothEnabled = state == fbp.BluetoothAdapterState.on;
    });
  }

  Future<void> _checkPermissionsAndStartScan() async {
    final hasPermissions = await _requestPermissions();
    if (hasPermissions && _isBluetoothEnabled) {
      await _startScan();
    }
  }

  Future<bool> _requestPermissions() async {
    try {
      debugPrint('🔵 Requesting Bluetooth permissions...');

      // Check current status first
      final scanStatus = await Permission.bluetoothScan.status;
      final connectStatus = await Permission.bluetoothConnect.status;
      final locationStatus = await Permission.location.status;

      debugPrint('📊 Current status:');
      debugPrint('  - Bluetooth Scan: $scanStatus');
      debugPrint('  - Bluetooth Connect: $connectStatus');
      debugPrint('  - Location: $locationStatus');

      // Request permissions
      final bluetoothScan = await Permission.bluetoothScan.request();
      final bluetoothConnect = await Permission.bluetoothConnect.request();
      final location = await Permission.location.request();

      debugPrint('📊 After request:');
      debugPrint('  - Bluetooth Scan: $bluetoothScan');
      debugPrint('  - Bluetooth Connect: $bluetoothConnect');
      debugPrint('  - Location: $location');

      final granted = bluetoothScan.isGranted &&
          bluetoothConnect.isGranted &&
          location.isGranted;

      debugPrint('✅ All permissions granted: $granted');

      if (!granted && mounted) {
        debugPrint('❌ Showing permissions denied dialog');
        _showPermissionsDeniedDialog();
      }

      return granted;
    } on Exception catch (e) {
      debugPrint('❌ Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) {
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults = [];
    });

    try {
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        androidUsesFineLocation: true,
      );

      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        debugPrint('📡 Scan results: ${results.length} devices found');

        // Log all devices for debugging
        for (final result in results) {
          debugPrint('  Device: ${result.device.platformName.isNotEmpty ? result.device.platformName : "Unknown"} (${result.device.remoteId}) - RSSI: ${result.rssi}');
        }

        setState(() {
          _scanResults = results
              .where((r) =>
                  r.device.platformName.isNotEmpty &&
                  (r.device.platformName.toLowerCase().contains('nebu') ||
                      r.device.platformName.toLowerCase().contains('esp32')))
              .toList();

          debugPrint('✅ Filtered results: ${_scanResults.length} Nebu/ESP32 devices');
        });
      });

      // Auto-stop after timeout
      Future<void>.delayed(const Duration(seconds: 15), () {
        if (mounted) {
          _stopScan();
        }
      });
    } on Exception catch (e) {
      debugPrint('Error starting scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _stopScan() async {
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
      debugPrint('Error stopping scan: $e');
    }
  }

  void _showEnableBluetoothDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enable Bluetooth'),
        content: const Text(
          'Please enable Bluetooth to connect to your Nebu device.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show message that Bluetooth is required
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bluetooth is required to scan for devices'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);

              // Try to turn on Bluetooth
              try {
                if (await fbp.FlutterBluePlus.isSupported) {
                  await fbp.FlutterBluePlus.turnOn();
                }
              } on Exception catch (e) {
                debugPrint('Error turning on Bluetooth: $e');
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Could not enable Bluetooth: $e'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
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
              Navigator.pop(context);
              // Go to home screen
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
    
    return Scaffold(
        body: DecoratedBox(
          decoration: AppTheme.primaryGradientDecoration,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Progress indicator
                  _buildProgressIndicator(1, 7),

                  const SizedBox(height: 40),

                  // Title
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
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Scanning status and devices list
                  Expanded(
                    child: _isScanning
                        ? _buildScanningView(theme)
                        : _buildDevicesList(theme),
                  ),

                  // Scan/Next button
                  ElevatedButton(
                    onPressed: _isScanning
                        ? null
                        : () async {
                            if (_scanResults.isEmpty) {
                              // Check if Bluetooth is enabled first
                              if (!_isBluetoothEnabled) {
                                _showEnableBluetoothDialog();
                                return;
                              }

                              // Then check permissions and start scan
                              await _checkPermissionsAndStartScan();
                            } else {
                              await context.push(AppConstants.routeToyNameSetup);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryLight,
                      disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isScanning
                          ? 'Scanning...'
                          : _scanResults.isEmpty
                              ? 'Start Scan'
                              : 'Next',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  TextButton(
                    onPressed: _showSkipSetupDialog,
                    child: Text(
                      'Skip Setup',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildProgressIndicator(int current, int total) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          total,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index < current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: index < current
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );

  Widget _buildScanningView(ThemeData theme) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated scanning indicator
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
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Make sure your Nebu device is turned on',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Widget _buildDevicesList(ThemeData theme) {
    if (_scanResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 80,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              'No devices found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap "Start Scan" to search for your Nebu device',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Available Devices (${_scanResults.length})',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              final device = result.device;
              final rssi = result.rssi;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    device.platformName.isNotEmpty
                        ? device.platformName
                        : 'Unknown Device',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Signal: $rssi dBm',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final router = GoRouter.of(context);

                    try {
                      await device.connect(
                        license: fbp.License.free,
                        timeout: const Duration(seconds: 15),
                      );
                      if (!mounted) {
                        return;
                      }

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Connected to ${device.platformName}'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      await router.push(AppConstants.routeToyNameSetup);
                    } on Exception catch (e) {
                      if (!mounted) {
                        return;
                      }

                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to connect: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
