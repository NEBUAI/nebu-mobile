import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class IoTDashboardScreen extends StatelessWidget {
  const IoTDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add device
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'My Devices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _DeviceCard(
            name: 'Robot 1',
            type: 'Nebu Robot',
            status: 'Online',
            isOnline: true,
            onTap: () {},
          ),
          _DeviceCard(
            name: 'Robot 2',
            type: 'Nebu Robot',
            status: 'Offline',
            isOnline: false,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Add more devices to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final String name;
  final String type;
  final String status;
  final bool isOnline;
  final VoidCallback onTap;

  const _DeviceCard({
    required this.name,
    required this.type,
    required this.status,
    required this.isOnline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOnline
                ? AppTheme.primaryLight.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.smart_toy,
            color: isOnline ? AppTheme.primaryLight : Colors.grey,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(type),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
