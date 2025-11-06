import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../core/theme/app_theme.dart';
import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';

class DeviceManagementController extends GetxController {

  DeviceManagementController(this.toyProvider);
  final ToyProvider toyProvider;
  final isLoading = false.obs;
  final toys = <Toy>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDevices();
  }

  Future<void> loadDevices() async {
    isLoading.value = true;
    try {
      await toyProvider.loadMyToys();
      toys.value = toyProvider.toys;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load devices: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshDevices() async {
    await loadDevices();
  }

  Future<void> deleteDevice(String toyId) async {
    try {
      await toyProvider.deleteToy(toyId);
      toys.removeWhere((toy) => toy.id == toyId);
      Get.snackbar(
        'Success',
        'Device removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove device: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final toyProvider = Get.find<ToyProvider>();
    final controller = Get.put(DeviceManagementController(toyProvider));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('device_management.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshDevices,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.toys.isEmpty) {
          return _buildEmptyState(theme);
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDevices,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.toys.length,
            itemBuilder: (context, index) {
              final toy = controller.toys[index];
              return _buildDeviceCard(toy, theme, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(ThemeData theme) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppTheme.primaryGradient),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Icon(Icons.devices, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text('No Devices', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Add your first Nebu toy to get started',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildDeviceCard(
    Toy toy,
    ThemeData theme,
    DeviceManagementController controller,
  ) {
    final isOnline = toy.status == ToyStatus.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isOnline
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          child: Icon(
            Icons.smart_toy,
            color: isOnline ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          toy.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Model: ${toy.model ?? "Unknown"}'),
            Text('ID: ${toy.iotDeviceId}', style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOnline
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Firmware',
                  toy.firmwareVersion ?? 'Not set',
                  theme,
                ),
                const SizedBox(height: 8),
                if (toy.batteryLevel != null)
                  _buildInfoRow('Battery', '${toy.batteryLevel}', theme),
                if (toy.batteryLevel != null) const SizedBox(height: 8),
                _buildInfoRow('Status', toy.status.name, theme),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(controller, toy.id);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to device settings
                        Get.snackbar(
                          'Info',
                          'Device settings coming soon',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Settings'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) => Row(
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

  void _showDeleteConfirmation(
    DeviceManagementController controller,
    String toyId,
  ) {
    Get.dialog<void>(
      AlertDialog(
        title: const Text('Remove Device'),
        content: const Text(
          'Are you sure you want to remove this device? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back<void>();
              controller.deleteDevice(toyId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
