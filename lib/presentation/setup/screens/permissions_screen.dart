import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_text.dart';
import '../../widgets/setup_progress_indicator.dart';
import '../setup_wizard_controller.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final controller = Get.find<SetupWizardController>();
  bool isLoading = false;

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
                'Permissions',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'We need a few permissions to provide you with the best experience',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Permissions list
              Expanded(
                child: Column(
                  children: [
                    _buildPermissionCard(
                      icon: Icons.mic,
                      title: 'Microphone',
                      description: 'Required for voice commands and audio features',
                      isGranted: controller.microphonePermission.value,
                      onTap: _requestMicrophonePermission,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      description: 'Send you important updates and reminders',
                      isGranted: controller.notificationsPermission.value,
                      onTap: _requestNotificationPermission,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildPermissionCard(
                      icon: Icons.camera_alt,
                      title: 'Camera (Optional)',
                      description: 'For photo capture and video features',
                      isGranted: controller.cameraPermission.value,
                      onTap: _requestCameraPermission,
                      isDark: isDark,
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
                    onPressed: controller.canProceed() && !isLoading
                        ? controller.nextStep
                        : null,
                    isFullWidth: true,
                    isLoading: isLoading,
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

  Widget _buildPermissionCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onTap,
    required bool isDark,
    bool isOptional = false,
  }) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? AppTheme.primaryLight
              : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
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
                  ? AppTheme.primaryLight.withValues(alpha: 0.1)
                  : (isDark ? Colors.grey[700] : Colors.grey[200]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? AppTheme.primaryLight : Colors.grey[600],
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
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
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
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isGranted ? AppTheme.primaryLight : Colors.grey[600],
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
      controller.microphonePermission.value = status.isGranted;
      
      if (!status.isGranted) {
        _showPermissionDeniedDialog('Microphone');
      }
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
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
      controller.notificationsPermission.value = status.isGranted;
      
      if (!status.isGranted) {
        _showPermissionDeniedDialog('Notifications');
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
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
      controller.cameraPermission.value = status.isGranted;
      
      if (!status.isGranted) {
        _showPermissionDeniedDialog('Camera');
      }
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
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
