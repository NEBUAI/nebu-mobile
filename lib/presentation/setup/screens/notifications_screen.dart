import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final controller = Get.find<SetupWizardController>();

  final List<Map<String, dynamic>> notificationTypes = [
    {
      'title': 'Push Notifications',
      'description': 'Receive notifications when the app is closed',
      'icon': Icons.notifications,
      'enabled': true,
      'type': 'push',
    },
    {
      'title': 'Reminders',
      'description': 'Daily reminders and scheduled notifications',
      'icon': Icons.schedule,
      'enabled': true,
      'type': 'reminders',
    },
    {
      'title': 'Voice Commands',
      'description': 'Notifications for voice command results',
      'icon': Icons.mic,
      'enabled': true,
      'type': 'voice',
    },
    {
      'title': 'Updates & News',
      'description': 'App updates and feature announcements',
      'icon': Icons.new_releases,
      'enabled': false,
      'type': 'updates',
    },
    {
      'title': 'Marketing',
      'description': 'Promotional content and special offers',
      'icon': Icons.campaign,
      'enabled': false,
      'type': 'marketing',
    },
  ];

  final List<Map<String, dynamic>> quietHours = [
    {
      'title': 'Quiet Hours',
      'description': 'Disable notifications during specified hours',
      'icon': Icons.bedtime,
      'enabled': false,
    },
    {
      'title': 'Do Not Disturb',
      'description': 'Pause all notifications except important ones',
      'icon': Icons.do_not_disturb,
      'enabled': false,
    },
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
                'Notifications',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Choose how you want to be notified',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Notifications content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Notification types
                      _buildNotificationSection(
                        title: 'Notification Types',
                        icon: Icons.notifications_active,
                        children: notificationTypes.map((notification) => 
                          _buildNotificationTile(
                            title: notification['title'],
                            description: notification['description'],
                            icon: notification['icon'],
                            enabled: notification['enabled'],
                            onChanged: (value) {
                              setState(() {
                                notification['enabled'] = value;
                              });
                            },
                            isDark: isDark,
                          ),
                        ).toList(),
                        isDark: isDark,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Quiet hours
                      _buildNotificationSection(
                        title: 'Quiet Hours',
                        icon: Icons.bedtime,
                        children: quietHours.map((setting) => 
                          _buildNotificationTile(
                            title: setting['title'],
                            description: setting['description'],
                            icon: setting['icon'],
                            enabled: setting['enabled'],
                            onChanged: (value) {
                              setState(() {
                                setting['enabled'] = value;
                              });
                            },
                            isDark: isDark,
                          ),
                        ).toList(),
                        isDark: isDark,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Notification preview
                      _buildNotificationPreview(isDark),
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

  Widget _buildNotificationSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
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
          ...children,
        ],
      ),
    );

  Widget _buildNotificationTile({
    required String title,
    required String description,
    required IconData icon,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: enabled
                  ? AppTheme.primaryLight.withValues(alpha: 0.1)
                  : (isDark ? Colors.grey[700] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: enabled ? AppTheme.primaryLight : Colors.grey[600],
              size: 20,
            ),
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
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryLight,
          ),
        ],
      ),
    );

  Widget _buildNotificationPreview(bool isDark) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppTheme.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Notification Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Nebu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'now',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your voice command has been processed successfully!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'This is how notifications will appear on your device',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
}
