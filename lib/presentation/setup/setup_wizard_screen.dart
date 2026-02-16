import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import 'screens/completion_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/voice_setup_screen.dart';
import 'screens/welcome_screen.dart';
import 'setup_wizard_notifier.dart';

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.watch(setupWizardPageControllerProvider);

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: PageView(
        controller: pageController,
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
