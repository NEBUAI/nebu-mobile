import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/toy.dart';
import '../../providers/auth_provider.dart' as auth_provider;
import '../../providers/toy_provider.dart';

class WorldInfoSetupScreen extends ConsumerWidget {
  const WorldInfoSetupScreen({super.key});

  Future<void> _finishSetup(BuildContext context, WidgetRef ref) async {
    final prefs = await ref.read(
      auth_provider.sharedPreferencesProvider.future,
    );

    final deviceRegistered =
        prefs.getBool(StorageKeys.setupDeviceRegistered) ?? false;

    if (!deviceRegistered) {
      // Device was NOT registered in backend — save as local toy with pending status
      final toyName =
          prefs.getString(StorageKeys.setupToyName) ?? 'My Nebu';

      final localToy = Toy(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: toyName,
        status: ToyStatus.pending,
        model: 'Nebu',
        manufacturer: 'NEBU',
        createdAt: DateTime.now(),
      );

      await ref.read(toyProvider.notifier).saveLocalToy(localToy);
    }

    // Clean up temporary setup flags
    await prefs.remove(StorageKeys.setupDeviceRegistered);
    await prefs.setBool(StorageKeys.setupCompleted, true);

    if (context.mounted) {
      context.go(AppRoutes.home.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  _buildBackButton(context, colorScheme),
                  const Spacer(),
                  _buildStepIndicator(context, 7, 7),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: context.spacing.pageEdgeInsets,
                child: Column(
                  children: [
                    const Spacer(),

                    // Completion icon
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 60,
                          color: context.colors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Title
                    Text(
                      'setup.world_info.all_set'.tr(),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.titleBottomMarginSm),

                    Text(
                      'setup.world_info.ready_message'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Features summary
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.device_connected'.tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.profile_configured'.tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureSummary(
                      context,
                      theme,
                      Icons.check_circle,
                      'setup.world_info.preferences_saved'.tr(),
                    ),

                    const Spacer(),

                    // Finish button
                    _buildPrimaryButton(
                      context,
                      text: 'setup.world_info.start_using'.tr(),
                      onPressed: () => _finishSetup(context, ref),
                    ),

                    SizedBox(height: context.spacing.panelPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ColorScheme colorScheme) =>
      GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: context.radius.tile,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );

  Widget _buildStepIndicator(
          BuildContext context, int current, int total) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(total, (index) {
          final isActive = index < current;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? context.colors.primary
                  : context.colors.primary.withValues(alpha: 0.2),
              borderRadius: context.radius.checkbox,
            ),
          );
        }),
      );

  Widget _buildPrimaryButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) =>
      GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.primary100,
                context.colors.primary,
              ],
            ),
            borderRadius: context.radius.panel,
            boxShadow: [
              BoxShadow(
                color: context.colors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.colors.textOnFilled,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward,
                  color: context.colors.textOnFilled,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildFeatureSummary(
          BuildContext context, ThemeData theme, IconData icon, String text) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}
