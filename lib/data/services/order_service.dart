import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'api_service.dart';

class OrderService {
  OrderService({required ApiService apiService, required Logger logger})
    : _apiService = apiService,
      _logger = logger;

  final ApiService _apiService;
  final Logger _logger;

  /// Get all orders for the authenticated user
  Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      _logger.d('Fetching my orders');
      final response = await _apiService.get<dynamic>('/orders/my');
      // Backend may return a direct array or paginated {data: [...]}
      if (response is List) {
        return response.cast<Map<String, dynamic>>();
      }
      if (response is Map<String, dynamic> &&
          response.containsKey('data') &&
          response['data'] is List) {
        return (response['data'] as List).cast<Map<String, dynamic>>();
      }
      return [];
    } on Exception catch (e) {
      _logger.e('Error fetching orders: $e');
      return [];
    }
  }

  /// Get a specific order by ID
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      _logger.d('Fetching order $orderId');
      return await _apiService.get<Map<String, dynamic>>('/orders/$orderId');
    } on DioException catch (e) {
      _logger.e('Error fetching order: ${e.message}');
      return null;
    }
  }
}
