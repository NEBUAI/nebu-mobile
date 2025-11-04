import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/esp32_provider.dart';


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

  @override
  void initState() {
    super.initState();
    _subscribeToWifiStatus();
  }

  void _subscribeToWifiStatus() {
    final esp32service = ref.read(esp32WifiConfigServiceProvider);

    _statusSubscription = esp32service.statusStream.listen(
      (status) {
        if (!mounted) {
          return;
        }

        final messenger = ScaffoldMessenger.of(context);

        switch (status) {
          case ESP32WifiStatus.idle:
            // No hacer nada
            break;

          case ESP32WifiStatus.connecting:
            messenger.showSnackBar(
              SnackBar(
                content: Text('setup.wifi.status_connecting'.tr()),
                backgroundColor: Colors.blue,
                duration: const Duration(seconds: 2),
              ),
            );
            break;

          case ESP32WifiStatus.connected:
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
                context.push(AppConstants.routeToyNameSetup);
              }
            });
            break;

          case ESP32WifiStatus.failed:
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
      onError: (error) {
        if (!mounted) {
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
        if (!mounted) {
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
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _statusSubscription?.cancel();
    _timeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _connectToWifi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Prevenir múltiples llamadas simultáneas
    if (_isConnecting) {
      return;
    }

    final esp32service = ref.read(esp32WifiConfigServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    setState(() {
      _isConnecting = true;
    });

    try {
      final result = await esp32service.sendWifiCredentials(
        ssid: _ssidController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.credentials_sent'.tr()),
            backgroundColor: Colors.green,
          ),
        );

        // Iniciar timeout de 45 segundos
        _timeoutTimer = Timer(const Duration(seconds: 45), () {
          if (_isConnecting && mounted) {
            _showTimeoutDialog();
          }
        });

        // El statusStream se encargará de actualizar la UI cuando el ESP32 responda
      } else {
        throw Exception(result.message);
      }
    } on Exception catch (e) {
      final errorMsg = e.toString().toLowerCase();

      // Detectar tipo de error específico
      if (errorMsg.contains('disconnected') ||
          errorMsg.contains('connection') ||
          errorMsg.contains('not connected')) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_ble_disconnected'.tr()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      } else if (errorMsg.contains('timeout') || errorMsg.contains('timed out')) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('setup.wifi.error_ble_timeout'.tr()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
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
    final shouldContinue = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('setup.wifi.timeout_dialog_title'.tr()),
        content: Text('setup.wifi.timeout_dialog_message'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('setup.wifi.keep_waiting'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('setup.wifi.continue_anyway'.tr()),
          ),
        ],
      ),
    );

    if ((shouldContinue ?? false) && mounted) {
      setState(() {
        _isConnecting = false;
      });
      await context.push(AppConstants.routeToyNameSetup);
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

  Widget _buildHeader(BuildContext context) {
    return Row(
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
  }

  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Text(
          'setup.wifi.title'.tr(),
          style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'setup.wifi.subtitle'.tr(),
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withAlpha(230)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSsidInput(ThemeData theme) {
    return TextFormField(
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
  }

  Widget _buildPasswordInput(ThemeData theme) {
    return TextFormField(
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
  }

  InputDecoration _buildInputDecoration(ThemeData theme, String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
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
  }

  Widget _buildFooterButtons(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _isConnecting ? null : _connectToWifi,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.primaryLight,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _isConnecting
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3, color: AppTheme.primaryLight),
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
            _isConnecting ? 'setup.wifi.cancel_button'.tr() : 'setup.wifi.skip_button'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: _isConnecting ? Colors.red.withAlpha(204) : Colors.white.withAlpha(204),
            ),
          ),
        ),
      ],
    );
  }

  void _cancelConnection() {
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
    context.push(AppConstants.routeToyNameSetup);
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