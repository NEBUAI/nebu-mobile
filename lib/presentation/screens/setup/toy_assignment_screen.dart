import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/toy.dart';
import '../../../data/services/toy_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input.dart';

class ToyAssignmentScreen extends StatefulWidget {
  const ToyAssignmentScreen({
    required this.macAddress,
    required this.userId,
    required this.toyService,
    required this.logger,
    this.onAssignmentComplete,
    super.key,
  });

  final String macAddress;
  final String userId;
  final ToyService toyService;
  final Logger logger;
  final void Function(Toy toy)? onAssignmentComplete;

  @override
  State<ToyAssignmentScreen> createState() => _ToyAssignmentScreenState();
}

class _ToyAssignmentScreenState extends State<ToyAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toyNameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _toyNameController.dispose();
    super.dispose();
  }

  Future<void> _assignToy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await widget.toyService.assignToy(
        macAddress: widget.macAddress,
        userId: widget.userId,
        toyName: _toyNameController.text.trim().isEmpty
            ? null
            : _toyNameController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      if (response.success && response.toy != null) {
        // Llamar al callback si existe
        widget.onAssignmentComplete?.call(response.toy!);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'toy_assignment.success'.tr()),
            backgroundColor: context.colors.success,
          ),
        );

        // Navegar hacia atrás con el juguete asignado
        Navigator.of(context).pop(response.toy);
      } else {
        setState(() {
          _errorMessage = response.message ?? 'toy_assignment.error'.tr();
          _isLoading = false;
        });
      }
    } on Exception catch (e) {
      widget.logger.e('Error assigning toy: $e');
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
      appBar: AppBar(title: Text('toy_assignment.title'.tr()), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono del juguete
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.toys,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  'toy_assignment.heading'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Descripción
                Text(
                  'toy_assignment.description'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // MAC Address (solo lectura)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: context.radius.tile,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bluetooth, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'toy_assignment.device'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.macAddress,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Campo de nombre del juguete
                CustomInput(
                  controller: _toyNameController,
                  label: 'toy_assignment.toy_name'.tr(),
                  hint: 'toy_assignment.toy_name_hint'.tr(),
                  prefixIcon: const Icon(Icons.edit),
                ),
                const SizedBox(height: 24),

                // Mensaje de error
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: context.radius.tile,
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

                const Spacer(),

                // Botón de asignar
                CustomButton(
                  text: 'toy_assignment.assign'.tr(),
                  onPressed: _isLoading ? null : _assignToy,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),

                // Botón de cancelar
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text('common.cancel'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
