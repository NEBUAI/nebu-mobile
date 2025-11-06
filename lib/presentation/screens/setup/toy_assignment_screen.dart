import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

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

      if (!mounted) return;

      if (response.success && response.toy != null) {
        // Llamar al callback si existe
        widget.onAssignmentComplete?.call(response.toy!);

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Juguete asignado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Navegar hacia atrás con el juguete asignado
        Navigator.of(context).pop(response.toy);
      } else {
        setState(() {
          _errorMessage = response.message ?? 'No se pudo asignar el juguete';
          _isLoading = false;
        });
      }
    } catch (e) {
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
      appBar: AppBar(title: const Text('Configurar Juguete'), elevation: 0),
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
                  'Conecta tu Juguete',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Descripción
                Text(
                  'Estás a punto de asignar este juguete a tu cuenta. '
                  'Puedes darle un nombre personalizado para identificarlo fácilmente.',
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.bluetooth, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispositivo',
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
                  label: 'Nombre del Juguete (Opcional)',
                  hint: 'Ej: Mi Robot Favorito',
                  prefixIcon: const Icon(Icons.edit),
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

                const Spacer(),

                // Botón de asignar
                CustomButton(
                  text: 'Asignar Juguete',
                  onPressed: _isLoading ? null : _assignToy,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),

                // Botón de cancelar
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
