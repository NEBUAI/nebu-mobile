import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';
import '../widgets/esp32_audio_controls.dart';

class ToySettingsScreen extends ConsumerStatefulWidget {
  const ToySettingsScreen({required this.toy, super.key});

  final Toy toy;

  @override
  ConsumerState<ToySettingsScreen> createState() => _ToySettingsScreenState();
}

class _ToySettingsScreenState extends ConsumerState<ToySettingsScreen> {
  late final TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.toy.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateToySettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(toyProvider.notifier).updateToy(
            id: widget.toy.id,
            name: _nameController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toy_settings.update_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toy_settings.update_error'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteToy() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(toyProvider.notifier).deleteToy(widget.toy.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toy_settings.remove_success'.tr()),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toy_settings.remove_error'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('toy_settings.remove_title'.tr()),
        content: Text('toy_settings.remove_confirm'.tr(args: [widget.toy.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteToy();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('toy_settings.title'.tr())),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toy Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor:
                                  AppTheme.primaryLight.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.smart_toy,
                                size: 48,
                                color: AppTheme.primaryLight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.toy.model ?? 'toy_settings.unknown_model'.tr(),
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'ID: ${widget.toy.iotDeviceId}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Name Setting
                    Text(
                      'toy_settings.toy_name'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'toy_settings.toy_name_hint'.tr(),
                        prefixIcon: const Icon(Icons.label),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'toy_settings.toy_name_required'.tr();
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Device Status
                    Text(
                      'toy_settings.device_status'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildStatusRow(
                              'toy_settings.status'.tr(),
                              widget.toy.status.toString().split('.').last,
                              theme,
                            ),
                            const Divider(),
                            if (widget.toy.batteryLevel != null)
                              _buildStatusRow(
                                'toy_settings.battery'.tr(),
                                widget.toy.batteryLevel!,
                                theme,
                              ),
                            if (widget.toy.batteryLevel != null)
                              const Divider(),
                            _buildStatusRow(
                              'toy_settings.model'.tr(),
                              widget.toy.model ?? 'toy_settings.unknown'.tr(),
                              theme,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Audio Controls (Volume & Mute)
                    Text(
                      'toy_settings.audio_controls'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const ESP32AudioControls(),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _updateToySettings,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppTheme.primaryLight,
                      ),
                      child: Text('toy_settings.save_changes'.tr()),
                    ),

                    const SizedBox(height: 16),

                    // Remove Toy Button
                    OutlinedButton.icon(
                      onPressed: _showDeleteConfirmation,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: Text(
                        'toy_settings.remove_title'.tr(),
                        style: const TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusRow(String label, String value, ThemeData theme) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
}
