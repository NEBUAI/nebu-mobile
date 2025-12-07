import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_theme.dart';
import '../../data/models/iot_device.dart';
import '../providers/iot_provider.dart';

class IoTDevicesScreen extends ConsumerStatefulWidget {
  const IoTDevicesScreen({super.key});

  @override
  ConsumerState<IoTDevicesScreen> createState() => _IoTDevicesScreenState();
}

class _IoTDevicesScreenState extends ConsumerState<IoTDevicesScreen> {
  @override
  void initState() {
    super.initState();
    // Load devices when screen is first created
    Future.microtask(() {
      ref.read(iotDevicesProvider.notifier).fetchUserDevices();
    });
  }

  Future<void> _refreshDevices() async {
    await ref.read(iotDevicesProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(iotDevicesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My IoT Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDevices,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'online') {
                ref.read(iotDevicesProvider.notifier).fetchOnlineDevices();
              } else if (value == 'all') {
                ref.read(iotDevicesProvider.notifier).fetchUserDevices();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Devices'),
              ),
              const PopupMenuItem(
                value: 'online',
                child: Text('Online Only'),
              ),
            ],
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _buildErrorState(state.error!, theme)
              : state.devices.isEmpty
                  ? _buildEmptyState(theme)
                  : RefreshIndicator(
                      onRefresh: _refreshDevices,
                      child: Column(
                        children: [
                          _buildMetricsCard(state, theme),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.devices.length,
                              itemBuilder: (context, index) {
                                final device = state.devices[index];
                                return _buildDeviceCard(device, theme);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildMetricsCard(IoTDevicesState state, ThemeData theme) => Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem(
              'Total',
              state.totalDevices,
              Icons.devices,
              AppTheme.primaryLight,
              theme,
            ),
            _buildMetricItem(
              'Online',
              state.onlineCount,
              Icons.check_circle,
              Colors.green,
              theme,
            ),
            _buildMetricItem(
              'Offline',
              state.offlineCount,
              Icons.cancel,
              Colors.grey,
              theme,
            ),
            if (state.errorCount > 0)
              _buildMetricItem(
                'Error',
                state.errorCount,
                Icons.error,
                Colors.red,
                theme,
              ),
          ],
        ),
      ),
    );

  Widget _buildMetricItem(
    String label,
    int value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) => Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.disabledColor,
          ),
        ),
      ],
    );

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
          Text('No Devices Found', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Add your first IoT device to get started',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildErrorState(String error, ThemeData theme) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error Loading Devices',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );

  Widget _buildDeviceCard(IoTDevice device, ThemeData theme) {
    final isOnline = device.status == DeviceStatus.online;
    final hasError = device.status == DeviceStatus.error;

    Color statusColor;
    if (hasError) {
      statusColor = Colors.red;
    } else if (isOnline) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(
            _getDeviceIcon(device.deviceType),
            color: statusColor,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (device.deviceModel != null)
              Text('Model: ${device.deviceModel!.name}')
            else if (device.deviceType != null)
              Text('Type: ${device.deviceType!.name}'),
            if (device.lastSeen != null)
              Text(
                'Last seen: ${timeago.format(device.lastSeen!)}',
                style: theme.textTheme.bodySmall,
              )
            else
              Text('Never connected', style: theme.textTheme.bodySmall),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            device.status.name.toUpperCase(),
            style: TextStyle(
              color: statusColor,
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
                if (device.macAddress != null)
                  _buildInfoRow('MAC Address', device.macAddress!, theme),
                if (device.macAddress != null) const SizedBox(height: 8),
                if (device.ipAddress != null)
                  _buildInfoRow('IP Address', device.ipAddress!, theme),
                if (device.ipAddress != null) const SizedBox(height: 8),
                if (device.deviceId != null)
                  _buildInfoRow('Device ID', device.deviceId!, theme),
                if (device.deviceId != null) const SizedBox(height: 8),
                if (device.batteryLevel != null)
                  _buildInfoRow(
                    'Battery',
                    '${device.batteryLevel}%',
                    theme,
                  ),
                if (device.batteryLevel != null) const SizedBox(height: 8),
                if (device.signalStrength != null)
                  _buildInfoRow(
                    'Signal',
                    '${device.signalStrength} dBm',
                    theme,
                  ),
                if (device.signalStrength != null) const SizedBox(height: 8),
                if (device.temperature != null)
                  _buildInfoRow(
                    'Temperature',
                    '${device.temperature!.toStringAsFixed(1)}°C',
                    theme,
                  ),
                if (device.temperature != null) const SizedBox(height: 8),
                if (device.humidity != null)
                  _buildInfoRow(
                    'Humidity',
                    '${device.humidity!.toStringAsFixed(1)}%',
                    theme,
                  ),
                if (device.humidity != null) const SizedBox(height: 8),
                _buildInfoRow(
                  'Created',
                  device.createdAt != null
                      ? timeago.format(device.createdAt!)
                      : 'Unknown',
                  theme,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(device),
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showDeviceDetails(device),
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Details'),
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

  IconData _getDeviceIcon(DeviceType? type) {
    switch (type) {
      case DeviceType.sensor:
        return Icons.sensors;
      case DeviceType.actuator:
        return Icons.settings_input_component;
      case DeviceType.camera:
        return Icons.camera_alt;
      case DeviceType.microphone:
        return Icons.mic;
      case DeviceType.speaker:
        return Icons.speaker;
      case DeviceType.controller:
        return Icons.control_camera;
      default:
        return Icons.device_unknown;
    }
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

  void _showDeleteConfirmation(IoTDevice device) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text(
          'Are you sure you want to remove "${device.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(iotDevicesProvider.notifier)
                  .deleteDevice(device.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Device removed successfully'
                          : 'Failed to remove device',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetails(IoTDevice device) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(device.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${device.id}'),
              if (device.deviceModel != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Device Model:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Name: ${device.deviceModel!.name}'),
                if (device.deviceModel!.manufacturer != null)
                  Text('Manufacturer: ${device.deviceModel!.manufacturer}'),
                if (device.deviceModel!.description != null)
                  Text('Description: ${device.deviceModel!.description}'),
              ],
              if (device.metadata != null && device.metadata!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...device.metadata!.entries.map(
                  (e) => Text('${e.key}: ${e.value}'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
