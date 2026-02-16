import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class WorldInfoSetupScreen extends StatelessWidget {
  const WorldInfoSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back, color: context.colors.textOnFilled),
                  ),
                ),

                const SizedBox(height: 20),

                // Progress indicator
                _buildProgressIndicator(context, 7, 7),

                const Spacer(),

                // Completion icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: context.colors.bgPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.colors.textNormal.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 60,
                      color: context.colors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'setup.world_info.all_set'.tr(),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: context.colors.textOnFilled,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'setup.world_info.ready_message'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.colors.textOnFilled.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

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
                ElevatedButton(
                  onPressed: () {
                    // Mark setup as complete and navigate to home
                    context.go(AppRoutes.home.path);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.bgPrimary,
                    foregroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'setup.world_info.start_using'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, int current, int total) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      total,
      (index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: index < current ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: index < current
              ? context.colors.textOnFilled
              : context.colors.textOnFilled.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );

  Widget _buildFeatureSummary(BuildContext context, ThemeData theme, IconData icon, String text) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: context.colors.textOnFilled, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: context.colors.textOnFilled,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}
