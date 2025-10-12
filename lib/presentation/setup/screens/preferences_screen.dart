import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_controller.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final controller = Get.find<SetupWizardController>();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Progress indicator
              SetupProgressIndicator(
                currentStep: controller.currentStep.value + 1,
                totalSteps: controller.totalSteps,
              ),
              const SizedBox(height: 40),
              
              // Title
              const GradientText(
                'Preferences',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Customize your app experience',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
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
                        child: _buildLanguageSelector(isDark),
                        isDark: isDark,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Theme selection
                      _buildSection(
                        title: 'Theme',
                        icon: Icons.palette,
                        child: _buildThemeSelector(isDark),
                        isDark: isDark,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Additional preferences
                      _buildSection(
                        title: 'Additional Settings',
                        icon: Icons.settings,
                        child: _buildAdditionalSettings(isDark),
                        isDark: isDark,
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
                    onPressed: controller.nextStep,
                    isFullWidth: true,
                    icon: Icons.arrow_forward,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: controller.previousStep,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
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
    required bool isDark,
  }) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
        ),
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
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );

  Widget _buildLanguageSelector(bool isDark) => Column(
      children: languages.map((language) {
        final isSelected = controller.selectedLanguage.value == language['code'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => controller.selectedLanguage.value = language['code'],
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryLight.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      language['flag'],
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        language['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryLight : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryLight,
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

  Widget _buildThemeSelector(bool isDark) => Column(
      children: themes.map((theme) {
        final isSelected = controller.selectedTheme.value == theme['code'];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => controller.selectedTheme.value = theme['code'],
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryLight.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryLight
                        : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      theme['icon'],
                      color: isSelected ? AppTheme.primaryLight : Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        theme['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.primaryLight : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryLight,
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

  Widget _buildAdditionalSettings(bool isDark) => Column(
      children: [
        _buildSettingTile(
          title: 'Haptic Feedback',
          subtitle: 'Vibration feedback for interactions',
          icon: Icons.vibration,
          value: true,
          onChanged: (value) {
            // TODO: Implement haptic feedback setting
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          title: 'Auto-save',
          subtitle: 'Automatically save your work',
          icon: Icons.save,
          value: true,
          onChanged: (value) {
            // TODO: Implement auto-save setting
          },
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildSettingTile(
          title: 'Analytics',
          subtitle: 'Help us improve the app',
          icon: Icons.analytics,
          value: false,
          onChanged: (value) {
            // TODO: Implement analytics setting
          },
          isDark: isDark,
        ),
      ],
    );

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) => Row(
      children: [
        Icon(
          icon,
          color: Colors.grey[600],
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppTheme.primaryLight,
        ),
      ],
    );
}
