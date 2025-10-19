import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/esp32_wifi_config_service.dart';

// Provider para el servicio de configuración WiFi del ESP32
final esp32WifiConfigServiceProvider = Provider<ESP32WifiConfigService>((ref) {
  throw UnimplementedError('ESP32WifiConfigService must be overridden');
});


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

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connectToWifi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    final esp32service = ref.read(esp32WifiConfigServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final result = await esp32service.sendWifiCredentials(
        ssid: _ssidController.text.trim(),
        password: _passwordController.text,
      );

      if (result.success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Credentials sent! Waiting for connection...'),
            backgroundColor: Colors.green,
          ),
        );
        await Future<void>.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.push(AppConstants.routeToyNameSetup);
        }
      } else {
        throw Exception(result.message);
      }
    } on Exception catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to send credentials: $e'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
          onPressed: () => context.push(AppConstants.routeToyNameSetup),
          child: Text(
            'setup.wifi.skip_button'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white.withAlpha(204)),
          ),
        ),
      ],
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
              color: index < current ? Colors.white : Colors.white.withAlpha(77),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
}