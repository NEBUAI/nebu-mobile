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
  Widget build(BuildContext context) => Scaffold(
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
              _buildProgressIndicator(7, 7),

              const SizedBox(height: 40),

              // Title
              Text(
                'setup.favorites.title'.tr(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textOnFilled,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'setup.favorites.subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.textOnFilled.withValues(alpha: 0.9),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Categories grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedFavorites.contains(
                      category['label'] as String,
                    );

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedFavorites.remove(
                              category['label'] as String,
                            );
                          } else {
                            _selectedFavorites.add(category['label'] as String);
                          }
                        });
                      },
                      borderRadius: context.radius.panel,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.colors.bgPrimary
                              : context.colors.textOnFilled.withValues(alpha: 0.2),
                          borderRadius: context.radius.panel,
                          border: Border.all(
                            color: isSelected
                                ? context.colors.bgPrimary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              size: 40,
                              color: isSelected
                                  ? context.colors.primary
                                  : context.colors.textOnFilled,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (category['label'] as String).tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? context.colors.primary
                                    : context.colors.textOnFilled,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Icon(
                                Icons.check_circle,
                                color: context.colors.primary,
                                size: 20,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Next button
              ElevatedButton(
                onPressed: _selectedFavorites.length >= 2
                    ? () => context.go(AppRoutes.worldInfoSetup.path)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bgPrimary,
                  foregroundColor: context.colors.primary,
                  disabledBackgroundColor: context.colors.textOnFilled.withValues(alpha: 0.3),
                  disabledForegroundColor: context.colors.textOnFilled.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: context.radius.tile,
                  ),
                ),
                child: Text(
                  _selectedFavorites.length >= 2
                      ? 'setup.favorites.next_with_count'.tr(
                          args: [_selectedFavorites.length.toString()],
                        )
                      : 'setup.favorites.select_at_least'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip button
              TextButton(
                onPressed: () => context.go(AppRoutes.home.path),
                child: Text(
                  'setup.connection.skip_setup'.tr(),
                  style: TextStyle(
                    color: context.colors.textOnFilled.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildProgressIndicator(int current, int total) => Row(
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
          borderRadius: context.radius.checkbox,
        ),
      ),
    ),
  );
}
