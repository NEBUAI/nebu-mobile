import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/env_config.dart';

class ApiService {
  ApiService({
    required this.dio,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  }) : _secureStorage = secureStorage,
       _logger = logger {
    _setupDio();
  }
  final Dio dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  void _setupDio() {
    dio.options.baseUrl = EnvConfig.urlBackend;
    dio.options.connectTimeout = Duration(milliseconds: EnvConfig.apiTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: EnvConfig.apiTimeout);

    // Request interceptor - Add auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(
            key: AppConstants.keyAccessToken,
          );

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          _logger
            ..d('Request: ${options.method} ${options.path}')
            ..d('Headers: ${options.headers}');

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          _logger
            ..e(
              'Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            )
            ..e('Error message: ${error.message}');

          // Handle 401 Unauthorized - Try to refresh token
          if (error.response?.statusCode == 401) {
            final refreshToken = await _secureStorage.read(
              key: AppConstants.keyRefreshToken,
            );

            if (refreshToken != null && refreshToken.isNotEmpty) {
              try {
                // Try to refresh the token
                final refreshResponse = await dio.post<Map<String, dynamic>>(
                  '/auth/refresh',
                  data: {'refreshToken': refreshToken},
                  options: Options(
                    headers: {
                      'Authorization': null, // Remove old token
                    },
                  ),
                );

                final newAccessToken =
                    refreshResponse.data?['accessToken'] as String;
                await _secureStorage.write(
                  key: AppConstants.keyAccessToken,
                  value: newAccessToken,
                );

                // Retry the original request with new token
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await dio.fetch<dynamic>(
                  error.requestOptions,
                );
                return handler.resolve(retryResponse);
              } on Exception catch (e) {
                _logger.e('Token refresh failed: $e');
                // Clear tokens and redirect to login
                await _secureStorage.delete(key: AppConstants.keyAccessToken);
                await _secureStorage.delete(key: AppConstants.keyRefreshToken);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (only in debug mode)
    if (EnvConfig.isDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: _logger.d,
        ),
      );
    }
  }

  // Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('GET request failed: $e');
      rethrow;
    }
  }

  // Generic POST request
  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('POST request failed: $e');
      rethrow;
    }
  }

  // Generic PUT request
  Future<T> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('PUT request failed: $e');
      rethrow;
    }
  }

  // Generic DELETE request
  Future<T> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      rethrow;
    }
  }

  // Generic PATCH request
  Future<T> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response.data as T;
    } catch (e) {
      _logger.e('PATCH request failed: $e');
      rethrow;
    }
  }
}
