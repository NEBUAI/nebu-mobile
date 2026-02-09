import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart' as logger;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/esp32_wifi_config_service.dart';
import '../../../data/services/wifi_service.dart';
import '../../providers/api_provider.dart';

class WifiSetupScreen extends ConsumerStatefulWidget {
  const WifiSetupScreen({super.key});

  @override
  ConsumerState<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends ConsumerState<WifiSetupScreen> {
  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConnecting = false;
  StreamSubscription<ESP32WifiStatus>? _statusSubscription;
  Timer? _timeoutTimer;
  final _networkInfo = NetworkInfo();

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 [WIFI_SCREEN] Initializing WiFi setup screen');
    _subscribeToWifiStatus();
  }

  Future<void> _subscribeToWifiStatus() async {
    debugPrint('🔔 [WIFI_SCREEN] Subscribing to ESP32 status stream');

    final esp32service = await ref.read(esp32WifiConfigServiceProvider.future);

    if (!mounted) {
      return;
    }

    _statusSubscription = esp32service.statusStream.listen(
      (status) {
        debugPrint('🔔 [WIFI_SCREEN] Received status update: $status');

        if (!mounted) {
          debugPrint('⚠️  [WIFI_SCREEN] Widget not mounted, ignoring status');
          return;
        }

        final messenger = ScaffoldMessenger.of(context);

        switch (status) {
          case ESP32WifiStatus.idle:
            debugPrint('💤 [WIFI_SCREEN] Status IDLE - no action required');
            break;

          case ESP32WifiStatus.connecting:
            debugPrint('🔵 [WIFI_SCREEN] Status CONNECTING - showing snackbar');
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connecting'.tr()),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
            break;

          case ESP32WifiStatus.reconnecting:
            debugPrint('🔄 [WIFI_SCREEN] Status RECONNECTING - showing snackbar');
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_reconnecting'.tr()),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
            break;

          case ESP32WifiStatus.connected:
            debugPrint('✅ [WIFI_SCREEN] Status CONNECTED - navigating to next step');

            // Cancelar timeout si existe
            _timeoutTimer?.cancel();

            setState(() {
              _isConnecting = false;
            });

            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connected'.tr()),
                backgroundColor: Colors.green,
              ),
            );

            // Continuar al siguiente paso
            Future<void>.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                debugPrint('➡️  [WIFI_SCREEN] Navigating to ToyNameSetup');
                context.push(AppRoutes.toyNameSetup.path);
              }
            });
            break;

          case ESP32WifiStatus.failed:
            debugPrint('❌ [WIFI_SCREEN] Status FAILED - showing retry option');

            // Cancelar timeout si existe
            _timeoutTimer?.cancel();

            setState(() {
              _isConnecting = false;
            });

            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_failed'.tr()),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'setup.wifi.retry'.tr(),
                  textColor: Colors.white,
                  onPressed: _connectToWifi,
                ),
              ),
            );
            break;
        }
      },
      onError: (Object error) {
        debugPrint('❌ [WIFI_SCREEN] Stream error: $error');

        if (!mounted) {
          debugPrint('⚠️  [WIFI_SCREEN] Widget not mounted, ignoring error');
          return;
        }

        _timeoutTimer?.cancel();

        if (_isConnecting) {
          setState(() {
            _isConnecting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('setup.wifi.error_status_stream'.tr()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      onDone: () {
        debugPrint('⚠️  [WIFI_SCREEN] Status stream closed');

        if (!mounted) {
          debugPrint('⚠️  [WIFI_SCREEN] Widget not mounted, ignoring stream close');
          return;
        }

        _timeoutTimer?.cancel();

        // El stream se cerró (ESP32 desconectado?)
        if (_isConnecting) {
          setState(() {
            _isConnecting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('setup.wifi.error_ble_disconnected'.tr()),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
    );

    debugPrint('✅ [WIFI_SCREEN] Subscribed to status stream successfully');
  }

  @override
  void dispose() {
    debugPrint('🔚 [WIFI_SCREEN] Disposing WiFi setup screen');
    _ssidController.dispose();
    _passwordController.dispose();
    _statusSubscription?.cancel();
    _timeoutTimer?.cancel();
    debugPrint('🔚 [WIFI_SCREEN] Disposed successfully');
    super.dispose();
  }

  Future<void> _scanQrCode() async {
    final result = await context.push<String>(AppRoutes.qrScanner.path);
    if (result != null && mounted) {
      _parseWifiQr(result);
    }
  }

  void _parseWifiQr(String qrData) {
    // Standard format: WIFI:S:<SSID>;T:<TYPE>;P:<PASSWORD>;H:<HIDDEN>;;
    if (!qrData.startsWith('WIFI:')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid WiFi QR Code')),
      );
      return;
    }

    final ssidMatch = RegExp('S:(.*?);').firstMatch(qrData);
    final passwordMatch = RegExp('P:(.*?);').firstMatch(qrData);

    if (ssidMatch != null) {
      setState(() {
        _ssidController.text = ssidMatch.group(1) ?? '';
        if (passwordMatch != null) {
          _passwordController.text = passwordMatch.group(1) ?? '';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WiFi credentials loaded from QR')),
      );
    }
  }

  Future<void> _getCurrentWifi() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      try {
        final wifiName = await _networkInfo.getWifiName();
        if (wifiName != null && mounted) {
          setState(() {
            // Remove quotes if present
            _ssidController.text = wifiName.replaceAll('"', '');
          });
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch WiFi name')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required to get WiFi name')),
      );
    }
  }

  Future<void> _showWifiNetworksSheet() async {
    final wifiService = WiFiService(logger: logger.Logger());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _WifiNetworksSheet(
        wifiService: wifiService,
        onNetworkSelected: (ssid) {
          setState(() {
            _ssidController.text = ssid;
          });
        },
      ),
    );
  }

  Future<void> _connectToWifi() async {
    debugPrint('📡 [WIFI_SCREEN] Connect button pressed');

    if (!_formKey.currentState!.validate()) {
      debugPrint('⚠️  [WIFI_SCREEN] Form validation failed');
      return;
    }

    // Prevenir múltiples llamadas simultáneas
    if (_isConnecting) {
      debugPrint('⚠️  [WIFI_SCREEN] Already connecting, ignoring duplicate request');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    debugPrint('📡 [WIFI_SCREEN] Starting WiFi connection process');
    debugPrint('📡 [WIFI_SCREEN] SSID: "${_ssidController.text.trim()}"');

    setState(() {
      _isConnecting = true;
    });

    try {
      final service = await ref.read(esp32WifiConfigServiceProvider.future);
      debugPrint('📤 [WIFI_SCREEN] Sending WiFi credentials to ESP32');

      final result = await service.sendWifiCredentials(
        ssid: _ssidController.text.trim(),
        password: _passwordController.text,
      );

      debugPrint('📤 [WIFI_SCREEN] Send result: ${result.success ? "SUCCESS" : "FAILED"}');
      if (!result.success) {
        debugPrint('📤 [WIFI_SCREEN] Error message: ${result.message}');
      }

      if (result.success) {
        debugPrint('✅ [WIFI_SCREEN] Credentials sent successfully');

        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.credentials_sent'.tr()),
            backgroundColor: Colors.green,
          ),
        );

        // Iniciar timeout de 45 segundos
        debugPrint('⏱️  [WIFI_SCREEN] Starting 45 second timeout timer');
        _timeoutTimer = Timer(const Duration(seconds: 45), () {
          debugPrint('⏱️  [WIFI_SCREEN] Timeout reached after 45 seconds');
          if (_isConnecting && mounted) {
            _showTimeoutDialog();
          }
        });

        debugPrint('🔔 [WIFI_SCREEN] Waiting for status updates from ESP32');
        // El statusStream se encargará de actualizar la UI cuando el ESP32 responda
      } else {
        debugPrint('❌ [WIFI_SCREEN] Failed to send credentials: ${result.message}');
        throw Exception(result.message);
      }
    } on Exception catch (e) {
      debugPrint('❌ [WIFI_SCREEN] Exception during WiFi connection: $e');
      final errorMsg = e.toString().toLowerCase();

      // Detectar tipo de error específico
      if (errorMsg.contains('disconnected') ||
          errorMsg.contains('connection') ||
          errorMsg.contains('not connected')) {
        debugPrint('❌ [WIFI_SCREEN] BLE disconnection error detected');
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_ble_disconnected'.tr()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (errorMsg.contains('timeout') ||
          errorMsg.contains('timed out')) {
        debugPrint('❌ [WIFI_SCREEN] BLE timeout error detected');
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_ble_timeout'.tr()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        debugPrint('❌ [WIFI_SCREEN] Generic error: $e');
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to send credentials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _showTimeoutDialog() async {
    debugPrint('⏱️  [WIFI_SCREEN] Showing timeout dialog to user');
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('setup.wifi.timeout_dialog_title'.tr()),
        content: Text('setup.wifi.timeout_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('⏱️  [WIFI_SCREEN] User chose to keep waiting');
              Navigator.of(context).pop(false);
            },
            child: Text('setup.wifi.keep_waiting'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('⏱️  [WIFI_SCREEN] User chose to continue anyway');
              Navigator.of(context).pop(true);
            },
            child: Text('setup.wifi.continue_anyway'.tr()),
          ),
        ],
      ),
    );

    if ((shouldContinue ?? false) && mounted) {
      debugPrint('➡️  [WIFI_SCREEN] Continuing to next step despite timeout');
      setState(() {
        _isConnecting = false;
      });
      await context.push(AppRoutes.toyNameSetup.path);
    } else {
      debugPrint('⏱️  [WIFI_SCREEN] User still waiting for connection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !_isConnecting,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        if (_isConnecting && context.mounted) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text('setup.wifi.cancel_dialog_title'.tr()),
              content: Text('setup.wifi.cancel_dialog_message'.tr()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text('common.no'.tr()),
                ),
                TextButton(
                  onPressed: () {
                    _timeoutTimer?.cancel();
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text('common.yes'.tr()),
                ),
              ],
            ),
          );

          if ((shouldPop ?? false) && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: DecoratedBox(
          decoration: AppTheme.primaryGradientDecoration,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildTitle(theme),
                            const SizedBox(height: 40),
                            _buildQuickActions(theme),
                            const SizedBox(height: 16),
                            _buildSsidInput(theme),
                            const SizedBox(height: 20),
                            _buildPasswordInput(theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooterButtons(context, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) => Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 8,
        runSpacing: 8,
        children: [
          _QuickActionButton(
            icon: Icons.qr_code_scanner,
            label: 'QR Scan',
            onPressed: _scanQrCode,
          ),
          _QuickActionButton(
            icon: Icons.wifi,
            label: 'Current WiFi',
            onPressed: _getCurrentWifi,
          ),
          _QuickActionButton(
            icon: Icons.wifi_find,
            label: 'setup.wifi.scan_networks'.tr(),
            onPressed: _showWifiNetworksSheet,
          ),
        ],
      );

  Widget _buildHeader(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Spacer(),
          _buildProgressIndicator(2, 7), // This is now step 2
          const Spacer(),
          const Opacity(
            opacity: 0,
            child: IconButton(icon: Icon(Icons.arrow_back), onPressed: null),
          ),
        ],
      );

  Widget _buildTitle(ThemeData theme) => Column(
        children: [
          Text(
            'setup.wifi.title'.tr(),
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'setup.wifi.subtitle'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(230),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );

  Widget _buildSsidInput(ThemeData theme) => TextFormField(
        controller: _ssidController,
        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        decoration: _buildInputDecoration(theme, 'setup.wifi.ssid_hint'.tr()),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'setup.wifi.validation_ssid_empty'.tr();
          }

          // Validar longitud máxima del SSID (32 bytes en WiFi)
          if (value.trim().length > 32) {
            return 'setup.wifi.validation_ssid_too_long'.tr();
          }

          // Validar caracteres especiales problemáticos
          if (value.contains('\n') || value.contains('\r')) {
            return 'setup.wifi.validation_ssid_invalid_chars'.tr();
          }

          return null;
        },
      );

  Widget _buildPasswordInput(ThemeData theme) => TextFormField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
        decoration: _buildInputDecoration(
          theme,
          'setup.wifi.password_hint'.tr(),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withAlpha(179),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) {
          // Validar longitud mínima de WPA2 (8 caracteres) si no está vacío
          if (value != null && value.isNotEmpty && value.length < 8) {
            return 'setup.wifi.validation_password_too_short'.tr();
          }

          // Validar longitud máxima (63 caracteres para WPA2)
          if (value != null && value.length > 63) {
            return 'setup.wifi.validation_password_too_long'.tr();
          }

          return null;
        },
      );

  InputDecoration _buildInputDecoration(
    ThemeData theme,
    String hintText, {
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
        filled: true,
        fillColor: Colors.white.withAlpha(51),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
        suffixIcon: suffixIcon,
      );

  Widget _buildFooterButtons(BuildContext context, ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _isConnecting ? null : _connectToWifi,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isConnecting
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: AppTheme.primaryLight,
                    ),
                  )
                : Text(
                    'setup.wifi.connect_button'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isConnecting ? _cancelConnection : _skipWifiSetup,
            child: Text(
              _isConnecting
                  ? 'setup.wifi.cancel_button'.tr()
                  : 'setup.wifi.skip_button'.tr(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _isConnecting
                    ? Colors.red.withAlpha(204)
                    : Colors.white.withAlpha(204),
              ),
            ),
          ),
        ],
      );

  void _cancelConnection() {
    debugPrint('🛑 [WIFI_SCREEN] User cancelled WiFi connection');
    _timeoutTimer?.cancel();
    setState(() {
      _isConnecting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('setup.wifi.connection_cancelled'.tr()),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _skipWifiSetup() {
    debugPrint('⏭️  [WIFI_SCREEN] User skipped WiFi setup');
    context.push(AppRoutes.toyNameSetup.path);
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
              color: index < current ? Colors.white : Colors.white.withAlpha(77),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _WifiNetworksSheet extends StatefulWidget {
  const _WifiNetworksSheet({
    required this.wifiService,
    required this.onNetworkSelected,
  });

  final WiFiService wifiService;
  final ValueChanged<String> onNetworkSelected;

  @override
  State<_WifiNetworksSheet> createState() => _WifiNetworksSheetState();
}

class _WifiNetworksSheetState extends State<_WifiNetworksSheet> {
  List<WiFiNetwork> _networks = [];
  bool _isScanning = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scan();
  }

  @override
  void dispose() {
    widget.wifiService.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final networks = await widget.wifiService.scanNetworks();
      if (mounted) {
        setState(() {
          _networks = networks;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _error = e.toString();
        });
      }
    }
  }

  IconData _signalIcon(int rssi) {
    if (rssi >= -50) {
      return Icons.network_wifi;
    }
    if (rssi >= -70) {
      return Icons.network_wifi_3_bar;
    }
    if (rssi >= -80) {
      return Icons.network_wifi_2_bar;
    }
    return Icons.network_wifi_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(77),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Text(
                  'setup.wifi.available_networks'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isScanning ? null : _scan,
                  icon: Icon(
                    Icons.refresh,
                    color: _isScanning
                        ? Colors.white.withAlpha(77)
                        : Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          // Content
          Flexible(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isScanning) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'setup.wifi.scanning'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(179),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'setup.wifi.scan_error'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(179),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _scan,
              child: Text(
                'setup.wifi.retry'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_networks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: Colors.white.withAlpha(128), size: 48),
            const SizedBox(height: 12),
            Text(
              'setup.wifi.no_networks_found'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withAlpha(179),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _scan,
              child: Text(
                'setup.wifi.retry'.tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _networks.length,
      separatorBuilder: (_, _) =>
          const Divider(color: Colors.white12, height: 1, indent: 56),
      itemBuilder: (context, index) {
        final network = _networks[index];
        return ListTile(
          leading: Icon(
            _signalIcon(network.rssi),
            color: Colors.white,
          ),
          title: Text(
            network.ssid,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          subtitle: Text(
            '${network.security} · ${network.rssi} dBm',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withAlpha(128),
            ),
          ),
          trailing: network.security != 'Open'
              ? Icon(Icons.lock, color: Colors.white.withAlpha(128), size: 18)
              : null,
          onTap: () {
            widget.onNetworkSelected(network.ssid);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}
