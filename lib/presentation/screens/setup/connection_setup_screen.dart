import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/esp32_provider.dart';

class ConnectionSetupScreen extends ConsumerStatefulWidget {
  const ConnectionSetupScreen({super.key});

  @override
  ConsumerState<ConnectionSetupScreen> createState() =>
      _ConnectionSetupScreenState();
}

class _ConnectionSetupScreenState extends ConsumerState<ConnectionSetupScreen>
    with SingleTickerProviderStateMixin {
  final _logger = Logger();
  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isBluetoothEnabled = false;
  StreamSubscription<fbp.BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<fbp.ScanResult>>? _scanSubscription;
  List<fbp.ScanResult> _scanResults = [];
  fbp.BluetoothDevice? _selectedDevice;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _stopScan();
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _pulseController.dispose();
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
        _showPermissionsDeniedSheet();
      }
      return granted;
    } on Exception catch (e) {
      _logger.e('Error requesting permissions: $e');
      return false;
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) {
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
        final filteredResults = results
            .where((r) =>
                r.device.platformName.isNotEmpty &&
                (r.device.platformName.toLowerCase().contains('nebu') ||
                    r.device.platformName.toLowerCase().contains('esp32')))
            .toList();

        if (mounted) {
          setState(() => _scanResults = filteredResults);
        }
      });

      Future<void>.delayed(const Duration(seconds: 15), () {
        if (mounted) {
          _stopScan();
        }
      });
    } on Exception catch (e) {
      _logger.e('Error starting scan: $e');
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _stopScan() async {
    try {
      await fbp.FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      if (mounted) {
        setState(() => _isScanning = false);
      }
    } on Exception catch (e) {
      _logger.e('Error stopping scan: $e');
    }
  }

  Future<void> _connectToDevice(fbp.BluetoothDevice device) async {
    final messenger = ScaffoldMessenger.of(context);
    final esp32service = ref.read(esp32WifiConfigServiceProvider);

    setState(() => _isConnecting = true);

    try {
      await esp32service.connectToESP32(device);

      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text('Connected to ${device.platformName}'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

      setState(() => _selectedDevice = device);
    } on Exception catch (e) {
      _logger.e('Failed to connect: $e');
      if (!mounted) {
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Connection failed. Please try again.')),
            ],
          ),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _showEnableBluetoothSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheet(
        icon: Icons.bluetooth_disabled_rounded,
        iconColor: const Color(0xFF6B4EFF),
        title: 'Enable Bluetooth',
        description: 'Bluetooth is required to connect to your Nebu device.',
        primaryText: 'Enable Bluetooth',
        primaryOnPressed: () async {
          Navigator.pop(context);
          try {
            if (await fbp.FlutterBluePlus.isSupported) {
              await fbp.FlutterBluePlus.turnOn();
            }
          } on Exception catch (e) {
            _logger.e('Error turning on Bluetooth: $e');
          }
        },
        secondaryText: 'Cancel',
        secondaryOnPressed: () => Navigator.pop(context),
      ),
    );
  }

  void _showSkipSetupSheet() {
    showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) {
          final textTheme = Theme.of(context).textTheme;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4EFF).withValues(alpha: 26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Color(0xFF6B4EFF),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Setup Options',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to proceed',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 28),

                // Option 1: Configure Locally
                _OptionCard(
                  icon: Icons.phone_android_rounded,
                  title: 'Configure Locally',
                  description: 'Set up child info without a device',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.localChildSetup.path);
                  },
                ),

                const SizedBox(height: 12),

                // Option 2: Skip
                _OptionCard(
                  icon: Icons.arrow_forward_rounded,
                  title: 'Skip Setup',
                  description: 'Continue to home and set up later',
                  isSecondary: true,
                  onTap: () {
                    Navigator.pop(context);
                    context.go(AppRoutes.home.path);
                  },
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        });
  }

  void _showPermissionsDeniedSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheet(
        icon: Icons.security_rounded,
        iconColor: const Color(0xFFFF9800),
        title: 'Permissions Required',
        description:
            'Bluetooth and location permissions are needed to find your device.',
        primaryText: 'Open Settings',
        primaryOnPressed: () {
          Navigator.pop(context);
          openAppSettings();
        },
        secondaryText: 'Cancel',
        secondaryOnPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final canProceed = _selectedDevice != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  _BackButton(onPressed: () => context.pop()),
                  const Spacer(),
                  const _StepIndicator(currentStep: 1, totalSteps: 7),
                  const Spacer(),
                  const SizedBox(width: 44), // Balance
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Title section
                    Text(
                      'Connect Your Device',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isScanning
                          ? 'Searching for nearby devices...'
                          : "Let's connect your Nebu toy",
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Main content area
                    Expanded(
                      child: _isScanning
                          ? _buildScanningView()
                          : _scanResults.isEmpty
                              ? _buildEmptyState()
                              : _buildDevicesList(),
                    ),

                    // Bottom buttons
                    _PrimaryButton(
                      text: _isScanning
                          ? 'Scanning...'
                          : canProceed
                              ? 'Continue'
                              : 'Start Scan',
                      isLoading: _isScanning,
                      onPressed: () {
                        if (_isScanning) {
                          return;
                        }
                        if (canProceed) {
                          context.push(AppRoutes.wifiSetup.path);
                        } else if (!_isBluetoothEnabled) {
                          _showEnableBluetoothSheet();
                        } else {
                          _checkPermissionsAndStartScan();
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _showSkipSetupSheet,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Skip for now',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningView() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B4EFF).withValues(alpha: 26),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bluetooth_searching_rounded,
                        size: 36,
                        color: Color(0xFF6B4EFF),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Looking for devices',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure your Nebu is turned on',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.bluetooth_rounded,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to connect',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Start Scan" to find your Nebu device',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Available Devices',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF6B4EFF).withValues(alpha: 26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_scanResults.length}',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B4EFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _scanResults.length,
            itemBuilder: (context, index) {
              final result = _scanResults[index];
              final device = result.device;
              final isSelected = _selectedDevice?.remoteId == device.remoteId;
              final isConnecting = _isConnecting && isSelected;

              return _DeviceCard(
                name: device.platformName.isNotEmpty
                    ? device.platformName
                    : 'Unknown Device',
                signal: result.rssi,
                isSelected: isSelected,
                isConnecting: isConnecting,
                onTap: _isConnecting ? null : () => _connectToDevice(device),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============ Reusable Components ============

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalSteps, (index) {
          final isActive = index < currentStep;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF6B4EFF)
                  : const Color(0xFF6B4EFF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B6FFF), Color(0xFF6B4EFF)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B4EFF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  text,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.name,
    required this.signal,
    required this.isSelected,
    required this.isConnecting,
    this.onTap,
  });
  final String name;
  final int signal;
  final bool isSelected;
  final bool isConnecting;
  final VoidCallback? onTap;

  IconData _getSignalIcon() {
    if (signal >= -50) {
      return Icons.signal_cellular_4_bar_rounded;
    }
    if (signal >= -70) {
      return Icons.signal_cellular_alt_rounded;
    }
    return Icons.signal_cellular_alt_1_bar_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B4EFF).withOpacity(0.08)
              : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF6B4EFF) : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6B4EFF).withOpacity(0.15)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isConnecting
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF6B4EFF),
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.bluetooth_rounded,
                      color: isSelected
                          ? const Color(0xFF6B4EFF)
                          : colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF6B4EFF)
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getSignalIcon(),
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$signal dBm',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected && !isConnecting)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF6B4EFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.primaryText,
    required this.primaryOnPressed,
    required this.secondaryText,
    required this.secondaryOnPressed,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String primaryText;
  final VoidCallback primaryOnPressed;
  final String secondaryText;
  final VoidCallback secondaryOnPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: primaryOnPressed,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  primaryText,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: secondaryOnPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                secondaryText,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.isSecondary = false,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool isSecondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSecondary
              ? Colors.grey[50]
              : const Color(0xFF6B4EFF).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSecondary
                ? Colors.grey[200]!
                : const Color(0xFF6B4EFF).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSecondary
                    ? Colors.grey[100]
                    : const Color(0xFF6B4EFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSecondary ? Colors.grey[600] : const Color(0xFF6B4EFF),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSecondary
                          ? Colors.grey[700]
                          : const Color(0xFF6B4EFF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}
