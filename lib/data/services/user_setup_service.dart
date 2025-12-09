import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/user_setup.dart';
import 'api_service.dart';

class UserSetupService {
  UserSetupService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Save complete setup configuration
  Future<SetupResponse> saveSetup({
    required String userId,
    required UserProfile profile,
    required UserPreferences preferences,
    required NotificationSettings notifications,
    required VoiceSettings voice,
  }) async {
    try {
      _logger.d('Saving setup for user: $userId');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/users/$userId/setup',
        data: {
          'profile': profile.toJson(),
          'preferences': preferences.toJson(),
          'notifications': notifications.toJson(),
          'voice': voice.toJson(),
        },
      );

      _logger.d('Setup saved successfully');
      return SetupResponse.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error saving setup: ${e.message}');
      throw Exception('Error al guardar configuración: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error saving setup: $e');
      throw Exception('Error inesperado al guardar configuración');
    }
  }

  /// Get setup configuration
  Future<UserSetup> getSetup(String userId) async {
    try {
      _logger.d('Fetching setup for user: $userId');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/users/$userId/setup',
      );

      _logger.d('Setup fetched successfully');
      return UserSetup.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching setup: ${e.message}');
      if (e.response?.statusCode == 404) {
        // Setup not found, return default
        throw Exception('Configuración no encontrada');
      }
      throw Exception('Error al obtener configuración: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error fetching setup: $e');
      throw Exception('Error inesperado al obtener configuración');
    }
  }

  /// Update user preferences
  Future<void> updatePreferences({
    required String userId,
    String? language,
    String? theme,
    bool? hapticFeedback,
    bool? autoSave,
    bool? analytics,
  }) async {
    try {
      _logger.d('Updating preferences for user: $userId');

      await _apiService.patch<Map<String, dynamic>>(
        '/users/$userId/preferences',
        data: {
          if (language != null) 'language': language,
          if (theme != null) 'theme': theme,
          if (hapticFeedback != null) 'hapticFeedback': hapticFeedback,
          if (autoSave != null) 'autoSave': autoSave,
          if (analytics != null) 'analytics': analytics,
        },
      );

      _logger.d('Preferences updated successfully');
    } on DioException catch (e) {
      _logger.e('Error updating preferences: ${e.message}');
      throw Exception('Error al actualizar preferencias: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error updating preferences: $e');
      throw Exception('Error inesperado al actualizar preferencias');
    }
  }
}
