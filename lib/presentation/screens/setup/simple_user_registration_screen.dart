import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../core/constants/app_routes.dart';
import '../../providers/api_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

/// Pantalla de registro simple de usuario (sin login/autenticación)
/// Este flujo permite crear un usuario y asignarle un juguete directamente
class SimpleUserRegistrationScreen extends ConsumerStatefulWidget {
  const SimpleUserRegistrationScreen({super.key});

  @override
  ConsumerState<SimpleUserRegistrationScreen> createState() =>
      _SimpleUserRegistrationScreenState();
}

class _SimpleUserRegistrationScreenState
    extends ConsumerState<SimpleUserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _logger = Logger();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = ref.read(userServiceProvider);

      final user = await userService.createUser(
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        password: _passwordController.text,
      );

      _logger.d('User created successfully: ${user.id}');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('simple_registration.success'.tr()),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a la pantalla de configuración del dispositivo
      // para asignar el juguete al usuario
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) {
        await context.push(AppRoutes.connectionSetup.path);
      }
    } on Exception catch (e) {
      _logger.e('Error creating user: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('simple_registration.title'.tr()), elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  'simple_registration.create_account'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Descripción
                Text(
                  'simple_registration.subtitle'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Nombre
                CustomInput(
                  controller: _firstNameController,
                  label: 'simple_registration.first_name'.tr(),
                  hint: 'simple_registration.first_name_hint'.tr(),
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'simple_registration.first_name_required'.tr();
                    }
                    if (value.trim().length < 2) {
                      return 'simple_registration.first_name_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Apellido
                CustomInput(
                  controller: _lastNameController,
                  label: 'simple_registration.last_name'.tr(),
                  hint: 'simple_registration.last_name_hint'.tr(),
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'simple_registration.last_name_required'.tr();
                    }
                    if (value.trim().length < 2) {
                      return 'simple_registration.last_name_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                CustomInput(
                  controller: _emailController,
                  label: 'simple_registration.email'.tr(),
                  hint: 'simple_registration.email_hint'.tr(),
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'simple_registration.email_required'.tr();
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value.trim())) {
                      return 'simple_registration.email_invalid'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Contraseña
                CustomInput(
                  controller: _passwordController,
                  label: 'simple_registration.password'.tr(),
                  hint: 'simple_registration.password_hint'.tr(),
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'simple_registration.password_required'.tr();
                    }
                    if (value.length < 8) {
                      return 'simple_registration.password_short'.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Mensaje de error
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Botón de registro
                CustomButton(
                  text: 'simple_registration.register'.tr(),
                  onPressed: _isLoading ? null : _registerUser,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),

                // Información adicional
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'simple_registration.info_text'.tr(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
