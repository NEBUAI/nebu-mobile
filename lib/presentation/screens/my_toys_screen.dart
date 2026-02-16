import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/toy.dart';
import '../providers/auth_provider.dart';
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
    final user = ref.read(authProvider).value;
    final notifier = ref.read(toyProvider.notifier);

    if (user != null) {
      // Authenticated: load from backend + local
      await notifier.loadMyToys();
      final localToys = await notifier.loadLocalToys();
      if (localToys.isNotEmpty) {
        final current = ref.read(toyProvider).value ?? [];
        notifier.setToys([...current, ...localToys]);
      }
    } else {
      // Unauthenticated: only local toys
      final localToys = await notifier.loadLocalToys();
      notifier.setToys(localToys);
    }
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
            style: TextButton.styleFrom(foregroundColor: context.colors.error),
            child: Text('common.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      if (toy.id.startsWith('local_')) {
        await ref.read(toyProvider.notifier).removeLocalToy(toy.id);
      } else {
        await ref.read(toyProvider.notifier).deleteToy(toy.id);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.deleted_success'.tr(args: [toy.name])),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('toys.delete_error'.tr()),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _showToyDetails(Toy toy, ThemeData theme, bool isDark) {
    final isOnline = toy.status == ToyStatus.active;
    final isPending = toy.status == ToyStatus.pending;

    Color statusColor;
    String statusText;
    if (isPending) {
      statusColor = Colors.amber;
      statusText = 'toys.pending'.tr();
    } else if (isOnline) {
      statusColor = context.colors.success;
      statusText = 'toys.online'.tr();
    } else {
      statusColor = context.colors.error;
      statusText = 'toys.offline'.tr();
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(context.spacing.pageMargin),
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
                color: isPending
                    ? Colors.amber.withValues(alpha: 0.1)
                    : isOnline
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.disabledColor.withValues(alpha: 0.1),
                borderRadius: context.radius.bottomSheet,
              ),
              child: Icon(
                Icons.smart_toy,
                size: 40,
                color: isPending
                    ? Colors.amber.shade700
                    : isOnline
                        ? theme.colorScheme.primary
                        : theme.disabledColor,
              ),
            ),
            SizedBox(height: context.spacing.sectionTitleBottomMargin),
            Text(
              toy.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: context.radius.bottomSheet,
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: context.spacing.panelPadding),
            // Device info section
            Container(
              padding: EdgeInsets.all(context.spacing.alertPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: context.radius.tile,
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
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
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
            SizedBox(height: context.spacing.panelPadding),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.toySettings.path, extra: toy);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: context.colors.textOnFilled,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: context.radius.tile,
                  ),
                ),
                icon: const Icon(Icons.settings),
                label: Text('toys.configure'.tr()),
              ),
            ),
            SizedBox(height: context.spacing.paragraphBottomMarginSm),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteToy(toy);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.error,
                  side: BorderSide(color: context.colors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: context.radius.tile,
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text('toys.remove'.tr()),
              ),
            ),
            SizedBox(height: context.spacing.titleBottomMarginSm),
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
            backgroundColor: context.colors.error,
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
                padding: EdgeInsets.all(context.spacing.alertPadding),
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
                          borderRadius: context.radius.tile,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _addNewToy(context),
                            borderRadius: context.radius.tile,
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
                  SizedBox(height: context.spacing.titleBottomMargin),

                  // Toy Cards from API
                  if (toys.isEmpty) ...[
                    // Empty state
                    _buildEmptyState(context, theme),
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
                    SizedBox(height: context.spacing.panelPadding),
                    // Add more hint
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.spacing.alertPadding,
                        vertical: context.spacing.paragraphBottomMarginSm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 18,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'toys.add_more_hint'.tr(),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
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
            padding: EdgeInsets.all(context.spacing.pageMargin),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: context.spacing.sectionTitleBottomMargin),
                  Text(
                    'toys.error_loading'.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.spacing.paragraphBottomMarginSm),
                  Container(
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: context.radius.tile,
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
                  SizedBox(height: context.spacing.panelPadding),
                  ElevatedButton.icon(
                    onPressed: _loadToys,
                    icon: const Icon(Icons.refresh),
                    label: Text('common.retry'.tr()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: context.colors.textOnFilled,
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

  Widget _buildEmptyState(BuildContext context, ThemeData theme) => Container(
    padding: EdgeInsets.all(context.spacing.paragraphBottomMargin),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          context.colors.primary.withValues(alpha: 0.04),
          context.colors.secondary.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: context.radius.panel,
      border: Border.all(
        color: theme.dividerColor.withValues(alpha: 0.3),
        width: 2,
      ),
    ),
    child: Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary.withValues(alpha: 0.08),
                context.colors.secondary.withValues(alpha: 0.08),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            size: 48,
            color: context.colors.primary.withValues(alpha: 0.5),
          ),
        ),
        SizedBox(height: context.spacing.sectionTitleBottomMargin),
        Text(
          'toys.no_toys_title'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMarginSm),
        Text(
          'toys.no_toys_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: context.spacing.titleBottomMargin),
        ElevatedButton.icon(
          onPressed: () => _addNewToy(context),
          icon: const Icon(Icons.add),
          label: Text('toys.setup_new_toy'.tr()),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: context.colors.textOnFilled,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: context.radius.button,
            ),
          ),
        ),
      ],
    ),
  );
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
    final isPending = toy.status == ToyStatus.pending;

    Color accentColor;
    String badgeText;
    if (isPending) {
      accentColor = Colors.amber;
      badgeText = 'toys.pending'.tr();
    } else if (isOnline) {
      accentColor = context.colors.success;
      badgeText = 'toys.online'.tr();
    } else {
      accentColor = context.colors.error;
      badgeText = 'toys.offline'.tr();
    }

    return Container(
      margin: EdgeInsets.only(bottom: context.spacing.paragraphBottomMarginSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: context.radius.panel,
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: context.radius.panel,
        child: InkWell(
          onTap: onTap,
          borderRadius: context.radius.panel,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Accent left border
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Main content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(context.spacing.alertPadding),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Toy Icon
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.amber.withValues(alpha: 0.15)
                                    : isOnline
                                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                        : theme.disabledColor.withValues(alpha: 0.15),
                                borderRadius: context.radius.panel,
                              ),
                              child: Icon(
                                Icons.smart_toy,
                                size: 28,
                                color: isPending
                                    ? Colors.amber.shade700
                                    : isOnline
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
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: context.radius.bottomSheet,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    badgeText,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: accentColor,
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
                        // Pending banner
                        if (isPending) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.08),
                              borderRadius: context.radius.tile,
                              border: Border.all(
                                color: Colors.amber.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: Colors.amber.shade700,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'toys.pending_hint'.tr(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // Quick action buttons for online toys
                        if (isOnline) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickActionButton(
                                  icon: Icons.record_voice_over,
                                  label: 'toys.talk_to_toy'.tr(),
                                  color: context.colors.primary,
                                  onTap: () => context.push(
                                    AppRoutes.walkieTalkie.path,
                                    extra: toy,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _QuickActionButton(
                                  icon: Icons.settings,
                                  label: 'toys.configure_toy'.tr(),
                                  color: context.colors.secondary,
                                  onTap: () => context.push(
                                    AppRoutes.toySettings.path,
                                    extra: toy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        // Last connected time for offline toys
                        if (!isOnline && !isPending && toy.lastConnected != null) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatLastConnected(toy.lastConnected!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatLastConnected(DateTime lastConnected) {
    final now = DateTime.now();
    final diff = now.difference(lastConnected);
    if (diff.inMinutes < 1) {
      return 'activity_log.just_now'.tr();
    }
    if (diff.inHours < 1) {
      return 'activity_log.minutes_ago'.tr(args: [diff.inMinutes.toString()]);
    }
    if (diff.inDays < 1) {
      return 'activity_log.hours_ago'.tr(args: [diff.inHours.toString()]);
    }
    return 'activity_log.days_ago'.tr(args: [diff.inDays.toString()]);
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: context.radius.tile,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: context.radius.tile,
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
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
