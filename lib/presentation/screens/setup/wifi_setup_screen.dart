
import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart' as logger;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';
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

  void _log(String message) {
    if (kDebugMode) {
      _log(message);
    }
  }

  @override
  void initState() {
    super.initState();
    _log('🎬 [WIFI_SCREEN] Initializing WiFi setup screen');
    _subscribeToWifiStatus();
  }

  Future<void> _subscribeToWifiStatus() async {
    _log('🔔 [WIFI_SCREEN] Subscribing to ESP32 status stream');

    final esp32service = await ref.read(esp32WifiConfigServiceProvider.future);

    if (!mounted) {
      return;
    }

    _statusSubscription = esp32service.statusStream.listen(
      (status) {
        _log('🔔 [WIFI_SCREEN] Received status update: $status');

        if (!mounted) {
          _log('⚠️  [WIFI_SCREEN] Widget not mounted, ignoring status');
          return;
        }

        final messenger = ScaffoldMessenger.of(context);

        switch (status) {
          case ESP32WifiStatus.idle:
            _log('💤 [WIFI_SCREEN] Status IDLE - no action required');
            break;

          case ESP32WifiStatus.connecting:
            _log('🔵 [WIFI_SCREEN] Status CONNECTING - showing snackbar');
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connecting'.tr()),
                backgroundColor: context.colors.info,
                duration: const Duration(seconds: 2),
              ),
            );
            break;

          case ESP32WifiStatus.reconnecting:
            _log(
              '🔄 [WIFI_SCREEN] Status RECONNECTING - showing snackbar',
            );
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_reconnecting'.tr()),
                backgroundColor: context.colors.warning,
                duration: const Duration(seconds: 2),
              ),
            );
            break;

          case ESP32WifiStatus.connected:
            _log(
              '✅ [WIFI_SCREEN] Status CONNECTED - navigating to next step',
            );

            // Cancelar timeout si existe
            _timeoutTimer?.cancel();

            setState(() {
              _isConnecting = false;
            });

            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connected'.tr()),
                backgroundColor: context.colors.success,
              ),
            );

            // Continuar al siguiente paso
            unawaited(Future<void>.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                _log('➡️  [WIFI_SCREEN] Navigating to ToyNameSetup');
                context.push(AppRoutes.toyNameSetup.path);
              }
            }));
            break;

          case ESP32WifiStatus.failed:
            _log('❌ [WIFI_SCREEN] Status FAILED - showing retry option');

            // Cancelar timeout si existe
            _timeoutTimer?.cancel();

            setState(() {
              _isConnecting = false;
            });

            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_failed'.tr()),
                backgroundColor: context.colors.error,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'setup.wifi.retry'.tr(),
                  textColor: context.colors.textOnFilled,
                  onPressed: _connectToWifi,
                ),
              ),
            );
            break;
        }
      },
      onError: (Object error) {
        _log('❌ [WIFI_SCREEN] Stream error: $error');

        if (!mounted) {
          _log('⚠️  [WIFI_SCREEN] Widget not mounted, ignoring error');
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
              backgroundColor: context.colors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      onDone: () {
        _log('⚠️  [WIFI_SCREEN] Status stream closed');

        if (!mounted) {
          _log(
            '⚠️  [WIFI_SCREEN] Widget not mounted, ignoring stream close',
          );
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
              backgroundColor: context.colors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
    );

    _log('✅ [WIFI_SCREEN] Subscribed to status stream successfully');
  }

  @override
  void dispose() {
    _log('🔚 [WIFI_SCREEN] Disposing WiFi setup screen');
    _ssidController.dispose();
    _passwordController.dispose();
    _statusSubscription?.cancel();
    _timeoutTimer?.cancel();
    _log('🔚 [WIFI_SCREEN] Disposed successfully');
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('qr_scanner.invalid_wifi_qr'.tr())));
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
        SnackBar(content: Text('qr_scanner.wifi_loaded'.tr())),
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
            SnackBar(content: Text('qr_scanner.wifi_name_error'.tr())),
          );
        }
      } on Exception {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('setup.wifi.error_generic'.tr())));
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('qr_scanner.location_permission_required'.tr()),
        ),
      );
    }
  }

  Future<void> _showWifiNetworksSheet() async {
    final esp32Service = await ref.read(esp32WifiConfigServiceProvider.future);
    if (!mounted) {
      return;
    }
    final wifiService = WiFiService(
      logger: logger.Logger(),
      esp32WifiConfigService: esp32Service,
    );

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
    _log('📡 [WIFI_SCREEN] Connect button pressed');

    if (!_formKey.currentState!.validate()) {
      _log('⚠️  [WIFI_SCREEN] Form validation failed');
      return;
    }

    // Prevenir múltiples llamadas simultáneas
    if (_isConnecting) {
      _log(
        '⚠️  [WIFI_SCREEN] Already connecting, ignoring duplicate request',
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    _log('📡 [WIFI_SCREEN] Starting WiFi connection process');
    _log('📡 [WIFI_SCREEN] SSID: "${_ssidController.text.trim()}"');

    setState(() {
      _isConnecting = true;
    });

    try {
      final service = await ref.read(esp32WifiConfigServiceProvider.future);
      _log('📤 [WIFI_SCREEN] Sending WiFi credentials to ESP32');

      final result = await service.sendWifiCredentials(
        ssid: _ssidController.text.trim(),
        password: _passwordController.text,
      );

      _log(
        '📤 [WIFI_SCREEN] Send result: ${result.success ? "SUCCESS" : "FAILED"}',
      );
      if (!result.success) {
        _log('📤 [WIFI_SCREEN] Error message: ${result.message}');
      }

      if (result.success) {
        _log('✅ [WIFI_SCREEN] Credentials sent successfully');

        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.credentials_sent'.tr()),
            backgroundColor: context.colors.success,
          ),
        );

        // Iniciar timeout de 45 segundos
        _log('⏱️  [WIFI_SCREEN] Starting 45 second timeout timer');
        _timeoutTimer = Timer(const Duration(seconds: 45), () {
          _log('⏱️  [WIFI_SCREEN] Timeout reached after 45 seconds');
          if (_isConnecting && mounted) {
            _showTimeoutDialog();
          }
        });

        _log('🔔 [WIFI_SCREEN] Waiting for status updates from ESP32');
        // El statusStream se encargará de actualizar la UI cuando el ESP32 responda
      } else {
        _log(
          '❌ [WIFI_SCREEN] Failed to send credentials: ${result.message}',
        );
        throw Exception(result.message);
      }
    } on Exception catch (e) {
      _log('❌ [WIFI_SCREEN] Exception during WiFi connection: $e');
      final errorMsg = e.toString().toLowerCase();

      // Detectar tipo de error específico
      if (errorMsg.contains('disconnected') ||
          errorMsg.contains('connection') ||
          errorMsg.contains('not connected')) {
        _log('❌ [WIFI_SCREEN] BLE disconnection error detected');
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_ble_disconnected'.tr()),
            backgroundColor: context.colors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (errorMsg.contains('timeout') ||
          errorMsg.contains('timed out')) {
        _log('❌ [WIFI_SCREEN] BLE timeout error detected');
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_ble_timeout'.tr()),
            backgroundColor: context.colors.warning,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        _log('❌ [WIFI_SCREEN] Generic error: $e');
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_send_credentials'.tr()),
            backgroundColor: context.colors.error,
          ),
        );
      }

      setState(() {
        _isConnecting = false;
      });
    }
  }

  Future<void> _showTimeoutDialog() async {
    _log('⏱️  [WIFI_SCREEN] Showing timeout dialog to user');
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('setup.wifi.timeout_dialog_title'.tr()),
        content: Text('setup.wifi.timeout_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () {
              _log('⏱️  [WIFI_SCREEN] User chose to keep waiting');
              Navigator.of(context).pop(false);
            },
            child: Text('setup.wifi.keep_waiting'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              _log('⏱️  [WIFI_SCREEN] User chose to continue anyway');
              Navigator.of(context).pop(true);
            },
            child: Text('setup.wifi.continue_anyway'.tr()),
          ),
        ],
      ),
    );

    if ((shouldContinue ?? false) && mounted) {
      _log('➡️  [WIFI_SCREEN] Continuing to next step despite timeout');
      setState(() {
        _isConnecting = false;
      });
      await context.push(AppRoutes.toyNameSetup.path);
    } else {
      _log('⏱️  [WIFI_SCREEN] User still waiting for connection');
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
                            const SizedBox(height: 12),
                            _buildHotspotHint(),
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

  Widget _buildHotspotHint() => Row(
    children: [
      Icon(Icons.info_outline, size: 14, color: context.colors.textOnFilled.withAlpha(179)),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          'setup.wifi.hotspot_hint'.tr(),
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textOnFilled.withAlpha(179),
          ),
        ),
      ),
    ],
  );

  Widget _buildQuickActions(ThemeData theme) => Wrap(
    alignment: WrapAlignment.spaceEvenly,
    spacing: 8,
    runSpacing: 8,
    children: [
      _QuickActionButton(
        icon: Icons.qr_code_scanner,
        label: 'setup.wifi.qr_scan_label'.tr(),
        onPressed: _scanQrCode,
      ),
      _QuickActionButton(
        icon: Icons.wifi,
        label: 'setup.wifi.current_wifi_label'.tr(),
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
        icon: Icon(Icons.arrow_back, color: context.colors.textOnFilled),
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
        style: theme.textTheme.headlineMedium?.copyWith(color: context.colors.textOnFilled),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        'setup.wifi.subtitle'.tr(),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: context.colors.textOnFilled.withAlpha(230),
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildSsidInput(ThemeData theme) => TextFormField(
    controller: _ssidController,
    style: theme.textTheme.titleMedium?.copyWith(color: context.colors.textOnFilled),
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
    style: theme.textTheme.titleMedium?.copyWith(color: context.colors.textOnFilled),
    decoration: _buildInputDecoration(
      theme,
      'setup.wifi.password_hint'.tr(),
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: context.colors.textOnFilled.withAlpha(179),
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
  }) => InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: context.colors.textOnFilled.withAlpha(128)),
    filled: true,
    fillColor: context.colors.textOnFilled.withAlpha(51),
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
          backgroundColor: context.colors.bgPrimary,
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
                ? context.colors.error.withAlpha(204)
                : context.colors.textOnFilled.withAlpha(204),
          ),
        ),
      ),
    ],
  );

  void _cancelConnection() {
    _log('🛑 [WIFI_SCREEN] User cancelled WiFi connection');
    _timeoutTimer?.cancel();
    setState(() {
      _isConnecting = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('setup.wifi.connection_cancelled'.tr()),
        backgroundColor: context.colors.warning,
      ),
    );
  }

  void _skipWifiSetup() {
    _log('⏭️  [WIFI_SCREEN] User skipped WiFi setup');
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
          color: index < current ? context.colors.textOnFilled : context.colors.textOnFilled.withAlpha(77),
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
          color: context.colors.textOnFilled.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.textOnFilled.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: context.colors.textOnFilled, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: context.colors.textOnFilled),
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
  final void Function(String) onNetworkSelected;

  @override
  State<_WifiNetworksSheet> createState() => _WifiNetworksSheetState();
}

class _WifiNetworksSheetState extends State<_WifiNetworksSheet> {
  bool _isLoading = true;
  List<WiFiNetwork> _networks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  Future<void> _scanNetworks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final networks = await widget.wifiService.scanNetworks();
      if (mounted) {
        setState(() {
          _networks = networks;
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: const BoxDecoration(
        color: context.colors.textOnFilled,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'setup.wifi.scan_networks'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.onBackgroundLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _scanNetworks,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: context.colors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'setup.wifi.scan_error'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _scanNetworks,
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            )
          else if (_networks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'setup.wifi.no_networks_found'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _networks.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final network = _networks[index];
                  return ListTile(
                    leading: const Icon(Icons.wifi),
                    title: Text(network.ssid),
                    subtitle: Text(
                      'setup.wifi.signal_info'.tr(args: ['${network.rssi}']),
                      style: theme.textTheme.bodySmall,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      widget.onNetworkSelected(network.ssid);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('common.cancel'.tr()),
          ),
        ],
      ),
    );
  }
}
