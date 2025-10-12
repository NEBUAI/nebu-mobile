import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class PersonalitySetupScreen extends StatefulWidget {
  const PersonalitySetupScreen({super.key});

  @override
  State<PersonalitySetupScreen> createState() => _PersonalitySetupScreenState();
}

class _PersonalitySetupScreenState extends State<PersonalitySetupScreen> {
  String? _selectedPersonality;

  final List<Map<String, String>> _personalities = [
    {
      'label': 'Playful',
      'icon': '😄',
      'description': 'Energetic and fun-loving',
    },
    {
      'label': 'Calm',
      'icon': '😌',
      'description': 'Gentle and soothing',
    },
    {
      'label': 'Curious',
      'icon': '🤔',
      'description': 'Always learning and exploring',
    },
    {
      'label': 'Wise',
      'icon': '🧙',
      'description': 'Thoughtful and knowledgeable',
    },
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
                  _buildProgressIndicator(4, 7),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    'Choose Personality',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'What personality suits your companion best?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
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
                              child: Row(
                                children: [
                                  Text(
                                    personality['icon']!,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          personality['label']!,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppTheme.primaryLight
                                                : Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          personality['description']!,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isSelected
                                                ? AppTheme.primaryLight
                                                    .withValues(alpha: 0.7)
                                                : Colors.white
                                                    .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppTheme.primaryLight,
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
                        ? () => context.go(AppConstants.routeVoiceSetup)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryLight,
                      disabledBackgroundColor:
                          Colors.white.withValues(alpha: 0.3),
                      disabledForegroundColor:
                          Colors.white.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Skip button
                  TextButton(
                    onPressed: () => context.go(AppConstants.routeHome),
                    child: Text(
                      'Skip Setup',
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
