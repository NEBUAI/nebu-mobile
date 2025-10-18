import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import '../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/device_provider.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Toys Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'home.my_active_toys'.tr(),
                    style: theme.textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        context.push(AppConstants.routeConnectionSetup),
                    icon: const Icon(Icons.add),
                    label: Text('home.add_toy'.tr()),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Active Toys List
              _buildActiveToysList(context, ref),

              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'home.quick_actions'.tr(),
                style: theme.textTheme.titleLarge,
              ),

              const SizedBox(height: 16),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _QuickActionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'home.scan_qr'.tr(),
                      onTap: () => context.push(AppConstants.routeQRScanner),
                    ),
                    _QuickActionCard(
                      icon: Icons.devices,
                      title: 'home.devices'.tr(),
                      onTap: () =>
                          context.push(AppConstants.routeDeviceManagement),
                    ),
                    _QuickActionCard(
                      icon: Icons.dashboard,
                      title: 'home.my_toys'.tr(),
                      onTap: () => context.go(AppConstants.routeMyToys),
                    ),
                    _QuickActionCard(
                      icon: Icons.history,
                      title: 'home.activity_log'.tr(),
                      onTap: () => context.go(AppConstants.routeActivityLog),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveToysList(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectedDevices = ref.watch(connectedDevicesProvider);

    return connectedDevices.when(
      data: (devices) {
        if (devices.isEmpty) {
          return _buildNoToysPlaceholder(theme);
        }

        return Column(
          children: devices
              .map((device) => _DeviceBatteryCard(device: device))
              .toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading devices: $error'),
      ),
    );
  }

  Widget _buildNoToysPlaceholder(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withAlpha(77)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icon_flow.svg',
            height: 64,
            colorFilter: ColorFilter.mode(
              theme.disabledColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'home.no_toys'.tr(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'home.no_toys_hint'.tr(),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceBatteryCard extends ConsumerWidget {
  const _DeviceBatteryCard({required this.device});

  final fbp.BluetoothDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final batteryLevel = ref.watch(batteryLevelProvider(device));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.bluetooth_connected),
        title: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown Device'),
        trailing: batteryLevel.when(
          data: (level) => Text('$level%', style: theme.textTheme.titleMedium),
          loading: () => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          error: (error, stack) => const Icon(Icons.error_outline, color: Colors.red),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
