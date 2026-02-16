import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_border_radius.dart';
import '../../../core/theme/app_colors.dart';

class VoiceSetupScreen extends StatefulWidget {
  const VoiceSetupScreen({super.key});

  @override
  State<VoiceSetupScreen> createState() => _VoiceSetupScreenState();
}

class _VoiceSetupScreenState extends State<VoiceSetupScreen> {
  String? _selectedVoice;

  final List<Map<String, dynamic>> _voices = [
    {
      'label': 'setup.voice.child_voice',
      'icon': Icons.child_care,
      'description': 'setup.voice.child_voice_desc',
    },
    {
      'label': 'setup.voice.friendly_adult',
      'icon': Icons.person,
      'description': 'setup.voice.friendly_adult_desc',
    },
    {
      'label': 'setup.voice.robot_voice',
      'icon': Icons.smart_toy,
      'description': 'setup.voice.robot_voice_desc',
    },
    {
      'label': 'setup.voice.custom',
      'icon': Icons.tune,
      'description': 'setup.voice.custom_desc',
    },
  ];

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
                _buildProgressIndicator(5, 7),

                const SizedBox(height: 40),

                // Title
                Text(
                  'setup.voice.title'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: context.colors.textOnFilled,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'setup.voice.subtitle'.tr(),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: context.colors.textOnFilled.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Voice options
                Expanded(
                  child: ListView.builder(
                    itemCount: _voices.length,
                    itemBuilder: (context, index) {
                      final voice = _voices[index];
                      final isSelected = _selectedVoice == voice['label'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedVoice = voice['label'] as String;
                            });
                          },
                          borderRadius: context.radius.panel,
                          child: Container(
                            padding: const EdgeInsets.all(20),
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
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? context.colors.primary
                                            .withValues(alpha: 0.1)
                                        : context.colors.textOnFilled.withValues(alpha: 0.1),
                                    borderRadius: context.radius.tile,
                                  ),
                                  child: Icon(
                                    voice['icon'] as IconData,
                                    size: 28,
                                    color: isSelected
                                        ? context.colors.primary
                                        : context.colors.textOnFilled,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (voice['label'] as String).tr(),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? context.colors.primary
                                                  : context.colors.textOnFilled,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        (voice['description'] as String).tr(),
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? context.colors.primary
                                                      .withValues(alpha: 0.7)
                                                  : context.colors.textOnFilled.withValues(alpha: 0.7),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: context.colors.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Next button
                ElevatedButton(
                  onPressed: _selectedVoice != null
                      ? () => context.go(AppRoutes.favoritesSetup.path)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.bgPrimary,
                    foregroundColor: context.colors.primary,
                    disabledBackgroundColor: context.colors.bgPrimary.withValues(alpha: 0.3),
                    disabledForegroundColor: context.colors.textOnFilled.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: context.radius.tile,
                    ),
                  ),
                  child: Text(
                    'common.next'.tr(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: context.colors.primary,
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: context.colors.textOnFilled.withValues(alpha: 0.8),
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
  }

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
