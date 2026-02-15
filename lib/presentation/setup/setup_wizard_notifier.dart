import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/storage_keys.dart';

/// Estado inmutable para el asistente de configuración
@immutable
class SetupWizardState {
  const SetupWizardState({
    this.currentStep = 0,
    this.isCompleted = false,
    this.userName = '',
    this.userEmail = '',
    this.avatarUrl = '',
    this.notificationsEnabled = true,
    this.voiceEnabled = true,
    this.selectedLanguage = 'en',
    this.selectedTheme = 'system',
    this.microphonePermission = false,
    this.cameraPermission = false,
    this.notificationsPermission = false,
    this.hapticFeedback = true,
    this.autoSave = true,
    this.analyticsEnabled = false,
  });

  final int currentStep;
  final bool isCompleted;

  // Form data
  final String userName;
  final String userEmail;
  final String avatarUrl;
  final bool notificationsEnabled;
  final bool voiceEnabled;
  final String selectedLanguage;
  final String selectedTheme;

  // Permissions
  final bool microphonePermission;
  final bool cameraPermission;
  final bool notificationsPermission;

  // Additional settings
  final bool hapticFeedback;
  final bool autoSave;
  final bool analyticsEnabled;

  static const int totalSteps = 7;

  SetupWizardState copyWith({
    int? currentStep,
    bool? isCompleted,
    String? userName,
    String? userEmail,
    String? avatarUrl,
    bool? notificationsEnabled,
    bool? voiceEnabled,
    String? selectedLanguage,
    String? selectedTheme,
    bool? microphonePermission,
    bool? cameraPermission,
    bool? notificationsPermission,
    bool? hapticFeedback,
    bool? autoSave,
    bool? analyticsEnabled,
  }) => SetupWizardState(
      currentStep: currentStep ?? this.currentStep,
      isCompleted: isCompleted ?? this.isCompleted,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      microphonePermission: microphonePermission ?? this.microphonePermission,
      cameraPermission: cameraPermission ?? this.cameraPermission,
      notificationsPermission:
          notificationsPermission ?? this.notificationsPermission,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      autoSave: autoSave ?? this.autoSave,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );

  double get progress => (currentStep + 1) / totalSteps;

  bool canProceed() {
    switch (currentStep) {
      case 0: // Welcome
        return true;
      case 1: // Permissions
        return microphonePermission && notificationsPermission;
      case 2: // Profile Setup
        return userName.isNotEmpty && userEmail.isNotEmpty;
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
}

/// Notificador para gestionar el estado del asistente de configuración
class SetupWizardNotifier extends Notifier<SetupWizardState> {
  // PageController se mantiene como campo de instancia (no es parte del estado)
  final PageController pageController = PageController();

  @override
  SetupWizardState build() {
    // Called when the provider is created
    _initializeSetup();
    return const SetupWizardState();
  }

  void _initializeSetup() {
    // Check if setup was already completed
    // This would typically check shared preferences or database
    state = state.copyWith(isCompleted: false);
  }

  void nextStep() {
    if (state.currentStep < SetupWizardState.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    // completeSetup se llama desde la UI cuando se presiona el botón final
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < SetupWizardState.totalSteps) {
      state = state.copyWith(currentStep: step);
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
    state = state.copyWith(isCompleted: true);
    // Navigation se maneja desde la UI con GoRouter
  }

  Future<void> _saveSetupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.setupLanguage, state.selectedLanguage);
    await prefs.setString(StorageKeys.setupTheme, state.selectedTheme);
    await prefs.setBool(StorageKeys.setupNotifications, state.notificationsEnabled);
    await prefs.setBool(StorageKeys.setupVoice, state.voiceEnabled);
    await prefs.setBool(StorageKeys.setupHapticFeedback, state.hapticFeedback);
    await prefs.setBool(StorageKeys.setupAutoSave, state.autoSave);
    await prefs.setBool(StorageKeys.setupAnalytics, state.analyticsEnabled);
    await prefs.setBool(StorageKeys.setupCompleted, true);
  }

  // Update methods para cada campo del formulario
  void updateUserName(String name) {
    state = state.copyWith(userName: name);
  }

  void updateUserEmail(String email) {
    state = state.copyWith(userEmail: email);
  }

  void updateAvatarUrl(String url) {
    state = state.copyWith(avatarUrl: url);
  }

  void updateNotificationsEnabled({required bool enabled}) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void updateVoiceEnabled({required bool enabled}) {
    state = state.copyWith(voiceEnabled: enabled);
  }

  void updateSelectedLanguage(String language) {
    state = state.copyWith(selectedLanguage: language);
  }

  void updateSelectedTheme(String theme) {
    state = state.copyWith(selectedTheme: theme);
  }

  void updateMicrophonePermission({required bool granted}) {
    state = state.copyWith(microphonePermission: granted);
  }

  void updateCameraPermission({required bool granted}) {
    state = state.copyWith(cameraPermission: granted);
  }

  void updateNotificationsPermission({required bool granted}) {
    state = state.copyWith(notificationsPermission: granted);
  }

  void updateHapticFeedback({required bool enabled}) {
    state = state.copyWith(hapticFeedback: enabled);
  }

  void updateAutoSave({required bool enabled}) {
    state = state.copyWith(autoSave: enabled);
  }

  void updateAnalyticsEnabled({required bool enabled}) {
    state = state.copyWith(analyticsEnabled: enabled);
  }
}

/// Provider para el notificador del asistente de configuración
final setupWizardProvider =
    NotifierProvider<SetupWizardNotifier, SetupWizardState>(
      SetupWizardNotifier.new,
    );

/// Provider para acceder al PageController
/// Nota: Este provider necesita ser autodispose para evitar memory leaks
final setupWizardPageControllerProvider = Provider.autoDispose<PageController>((
  ref,
) {
  final notifier = ref.read(setupWizardProvider.notifier);
  return notifier.pageController;
});
