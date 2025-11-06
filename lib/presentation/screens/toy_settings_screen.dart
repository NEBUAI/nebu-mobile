import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../core/theme/app_theme.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';

class ToySettingsController extends GetxController {
  ToySettingsController(this.toy, this.toyProvider);
  final Toy toy;
  final ToyProvider toyProvider;

  final isLoading = false.obs;
  late final name = toy.name.obs;
  late final firmwareVersion = (toy.firmwareVersion ?? 'Unknown').obs;

  final voiceOptions = ['Default', 'Child', 'Robot', 'Funny'];

  Future<void> updateToySettings({
    required String newName,
    Map<String, dynamic>? settings,
  }) async {
    isLoading.value = true;

    try {
      await toyProvider.updateToy(
        id: toy.id,
        updates: {'name': newName, if (settings != null) 'settings': settings},
      );

      name.value = newName;

      Get.snackbar(
        'Success',
        'Toy settings updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update toy settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteToy() async {
    isLoading.value = true;

    try {
      await toyProvider.deleteToy(toy.id);

      Get.snackbar(
        'Success',
        'Toy removed successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Go back to previous screen
      Get.back<void>();
      Get.back<void>();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove toy: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }
}

class ToySettingsScreen extends StatelessWidget {
  const ToySettingsScreen({required this.toy, super.key});

  final Toy toy;

  @override
  Widget build(BuildContext context) {
    final toyProvider = Get.find<ToyProvider>();
    final controller = Get.put(ToySettingsController(toy, toyProvider));
    final theme = Theme.of(context);

    final nameController = TextEditingController(text: toy.name);
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Toy Settings')),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
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
                                backgroundColor: AppTheme.primaryLight
                                    .withValues(alpha: 0.2),
                                child: const Icon(
                                  Icons.smart_toy,
                                  size: 48,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                toy.model,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              if (toy.macAddress != null)
                                Text(
                                  'MAC: ${toy.macAddress}',
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
                        controller: nameController,
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

                      // Personality Setting
                      Text(
                        'Personality',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: controller.personalities
                              .map(
                                (p) => RadioListTile<String>(
                                  title: Text(p.capitalize ?? p),
                                  value: p,
                                  groupValue: controller.personality.value,
                                  onChanged: (value) {
                                    if (value != null) {
                                      controller.personality.value = value;
                                    }
                                  },
                                ),
                              )
                              .toList(),
                        ),
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
                                'Connection',
                                toy.connectionStatus,
                                theme,
                              ),
                              const Divider(),
                              if (toy.batteryLevel != null)
                                _buildStatusRow(
                                  'Battery',
                                  '${toy.batteryLevel}%',
                                  theme,
                                ),
                              if (toy.batteryLevel != null) const Divider(),
                              _buildStatusRow('Model', toy.model, theme),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.updateToySettings(
                              newName: nameController.text,
                              newPersonality: controller.personality.value,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: AppTheme.primaryLight,
                        ),
                        child: const Text('Save Changes'),
                      ),

                      const SizedBox(height: 16),

                      // Remove Toy Button
                      OutlinedButton.icon(
                        onPressed: () =>
                            _showDeleteConfirmation(context, controller),
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
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, ThemeData theme) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
      ),
      Text(
        value,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  void _showDeleteConfirmation(
    BuildContext context,
    ToySettingsController controller,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Toy'),
        content: const Text(
          'Are you sure you want to remove this toy? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteToy();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
