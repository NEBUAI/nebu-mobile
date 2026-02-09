import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'api_service.dart';

class NotificationService {
  NotificationService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Get my notifications
  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      _logger.d('Fetching my notifications');
      final response = await _apiService.get<List<dynamic>>(
        '/notifications/my',
      );
      return response.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _logger.e('Error fetching notifications: ${e.message}');
      return [];
    }
  }

  /// Get unread notifications
  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    try {
      _logger.d('Fetching unread notifications');
      final response = await _apiService.get<List<dynamic>>(
        '/notifications/my/unread',
      );
      return response.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      _logger.e('Error fetching unread notifications: ${e.message}');
      return [];
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      _logger.d('Marking notification $notificationId as read');
      await _apiService.patch<Map<String, dynamic>>(
        '/notifications/$notificationId/read',
      );
      return true;
    } on DioException catch (e) {
      _logger.e('Error marking notification as read: ${e.message}');
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      _logger.d('Marking all notifications as read');
      await _apiService.patch<Map<String, dynamic>>('/notifications/read-all');
      return true;
    } on DioException catch (e) {
      _logger.e('Error marking all as read: ${e.message}');
      return false;
    }
  }

  /// Delete a notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      _logger.d('Deleting notification $notificationId');
      await _apiService.delete<Map<String, dynamic>>(
        '/notifications/$notificationId',
      );
      return true;
    } on DioException catch (e) {
      _logger.e('Error deleting notification: ${e.message}');
      return false;
    }
  }
}
