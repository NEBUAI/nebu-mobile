import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/toy.dart';
import '../providers/theme_provider.dart';
import '../providers/toy_provider.dart';

class MyToysScreen extends ConsumerStatefulWidget {
  const MyToysScreen({super.key});

  @override
  ConsumerState<MyToysScreen> createState() => _MyToysScreenState();
}

class _MyToysScreenState extends ConsumerState<MyToysScreen> {
  @override
  void initState() {
    super.initState();
    // Load toys when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadToys();
    });
  }

  Future<void> _loadToys() async {
    await ref.read(toyProvider.notifier).loadMyToys();
  }

  Future<void> _deleteToy(Toy toy) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('toys.delete_title'.tr()),
        content: Text('toys.delete_confirm'.tr(args: [toy.name])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      await ref.read(toyProvider.notifier).deleteToy(toy.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.deleted_success'.tr(args: [toy.name])),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.delete_error'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showToyDetails(Toy toy, ThemeData theme, bool isDark) {
    final isOnline = toy.status == ToyStatus.active;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Toy icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isOnline
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : theme.disabledColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy,
                size: 40,
                color: isOnline
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              toy.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOnline ? 'toys.online'.tr() : 'toys.offline'.tr(),
                style: TextStyle(
                  color: isOnline ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Device info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.memory,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'toys.iot_device'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (toy.iotDeviceId != null)
                    _InfoRow(
                      label: 'ID',
                      value: toy.iotDeviceId!.length > 12
                          ? '${toy.iotDeviceId!.substring(0, 12)}...'
                          : toy.iotDeviceId!,
                      theme: theme,
                    ),
                  if (toy.model != null)
                    _InfoRow(
                      label: 'toys.model'.tr(),
                      value: toy.model!,
                      theme: theme,
                    ),
                  if (toy.firmwareVersion != null)
                    _InfoRow(
                      label: 'toys.firmware'.tr(),
                      value: toy.firmwareVersion!,
                      theme: theme,
                    ),
                  if (toy.batteryLevel != null)
                    _InfoRow(
                      label: 'toys.battery'.tr(),
                      value: toy.batteryLevel!,
                      theme: theme,
                    ),
                  if (toy.signalStrength != null)
                    _InfoRow(
                      label: 'toys.signal'.tr(),
                      value: toy.signalStrength!,
                      theme: theme,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.toySettings.path, extra: toy);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.settings),
                label: Text('toys.configure'.tr()),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteToy(toy);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text('toys.remove'.tr()),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addNewToy(BuildContext context) {
    context.push(AppRoutes.connectionSetup.path);
  }

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    final themeState = themeAsync.value;
    final isDark = themeState?.isDarkMode ?? false;
    final theme = Theme.of(context);
    final toysAsync = ref.watch(toyProvider);

    // Handle errors
    ref.listen(toyProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.error_loading'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'toys.title'.tr(),
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!toysAsync.isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadToys,
              tooltip: 'toys.reload'.tr(),
            ),
        ],
      ),
      body: toysAsync.when(
        data: (toys) => RefreshIndicator(
          onRefresh: _loadToys,
          child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'toys.my_toys'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _addNewToy(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: theme.colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'toys.add_toy'.tr(),
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Toy Cards from API
                  if (toys.isEmpty) ...[
                    // Empty state
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 64,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'toys.no_toys_title'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'toys.no_toys_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _addNewToy(context),
                            icon: const Icon(Icons.add),
                            label: Text('toys.setup_new_toy'.tr()),
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
                  ] else ...[
                    // Display toys from API
                    ...toys.map<Widget>(
                      (toy) => _ToyCard(
                        toy: toy,
                        theme: theme,
                        isDark: isDark,
                        onTap: () => _showToyDetails(toy, theme, isDark),
                      ),
                    ),
                  ],

                  if (toys.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    // Add more hint
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 48,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'toys.add_more_hint'.tr(),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => _addNewToy(context),
                            icon: const Icon(Icons.add),
                            label: Text('toys.setup_new_toy'.tr()),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => RefreshIndicator(
          onRefresh: _loadToys,
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
                    'toys.error_loading'.tr(),
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
                      'toys.error_loading'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadToys,
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

class _ToyCard extends StatelessWidget {
  const _ToyCard({
    required this.toy,
    required this.theme,
    required this.isDark,
    required this.onTap,
  });

  final Toy toy;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOnline = toy.status == ToyStatus.active;

    return Card(
      color: theme.colorScheme.surface,
      elevation: isDark ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Toy Icon
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isOnline
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.disabledColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.smart_toy,
                  size: 28,
                  color: isOnline
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
              ),
              const SizedBox(width: 16),
              // Toy Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      toy.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      toy.model ?? 'Nebu Robot',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOnline
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isOnline ? 'toys.online'.tr() : 'toys.offline'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        color: isOnline ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.iconTheme.color?.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
}
