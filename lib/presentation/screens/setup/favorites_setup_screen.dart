import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class FavoritesSetupScreen extends StatefulWidget {
  const FavoritesSetupScreen({super.key});

  @override
  State<FavoritesSetupScreen> createState() => _FavoritesSetupScreenState();
}

class _FavoritesSetupScreenState extends State<FavoritesSetupScreen> {
  final Set<String> _selectedFavorites = {};

  final List<Map<String, dynamic>> _categories = [
    {'label': 'setup.favorites.animals', 'icon': Icons.pets},
    {'label': 'setup.favorites.space', 'icon': Icons.rocket_launch},
    {'label': 'setup.favorites.sports', 'icon': Icons.sports_soccer},
    {'label': 'setup.favorites.music', 'icon': Icons.music_note},
    {'label': 'setup.favorites.art', 'icon': Icons.palette},
    {'label': 'setup.favorites.science', 'icon': Icons.science},
    {'label': 'setup.favorites.stories', 'icon': Icons.menu_book},
    {'label': 'setup.favorites.games', 'icon': Icons.games},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final canProceed = _selectedFavorites.length >= 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  _buildBackButton(colorScheme),
                  const Spacer(),
                  _buildStepIndicator(7, 7),
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
                    SizedBox(height: context.spacing.titleBottomMargin),

                    Text(
                      'setup.favorites.title'.tr(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.spacing.titleBottomMarginSm),
                    Text(
                      'setup.favorites.subtitle'.tr(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: context.spacing.largePageBottomMargin),

                    // Categories grid
                    Expanded(
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedFavorites
                              .contains(category['label'] as String);

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedFavorites
                                      .remove(category['label'] as String);
                                } else {
                                  _selectedFavorites
                                      .add(category['label'] as String);
                                }
                              });
                            },
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colors.primary
                                        .withValues(alpha: 0.08)
                                    : colorScheme.surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                borderRadius: context.radius.panel,
                                border: Border.all(
                                  color: isSelected
                                      ? context.colors.primary
                                      : colorScheme.outline,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? context.colors.primary
                                              .withValues(alpha: 0.15)
                                          : colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius: context.radius.panel,
                                    ),
                                    child: Icon(
                                      category['icon'] as IconData,
                                      size: 24,
                                      color: isSelected
                                          ? context.colors.primary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    (category['label'] as String).tr(),
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? context.colors.primary
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Primary button
                    _buildPrimaryButton(
                      text: canProceed
                          ? 'setup.favorites.next_with_count'.tr(
                              args: [_selectedFavorites.length.toString()],
                            )
                          : 'setup.favorites.select_at_least'.tr(),
                      isEnabled: canProceed,
                      onPressed: () =>
                          context.go(AppRoutes.worldInfoSetup.path),
                    ),

                    SizedBox(height: context.spacing.sectionTitleBottomMargin),

                    GestureDetector(
                      onTap: () => context.go(AppRoutes.home.path),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'setup.connection.skip_setup'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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

  Widget _buildBackButton(ColorScheme colorScheme) => GestureDetector(
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

  Widget _buildStepIndicator(int current, int total) => Row(
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

  Widget _buildPrimaryButton({
    required String text,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) =>
      GestureDetector(
        onTap: isEnabled ? onPressed : null,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? LinearGradient(
                    colors: [
                      context.colors.primary100,
                      context.colors.primary,
                    ],
                  )
                : null,
            color: isEnabled
                ? null
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
            borderRadius: context.radius.panel,
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isEnabled
                        ? context.colors.textOnFilled
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ),
      );
}
