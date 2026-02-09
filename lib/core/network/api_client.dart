import 'package:dio/dio.dart';

import '../config/config.dart';

/// Ejemplo de servicio HTTP usando Config
class ApiClient {
  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Config.apiBaseUrl,
        headers: {
          if (Config.apiKey.isNotEmpty)
            'Authorization': 'Bearer ${Config.apiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    // Logging solo en desarrollo
    if (Config.enableDebugLogs) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }
  late final Dio _dio;

  Dio get dio => _dio;

  /// Ejemplo de uso
  Future<Map<String, dynamic>> getUser(String userId) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$userId');
    return response.data ?? {};
  }
}
