import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_theme.dart';

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
      decoration: AppTheme.primaryGradientDecoration,
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              // Progress indicator
              _buildProgressIndicator(6, 7),

              const SizedBox(height: 40),

              // Title
              Text(
                'setup.favorites.title'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'setup.favorites.subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
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
                      borderRadius: BorderRadius.circular(16),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
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
                                  ? AppTheme.primaryLight
                                  : Colors.white,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (category['label'] as String).tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppTheme.primaryLight
                                    : Colors.white,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryLight,
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
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryLight,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    color: Colors.white.withValues(alpha: 0.8),
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
              ? Colors.white
              : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  );
}
