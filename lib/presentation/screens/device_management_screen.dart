import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/toy.dart';
import '../providers/toy_provider.dart';

class DeviceManagementScreen extends ConsumerStatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  ConsumerState<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends ConsumerState<DeviceManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(toyProvider.notifier).loadMyToys();
    });
  }

  Future<void> _refreshDevices() async {
    await ref.read(toyProvider.notifier).loadMyToys();
  }

  Future<void> _deleteDevice(String toyId) async {
    try {
      await ref.read(toyProvider.notifier).deleteToy(toyId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('device_management.remove_success'.tr())),
        );
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('device_management.remove_error'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toysAsync = ref.watch(toyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('device_management.title'.tr()),
        actions: [
          if (!toysAsync.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDevices,
            ),
        ],
      ),
      body: toysAsync.when(
        data: (toys) {
          if (toys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.devices_other,
                    size: 64,
                    color: theme.disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'device_management.no_devices'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshDevices,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: toys.length,
              itemBuilder: (context, index) {
                final toy = toys[index];
                return _DeviceCard(
                  toy: toy,
                  theme: theme,
                  onDelete: () => _deleteDevice(toy.id),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => RefreshIndicator(
          onRefresh: _refreshDevices,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'device_management.error_loading'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'device_management.error_loading'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshDevices,
                    icon: const Icon(Icons.refresh),
                    label: Text('common.retry'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.toy,
    required this.theme,
    required this.onDelete,
  });

  final Toy toy;
  final ThemeData theme;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isOnline = toy.status == ToyStatus.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOnline
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          child: Icon(
            Icons.smart_toy,
            color: isOnline ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(toy.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (toy.model != null) Text('device_management.model'.tr(args: [toy.model ?? ''])),
            Text('device_management.status'.tr(args: [toy.status.name])),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('device_management.remove_title'.tr()),
                content: Text('device_management.remove_confirm'.tr(args: [toy.name])),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('common.cancel'.tr()),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: Text('common.delete'.tr()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
