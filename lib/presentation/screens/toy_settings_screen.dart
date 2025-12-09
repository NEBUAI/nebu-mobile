import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(toyProvider.notifier).updateToy(
            id: widget.toy.id,
            name: _nameController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toy settings updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update toy settings: $e'),
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
          const SnackBar(
            content: Text('Toy removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove toy: $e'),
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
        title: const Text('Remove Toy'),
        content: Text('Are you sure you want to remove ${widget.toy.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteToy();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Toy Settings')),
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
                              widget.toy.model ?? 'Unknown Model',
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
                      'Toy Name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter toy name',
                        prefixIcon: const Icon(Icons.label),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a toy name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Device Status
                    Text(
                      'Device Status',
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
                              'Status',
                              widget.toy.status.toString().split('.').last,
                              theme,
                            ),
                            const Divider(),
                            if (widget.toy.batteryLevel != null)
                              _buildStatusRow(
                                'Battery',
                                widget.toy.batteryLevel!,
                                theme,
                              ),
                            if (widget.toy.batteryLevel != null)
                              const Divider(),
                            _buildStatusRow(
                              'Model',
                              widget.toy.model ?? 'Unknown',
                              theme,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: _updateToySettings,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: AppTheme.primaryLight,
                      ),
                      child: const Text('Save Changes'),
                    ),

                    const SizedBox(height: 16),

                    // Remove Toy Button
                    OutlinedButton.icon(
                      onPressed: _showDeleteConfirmation,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Remove Toy',
                        style: TextStyle(color: Colors.red),
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
