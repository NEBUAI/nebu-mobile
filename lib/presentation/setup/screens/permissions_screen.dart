import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_notifier.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool isLoading = false;

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
                'Permissions',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.sectionTitleBottomMargin),

              // Subtitle
              Text(
                'We need a few permissions to provide you with the best experience',
                style: TextStyle(
                  fontSize: 16,
                  color: context.colors.grey400,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: context.spacing.largePageBottomMargin),

              // Permissions list
              Expanded(
                child: Column(
                  children: [
                    _buildPermissionCard(
                      icon: Icons.mic,
                      title: 'Microphone',
                      description:
                          'Required for voice commands and audio features',
                      isGranted: state.microphonePermission,
                      onTap: _requestMicrophonePermission,
                    ),
                    SizedBox(height: context.spacing.sectionTitleBottomMargin),
                    _buildPermissionCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      description: 'Send you important updates and reminders',
                      isGranted: state.notificationsPermission,
                      onTap: _requestNotificationPermission,
                    ),
                    SizedBox(height: context.spacing.sectionTitleBottomMargin),
                    _buildPermissionCard(
                      icon: Icons.camera_alt,
                      title: 'Camera (Optional)',
                      description: 'For photo capture and video features',
                      isGranted: state.cameraPermission,
                      onTap: _requestCameraPermission,
                      isOptional: true,
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                children: [
                  CustomButton(
                    text: 'Continue',
                    onPressed: state.canProceed() && !isLoading
                        ? notifier.nextStep
                        : null,
                    isFullWidth: true,
                    isLoading: isLoading,
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

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onTap,
    bool isOptional = false,
  }) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isGranted
            ? context.colors.primary
            : context.colors.grey700,
        width: 2,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isGranted
                ? context.colors.primary.withValues(alpha: 0.1)
                : context.colors.grey800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isGranted ? context.colors.primary : context.colors.grey400,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isOptional) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 10,
                          color: context.colors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.grey400,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onTap,
          icon: Icon(
            isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isGranted ? context.colors.primary : context.colors.grey400,
            size: 28,
          ),
        ),
      ],
    ),
  );

  Future<void> _requestMicrophonePermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      final status = await Permission.microphone.request();
      ref
          .read<SetupWizardNotifier>(setupWizardProvider.notifier)
          .updateMicrophonePermission(granted: status.isGranted);

      if (!status.isGranted) {
        _showPermissionDeniedDialog('Microphone');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting microphone permission: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      final status = await Permission.notification.request();
      ref
          .read<SetupWizardNotifier>(setupWizardProvider.notifier)
          .updateNotificationsPermission(granted: status.isGranted);

      if (!status.isGranted) {
        _showPermissionDeniedDialog('Notifications');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting notification permission: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      isLoading = true;
    });

    try {
      final status = await Permission.camera.request();
      ref
          .read<SetupWizardNotifier>(setupWizardProvider.notifier)
          .updateCameraPermission(granted: status.isGranted);

      if (!status.isGranted) {
        _showPermissionDeniedDialog('Camera');
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting camera permission: $e');
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission'),
        content: Text(
          'The $permission permission was denied. You can enable it later in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
