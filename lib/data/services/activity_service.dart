import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../models/activity.dart';
import 'api_service.dart';

class ActivityService {
  ActivityService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Get activities with filters and pagination
  Future<ActivityListResponse> getActivities({
    required String userId,
    String? toyId,
    ActivityType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? page,
  }) async {
    try {
      _logger.d('Fetching activities for user: $userId');

      final queryParameters = <String, dynamic>{
        'userId': userId,
        if (toyId != null) 'toyId': toyId,
        if (type != null) 'type': type.name,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (limit != null) 'limit': limit,
        if (page != null) 'page': page,
      };

      final response = await _apiService.get<Map<String, dynamic>>(
        '/activities',
        queryParameters: queryParameters,
      );

      _logger.d('Activities fetched successfully');
      return ActivityListResponse.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching activities: ${e.message}');
      throw Exception('Error al obtener actividades: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error fetching activities: $e');
      throw Exception('Error inesperado al obtener actividades');
    }
  }

  /// Create a new activity
  Future<Activity> createActivity({
    required String userId,
    required ActivityType type,
    required String description,
    String? toyId,
    Map<String, dynamic>? metadata,
    DateTime? timestamp,
  }) async {
    try {
      _logger.d('Creating activity: $type for user: $userId');

      final response = await _apiService.post<Map<String, dynamic>>(
        '/activities',
        data: {
          'userId': userId,
          if (toyId != null) 'toyId': toyId,
          'type': type.name,
          'description': description,
          if (metadata != null) 'metadata': metadata,
          if (timestamp != null) 'timestamp': timestamp.toIso8601String(),
        },
      );

      _logger.d('Activity created successfully');
      return Activity.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error creating activity: ${e.message}');
      throw Exception('Error al crear actividad: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error creating activity: $e');
      throw Exception('Error inesperado al crear actividad');
    }
  }

  /// Get activity statistics for a user
  Future<ActivityStats> getActivityStats(String userId) async {
    try {
      _logger.d('Fetching activity stats for user: $userId');

      final response = await _apiService.get<Map<String, dynamic>>(
        '/activities/stats/$userId',
      );

      _logger.d('Activity stats fetched successfully');
      return ActivityStats.fromJson(response);
    } on DioException catch (e) {
      _logger.e('Error fetching activity stats: ${e.message}');
      throw Exception('Error al obtener estadísticas: ${e.message}');
    } on Exception catch (e) {
      _logger.e('Unexpected error fetching activity stats: $e');
      throw Exception('Error inesperado al obtener estadísticas');
    }
  }
}
