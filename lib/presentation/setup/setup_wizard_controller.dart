import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SetupWizardController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;
  final RxBool isCompleted = false.obs;

  // Form data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool voiceEnabled = true.obs;
  final RxString selectedLanguage = 'en'.obs;
  final RxString selectedTheme = 'system'.obs;

  // Permissions
  final RxBool microphonePermission = false.obs;
  final RxBool cameraPermission = false.obs;
  final RxBool notificationsPermission = false.obs;

  final int totalSteps = 7;

  @override
  void onInit() {
    super.onInit();
    _initializeSetup();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void _initializeSetup() {
    // Check if setup was already completed
    // This would typically check shared preferences or database
    isCompleted.value = false;
  }

  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      currentStep.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      completeSetup();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
      pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void completeSetup() {
    // Save setup data to preferences/database
    _saveSetupData();
    isCompleted.value = true;
    
    // Navigate to main app
    Get.offAllNamed('/main');
  }

  void _saveSetupData() {
    // Save all setup preferences
    // This would typically use SharedPreferences or a local database
    print('Saving setup data:');
    print('User: ${userName.value}');
    print('Email: ${userEmail.value}');
    print('Language: ${selectedLanguage.value}');
    print('Theme: ${selectedTheme.value}');
    print('Notifications: ${notificationsEnabled.value}');
    print('Voice: ${voiceEnabled.value}');
  }

  void skipSetup() {
    // Skip setup and go to main app
    Get.offAllNamed('/main');
  }

  bool canProceed() {
    switch (currentStep.value) {
      case 0: // Welcome
        return true;
      case 1: // Permissions
        return microphonePermission.value && notificationsPermission.value;
      case 2: // Profile Setup
        return userName.value.isNotEmpty && userEmail.value.isNotEmpty;
      case 3: // Preferences
        return true;
      case 4: // Voice Setup
        return true;
      case 5: // Notifications
        return true;
      case 6: // Completion
        return true;
      default:
        return false;
    }
  }

  double get progress => (currentStep.value + 1) / totalSteps;
}
