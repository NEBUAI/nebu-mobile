import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_setup.dart';
import '../../data/services/user_setup_service.dart';
import 'api_provider.dart';

/// Estado del setup del usuario
class UserSetupState {
  const UserSetupState({
    this.setup,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.isSetupComplete = false,
  });
  final UserSetup? setup;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final bool isSetupComplete;

  UserSetupState copyWith({
    UserSetup? setup,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool? isSetupComplete,
  }) => UserSetupState(
    setup: setup ?? this.setup,
    isLoading: isLoading ?? this.isLoading,
    isSaving: isSaving ?? this.isSaving,
    error: error,
    isSetupComplete: isSetupComplete ?? this.isSetupComplete,
  );
}

/// Provider para gestionar el estado del setup del usuario
class UserSetupNotifier extends Notifier<UserSetupState> {
  UserSetupService get _userSetupService => ref.read(userSetupServiceProvider);

  @override
  UserSetupState build() => const UserSetupState();

  /// Cargar configuración guardada del usuario
  Future<void> loadSetup(String userId) async {
    state = state.copyWith(isLoading: true);

    try {
      final setup = await _userSetupService.getSetup(userId);
      state = state.copyWith(
        setup: setup,
        isLoading: false,
        isSetupComplete: true,
      );
    } catch (e) {
      // Si no existe setup, no es un error crítico
      state = state.copyWith(isLoading: false, isSetupComplete: false);
    }
  }

  /// Guardar configuración completa del setup (atómico)
  Future<bool> saveSetup({
    required String userId,
    required UserProfile profile,
    required UserPreferences preferences,
    required NotificationSettings notifications,
    required VoiceSettings voice,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      final response = await _userSetupService.saveSetup(
        userId: userId,
        profile: profile,
        preferences: preferences,
        notifications: notifications,
        voice: voice,
      );

      // Construir el UserSetup del response si viene
      final setup =
          response.setup ??
          UserSetup(
            profile: profile,
            preferences: preferences,
            notifications: notifications,
            voice: voice,
            setupCompleted: response.setupCompleted,
          );

      state = state.copyWith(
        setup: setup,
        isSaving: false,
        isSetupComplete: true,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Actualizar solo las preferencias (PATCH parcial)
  Future<bool> updatePreferences({
    required String userId,
    String? language,
    String? theme,
    bool? hapticFeedback,
    bool? autoSave,
    bool? analytics,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      await _userSetupService.updatePreferences(
        userId: userId,
        language: language,
        theme: theme,
        hapticFeedback: hapticFeedback,
        autoSave: autoSave,
        analytics: analytics,
      );

      // Actualizar solo las preferencias en el estado actual
      if (state.setup != null) {
        final updatedPreferences = state.setup!.preferences.copyWith(
          language: language ?? state.setup!.preferences.language,
          theme: theme ?? state.setup!.preferences.theme,
          hapticFeedback:
              hapticFeedback ?? state.setup!.preferences.hapticFeedback,
          autoSave: autoSave ?? state.setup!.preferences.autoSave,
          analytics: analytics ?? state.setup!.preferences.analytics,
        );

        final updatedSetup = state.setup!.copyWith(
          preferences: updatedPreferences,
        );

        state = state.copyWith(setup: updatedSetup, isSaving: false);
      }

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Actualizar perfil del usuario
  Future<bool> updateProfile({
    required String userId,
    required UserProfile profile,
  }) async {
    if (state.setup == null) {
      return false;
    }
    state = state.copyWith(isSaving: true);

    try {
      // Re-guardar toda la configuración con el nuevo perfil
      final response = await _userSetupService.saveSetup(
        userId: userId,
        profile: profile,
        preferences: state.setup!.preferences,
        notifications: state.setup!.notifications,
        voice: state.setup!.voice,
      );

      final setup = response.setup ?? state.setup!.copyWith(profile: profile);

      state = state.copyWith(setup: setup, isSaving: false);

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Actualizar configuración de notificaciones
  Future<bool> updateNotifications({
    required String userId,
    required NotificationSettings notifications,
  }) async {
    if (state.setup == null) return false;

    state = state.copyWith(isSaving: true);

    try {
      final response = await _userSetupService.saveSetup(
        userId: userId,
        profile: state.setup!.profile,
        preferences: state.setup!.preferences,
        notifications: notifications,
        voice: state.setup!.voice,
      );

      final setup =
          response.setup ?? state.setup!.copyWith(notifications: notifications);

      state = state.copyWith(setup: setup, isSaving: false);

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Actualizar configuración de voz
  Future<bool> updateVoice({
    required String userId,
    required VoiceSettings voice,
  }) async {
    if (state.setup == null) return false;

    state = state.copyWith(isSaving: true);

    try {
      final response = await _userSetupService.saveSetup(
        userId: userId,
        profile: state.setup!.profile,
        preferences: state.setup!.preferences,
        notifications: state.setup!.notifications,
        voice: voice,
      );

      final setup = response.setup ?? state.setup!.copyWith(voice: voice);

      state = state.copyWith(setup: setup, isSaving: false);

      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  /// Limpiar estado
  void clear() {
    state = const UserSetupState();
  }
}

/// Provider del notifier de user setup
final userSetupNotifierProvider =
    NotifierProvider<UserSetupNotifier, UserSetupState>(UserSetupNotifier.new);

/// Provider para verificar si el setup está completo
final isSetupCompleteProvider = Provider<bool>((ref) {
  final state = ref.watch(userSetupNotifierProvider);
  return state.isSetupComplete && state.setup != null;
});

/// Provider para obtener las preferencias actuales
final currentPreferencesProvider = Provider<UserPreferences?>((ref) {
  final state = ref.watch(userSetupNotifierProvider);
  return state.setup?.preferences;
});

/// Provider para obtener el perfil actual
final currentProfileProvider = Provider<UserProfile?>((ref) {
  final state = ref.watch(userSetupNotifierProvider);
  return state.setup?.profile;
});

/// Provider para obtener las notificaciones actuales
final currentNotificationSettingsProvider = Provider<NotificationSettings?>((
  ref,
) {
  final state = ref.watch(userSetupNotifierProvider);
  return state.setup?.notifications;
});

/// Provider para obtener la configuración de voz actual
final currentVoiceSettingsProvider = Provider<VoiceSettings?>((ref) {
  final state = ref.watch(userSetupNotifierProvider);
  return state.setup?.voice;
});
