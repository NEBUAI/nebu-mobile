import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Ejemplo de servicio HTTP usando AppConfig
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.getApiUrl(),
        headers: {
          if (AppConfig.getApiKey().isNotEmpty)
            'Authorization': 'Bearer ${AppConfig.getApiKey()}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Logging solo en desarrollo
    if (AppConfig.shouldShowDebugLogs) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }

  Dio get dio => _dio;

  /// Ejemplo de uso
  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$userId');
    return response.data ?? {};
  }
}
