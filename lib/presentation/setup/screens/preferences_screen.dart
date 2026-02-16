import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  final List<Map<String, dynamic>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
  ];

  final List<Map<String, dynamic>> themes = [
    {'code': 'system', 'name': 'System Default', 'icon': Icons.brightness_auto},
    {'code': 'light', 'name': 'Light Mode', 'icon': Icons.light_mode},
    {'code': 'dark', 'name': 'Dark Mode', 'icon': Icons.dark_mode},
  ];

  @override
  Widget build(BuildContext context) {
    final SetupWizardState state = ref.watch(setupWizardProvider);
    final SetupWizardNotifier notifier = ref.read(setupWizardProvider.notifier);
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Progress indicator
              SetupProgressIndicator(
                currentStep: state.currentStep + 1,
                totalSteps: SetupWizardState.totalSteps,
              ),
              const SizedBox(height: 40),

              // Title
              const GradientText(
                'Preferences',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Customize your app experience',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.textLowPriority,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Preferences sections
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Language selection
                      _buildSection(
                        title: 'Language',
                        icon: Icons.language,
                        child: _buildLanguageSelector(),
                      ),

                      const SizedBox(height: 32),

                      // Theme selection
                      _buildSection(
                        title: 'Theme',
                        icon: Icons.palette,
                        child: _buildThemeSelector(),
                      ),

                      const SizedBox(height: 32),

                      // Additional preferences
                      _buildSection(
                        title: 'Additional Settings',
                        icon: Icons.settings,
                        child: _buildAdditionalSettings(),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Column(
                children: [
                  CustomButton(
                    text: 'Continue',
                    onPressed: notifier.nextStep,
                    isFullWidth: true,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: notifier.previousStep,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: context.colors.textLowPriority,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.colors.grey700),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.colors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );

  Widget _buildLanguageSelector() {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Column(
      children: languages.map((language) {
        final isSelected = state.selectedLanguage == language['code'];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  notifier.updateSelectedLanguage(language['code'] as String),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.grey700,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      language['flag'] as String,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        language['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? context.colors.primary : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: context.colors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThemeSelector() {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Column(
      children: themes.map((theme) {
        final isSelected = state.selectedTheme == theme['code'];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () =>
                  notifier.updateSelectedTheme(theme['code'] as String),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primary
                        : context.colors.grey700,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      theme['icon'] as IconData?,
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.grey400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        theme['name'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? context.colors.primary : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: context.colors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAdditionalSettings() {
    final state = ref.watch(setupWizardProvider);
    final notifier = ref.read(setupWizardProvider.notifier);

    return Column(
      children: [
        _buildSettingTile(
          title: 'Haptic Feedback',
          subtitle: 'Vibration feedback for interactions',
          icon: Icons.vibration,
          value: state.hapticFeedback,
          onChanged: (value) {
            notifier.updateHapticFeedback(enabled: value);
          },
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          title: 'Auto-save',
          subtitle: 'Automatically save your work',
          icon: Icons.save,
          value: state.autoSave,
          onChanged: (value) {
            notifier.updateAutoSave(enabled: value);
          },
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          title: 'Analytics',
          subtitle: 'Help us improve the app',
          icon: Icons.analytics,
          value: state.analyticsEnabled,
          onChanged: (value) {
            notifier.updateAnalyticsEnabled(enabled: value);
          },
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => Row(
    children: [
      Icon(icon, color: context.colors.grey400, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: context.colors.textLowPriority,
              ),
            ),
          ],
        ),
      ),
      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: context.colors.primary,
      ),
    ],
  );
}
