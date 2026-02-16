import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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
    final SetupWizardState state = ref.watch(setupWizardProvider);
    final SetupWizardNotifier notifier = ref.read(setupWizardProvider.notifier);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.spacing.pageMargin),
          child: Column(
            children: [
              SizedBox(height: context.spacing.largePageBottomMargin),
              // Progress indicator
              SetupProgressIndicator(
                currentStep: state.currentStep + 1,
                totalSteps: SetupWizardState.totalSteps,
              ),
              SizedBox(height: context.spacing.largePageBottomMargin),

              // Title
              const GradientText(
                'Notifications',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              // Subtitle
              Text(
                'Choose how you want to be notified',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.grey400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.largePageBottomMargin),

              // Notifications content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Notification types
                      _buildNotificationSection(
                        title: 'Notification Types',
                        icon: Icons.notifications_active,
                        children: notificationTypes
                            .map(
                              (notification) => _buildNotificationTile(
                                title: notification['title'] as String,
                                description:
                                    notification['description'] as String,
                                icon: notification['icon'] as IconData,
                                enabled: notification['enabled'] as bool,
                                onChanged: (value) {
                                  setState(() {
                                    notification['enabled'] = value;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),

                      SizedBox(height: context.spacing.panelPadding),

                      // Quiet hours
                      _buildNotificationSection(
                        title: 'Quiet Hours',
                        icon: Icons.bedtime,
                        children: quietHours
                            .map(
                              (setting) => _buildNotificationTile(
                                title: setting['title'] as String,
                                description: setting['description'] as String,
                                icon: setting['icon'] as IconData,
                                enabled: setting['enabled'] as bool,
                                onChanged: (value) {
                                  setState(() {
                                    setting['enabled'] = value;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),

                      SizedBox(height: context.spacing.panelPadding),

                      // Notification preview
                      _buildNotificationPreview(),
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
                  SizedBox(height: context.spacing.sectionTitleBottomMargin),
                  TextButton(
                    onPressed: notifier.previousStep,
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: context.colors.grey400,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: context.spacing.titleBottomMargin),
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
  }) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? context.colors.primary.withValues(alpha: 0.1)
                : context.colors.grey700,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? context.colors.primary : context.colors.grey500,
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
                  color: context.colors.grey400,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: enabled,
          onChanged: onChanged,
          activeThumbColor: context.colors.primary,
        ),
      ],
    ),
  );

  Widget _buildNotificationPreview() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [context.colors.primary, context.colors.secondary],
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
                color: context.colors.textOnFilled.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
                color: context.colors.textOnFilled,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Notification Preview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textOnFilled,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.textOnFilled.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Nebu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textOnFilled,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'now',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colors.textOnFilled.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Your voice command has been processed successfully!',
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textOnFilled.withValues(alpha: 0.9),
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
            color: context.colors.textOnFilled.withValues(alpha: 0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    ),
  );
}
