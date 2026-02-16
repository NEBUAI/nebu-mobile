import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../providers/bluetooth_provider.dart';
import '../providers/device_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings.path),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
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
                        context.push(AppRoutes.connectionSetup.path),
                    icon: const Icon(Icons.add),
                    label: Text('home.add_toy'.tr()),
                  ),
                ],
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              // Active Toys List
              _buildActiveToysList(context, ref),

              SizedBox(height: context.spacing.panelPadding),

              // Quick Actions
              Text(
                'home.quick_actions'.tr(),
                style: theme.textTheme.titleLarge,
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _QuickActionCard(
                      icon: Icons.qr_code_scanner,
                      title: 'home.scan_qr'.tr(),
                      onTap: () => context.push(AppRoutes.qrScanner.path),
                    ),
                    _QuickActionCard(
                      icon: Icons.devices_other,
                      title: 'All Devices',
                      onTap: () => context.push(AppRoutes.allDevices.path),
                    ),
                    _QuickActionCard(
                      icon: Icons.dashboard,
                      title: 'home.my_toys'.tr(),
                      onTap: () => context.go(AppRoutes.myToys.path),
                    ),
                    _QuickActionCard(
                      icon: Icons.history,
                      title: 'home.activity_log'.tr(),
                      onTap: () => context.go(AppRoutes.activityLog.path),
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

    try {
      final connectedDevices = ref.watch(connectedDevicesProvider);

      return connectedDevices.when(
        data: (devices) {
          if (devices.isEmpty) {
            return _buildNoToysPlaceholder(context, theme);
          }

          return Column(
            children: devices
                .map((device) => _DeviceBatteryCard(device: device))
                .toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildErrorBanner(
          context,
          theme,
          'home.devices_error'.tr(),
        ),
      );
    } on Exception {
      return _buildErrorBanner(
        context,
        theme,
        'home.devices_error'.tr(),
      );
    }
  }

  Widget _buildErrorBanner(BuildContext context, ThemeData theme, String message) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
      borderRadius: context.radius.tile,
      border: Border.all(
        color: theme.colorScheme.error.withValues(alpha: 0.3),
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.error_outline,
          size: 32,
          color: theme.colorScheme.error,
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _buildNoToysPlaceholder(BuildContext context, ThemeData theme) => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor.withAlpha(77)),
        borderRadius: context.radius.panel,
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/icon_flow.svg',
            height: 64,
            colorFilter: ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
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

class _DeviceBatteryCard extends ConsumerWidget {
  const _DeviceBatteryCard({required this.device});

  final fbp.BluetoothDevice device;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final batteryLevel = ref.watch(batteryLevelProvider(device));

    return Card(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      child: ListTile(
        leading: const Icon(Icons.bluetooth_connected),
        title: Text(
          device.platformName.isNotEmpty
              ? device.platformName
              : 'Unknown Device',
        ),
        trailing: batteryLevel.when(
          data: (level) => Text('$level%', style: theme.textTheme.titleMedium),
          loading: () => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          error: (error, stack) =>
              Icon(Icons.error_outline, color: context.colors.error),
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
      shape: RoundedRectangleBorder(borderRadius: context.radius.modal),
      child: InkWell(
        onTap: onTap,
        borderRadius: context.radius.panel,
        child: Padding(
          padding: EdgeInsets.all(context.spacing.alertPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: theme.colorScheme.primary),
              SizedBox(height: context.spacing.paragraphBottomMarginSm),
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
