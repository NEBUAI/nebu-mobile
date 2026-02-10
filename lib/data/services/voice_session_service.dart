import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'api_service.dart';

class VoiceSessionService {
  VoiceSessionService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Create a new voice session
  Future<Map<String, dynamic>> createSession({
    required String userId,
    String? sessionToken,
    String? roomName,
    String language = 'es',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.d('Creating voice session for user: $userId');
      final response = await _apiService.post<Map<String, dynamic>>(
        '/voice/sessions',
        data: {
          'userId': userId,
          if (sessionToken != null) 'sessionToken': sessionToken,
          if (roomName != null) 'roomName': roomName,
          'language': language,
          if (metadata != null) 'metadata': metadata,
        },
      );
      _logger.d('Voice session created: ${response['id']}');
      return response;
    } on DioException catch (e) {
      _logger.e('Error creating voice session: ${e.message}');
      rethrow;
    }
  }

  /// Get voice sessions with optional filters
  Future<List<Map<String, dynamic>>> getSessions({
    String? userId,
    String? status,
    String? language,
  }) async {
    try {
      _logger.d('Fetching voice sessions');
      final response = await _apiService.get<dynamic>(
        '/voice/sessions',
        queryParameters: {
          if (userId != null) 'userId': userId,
          if (status != null) 'status': status,
          if (language != null) 'language': language,
        },
      );
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching voice sessions: ${e.message}');
      return [];
    }
  }

  /// Get a specific session by ID (includes conversations)
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      _logger.d('Fetching voice session: $sessionId');
      return await _apiService
          .get<Map<String, dynamic>>('/voice/sessions/$sessionId');
    } on DioException catch (e) {
      _logger.e('Error fetching voice session: ${e.message}');
      return null;
    }
  }

  /// Get sessions for a specific user
  Future<List<Map<String, dynamic>>> getUserSessions(String userId) async {
    try {
      _logger.d('Fetching sessions for user: $userId');
      final response = await _apiService
          .get<dynamic>('/voice/sessions/user/$userId');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching user sessions: ${e.message}');
      return [];
    }
  }

  /// Get active voice sessions
  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    try {
      _logger.d('Fetching active voice sessions');
      final response = await _apiService
          .get<dynamic>('/voice/sessions/active');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching active sessions: ${e.message}');
      return [];
    }
  }

  /// End a voice session
  Future<Map<String, dynamic>?> endSession(
    String sessionId, {
    String? reason,
  }) async {
    try {
      _logger.d('Ending voice session: $sessionId');
      return await _apiService.post<Map<String, dynamic>>(
        '/voice/sessions/$sessionId/end',
        data: {if (reason != null) 'reason': reason},
      );
    } on DioException catch (e) {
      _logger.e('Error ending voice session: ${e.message}');
      return null;
    }
  }

  /// Get conversations for a session
  Future<List<Map<String, dynamic>>> getSessionConversations(
    String sessionId,
  ) async {
    try {
      _logger.d('Fetching conversations for session: $sessionId');
      final response = await _apiService
          .get<dynamic>('/voice/sessions/$sessionId/conversations');
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      return [];
    } on DioException catch (e) {
      _logger.e('Error fetching conversations: ${e.message}');
      return [];
    }
  }

  /// Get session metrics/statistics
  Future<Map<String, dynamic>?> getSessionMetrics() async {
    try {
      _logger.d('Fetching voice session metrics');
      return await _apiService
          .get<Map<String, dynamic>>('/voice/sessions/metrics');
    } on DioException catch (e) {
      _logger.e('Error fetching session metrics: ${e.message}');
      return null;
    }
  }
}
