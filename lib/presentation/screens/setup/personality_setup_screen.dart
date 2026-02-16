import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/theme/app_colors.dart';

class PersonalitySetupScreen extends StatefulWidget {
  const PersonalitySetupScreen({super.key});

  @override
  State<PersonalitySetupScreen> createState() => _PersonalitySetupScreenState();
}

class _PersonalitySetupScreenState extends State<PersonalitySetupScreen> {
  String? _selectedPersonality;

  final List<Map<String, String>> _personalities = [
    {
      'label': 'setup.personality.playful',
      'icon': '😄',
      'description': 'setup.personality.playful_desc',
    },
    {
      'label': 'setup.personality.calm',
      'icon': '😌',
      'description': 'setup.personality.calm_desc',
    },
    {
      'label': 'setup.personality.curious',
      'icon': '🤔',
      'description': 'setup.personality.curious_desc',
    },
    {
      'label': 'setup.personality.wise',
      'icon': '🧙',
      'description': 'setup.personality.wise_desc',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                _buildProgressIndicator(4, 7),

                const SizedBox(height: 40),

                // Title
                Text(
                  'setup.personality.title'.tr(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textOnFilled,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Text(
                  'setup.personality.subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.textOnFilled.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Personality options
                Expanded(
                  child: ListView.builder(
                    itemCount: _personalities.length,
                    itemBuilder: (context, index) {
                      final personality = _personalities[index];
                      final isSelected =
                          _selectedPersonality == personality['label'];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPersonality = personality['label'];
                            });
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.colors.textOnFilled
                                  : context.colors.textOnFilled.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? context.colors.textOnFilled
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  personality['icon']!,
                                  style: const TextStyle(fontSize: 32),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        personality['label']!.tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? context.colors.primary
                                              : context.colors.textOnFilled,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        personality['description']!.tr(),
                                        style: TextStyle(
                                          fontSize: 14,
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
                  onPressed: _selectedPersonality != null
                      ? () => context.go(AppRoutes.voiceSetup.path)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.textOnFilled,
                    foregroundColor: context.colors.primary,
                    disabledBackgroundColor: context.colors.textOnFilled.withValues(alpha: 0.3),
                    disabledForegroundColor: context.colors.textOnFilled.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'common.next'.tr(),
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
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      );
}
