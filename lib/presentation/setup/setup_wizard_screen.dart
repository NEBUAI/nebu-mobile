import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import 'screens/completion_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/voice_setup_screen.dart';
import 'screens/welcome_screen.dart';
import 'setup_wizard_controller.dart';

class SetupWizardScreen extends StatelessWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SetupWizardController());

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          WelcomeScreen(),
          PermissionsScreen(),
          ProfileSetupScreen(),
          PreferencesScreen(),
          VoiceSetupScreen(),
          NotificationsScreen(),
          CompletionScreen(),
        ],
      ),
    );
  }
}
