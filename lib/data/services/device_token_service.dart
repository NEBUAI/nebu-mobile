import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Solicitud de token de dispositivo
class DeviceTokenRequest {

  const DeviceTokenRequest({
    required this.deviceId,
  });
  final String deviceId;

  Map<String, dynamic> toJson() => {
    'device_id': deviceId,
  };
}

/// Respuesta de token de dispositivo
class DeviceTokenResponse {

  const DeviceTokenResponse({
    required this.accessToken,
    required this.roomName,
    required this.expiresIn,
  });

  factory DeviceTokenResponse.fromJson(Map<String, dynamic> json) =>
      DeviceTokenResponse(
        accessToken: json['access_token'] as String,
        roomName: json['room_name'] as String,
        expiresIn: json['expires_in'] as int,
      );
  final String accessToken;
  final String roomName;
  final int expiresIn;

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'room_name': roomName,
    'expires_in': expiresIn,
  };
}

/// Error de token de dispositivo
class DeviceTokenError {

  const DeviceTokenError({
    required this.error,
  });

  factory DeviceTokenError.fromJson(Map<String, dynamic> json) =>
      DeviceTokenError(
        error: json['error'] as String,
      );
  final String error;
}

/// Servicio de tokens de dispositivo
class DeviceTokenService {

  DeviceTokenService({
    required Logger logger,
    required Dio dio,
  }) : _logger = logger,
       _dio = dio;
  final Logger _logger;
  final Dio _dio;

  static const String _baseEndpoint = '/livekit/iot/token';
  
  // Cache de tokens
  final Map<String, DeviceTokenResponse> _tokenCache = {};
  final Map<String, DateTime> _tokenExpiry = {};

  /// Solicitar token LiveKit para dispositivo IoT
  Future<DeviceTokenResponse> requestDeviceToken(String deviceId) async {
    try {
      _logger.d('Requesting device token for: $deviceId');

      // Validar formato del device_id
      if (!_isValidDeviceId(deviceId)) {
        throw Exception('Invalid device ID format');
      }

      // Verificar cache primero
      if (_isTokenValid(deviceId)) {
        _logger.d('Using cached token for device: $deviceId');
        return _tokenCache[deviceId]!;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        _baseEndpoint,
        data: DeviceTokenRequest(deviceId: deviceId).toJson(),
      );

      final tokenResponse = DeviceTokenResponse.fromJson(response.data!);
      
      // Guardar en cache
      _tokenCache[deviceId] = tokenResponse;
      _tokenExpiry[deviceId] = DateTime.now().add(
        Duration(seconds: tokenResponse.expiresIn - 300), // 5 min buffer
      );

      _logger.i('Device token obtained successfully for: $deviceId');
      return tokenResponse;
    } catch (e) {
      _logger.e('Error requesting device token: $e');
      
      // Si el dispositivo no está vinculado (404)
      if (e is DioException && e.response?.statusCode == 404) {
        throw Exception('Device not linked to user account');
      }
      
      // Si el dispositivo no está autorizado (403)
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('Device not authorized');
      }
      
      // Si hay error del servidor (500)
      if (e is DioException && e.response?.statusCode == 500) {
        throw Exception('Server error occurred');
      }
      
      rethrow;
    }
  }

  /// Validar formato del device ID
  bool _isValidDeviceId(String deviceId) {
    // Validar que tenga formato válido (ej: ESP32-XXXXXX o similar)
    final regex = RegExp(r'^[A-Za-z0-9_-]{6,32}$');
    return regex.hasMatch(deviceId);
  }

  /// Verificar si el token está válido en cache
  bool _isTokenValid(String deviceId) {
    final cachedToken = _tokenCache[deviceId];
    final expiry = _tokenExpiry[deviceId];
    
    if (cachedToken == null || expiry == null) {
      return false;
    }
    
    return DateTime.now().isBefore(expiry);
  }

  /// Obtener token válido (cache o nuevo)
  Future<DeviceTokenResponse> getValidToken(String deviceId) async {
    if (_isTokenValid(deviceId)) {
      return _tokenCache[deviceId]!;
    }
    
    return requestDeviceToken(deviceId);
  }

  /// Revocar token de dispositivo
  Future<bool> revokeDeviceToken(String deviceId) async {
    try {
      _logger.i('Revoking device token for: $deviceId');

      await _dio.delete<void>('$_baseEndpoint/$deviceId');
      
      // Remover del cache
      _tokenCache.remove(deviceId);
      _tokenExpiry.remove(deviceId);
      
      _logger.i('Device token revoked successfully for: $deviceId');
      return true;
    } on Exception catch (e) {
      _logger.e('Error revoking device token: $e');
      return false;
    }
  }

  /// Verificar estado del token
  Future<bool> verifyTokenStatus(String deviceId) async {
    try {
      _logger.d('Verifying token status for: $deviceId');

      final response = await _dio.get<Map<String, dynamic>>('$_baseEndpoint/$deviceId/status');

      final isValid = response.data?['valid'] as bool? ?? false;
      
      if (!isValid) {
        // Remover del cache si no es válido
        _tokenCache.remove(deviceId);
        _tokenExpiry.remove(deviceId);
      }
      
      _logger.d('Token status for $deviceId: ${isValid ? 'valid' : 'invalid'}');
      return isValid;
    } on Exception catch (e) {
      _logger.e('Error verifying token status: $e');
      return false;
    }
  }

  /// Limpiar cache de tokens expirados
  void clearExpiredTokens() {
    final now = DateTime.now();
    final expiredDevices = <String>[];
    
    _tokenExpiry.forEach((deviceId, expiry) {
      if (now.isAfter(expiry)) {
        expiredDevices.add(deviceId);
      }
    });
    
    for (final deviceId in expiredDevices) {
      _tokenCache.remove(deviceId);
      _tokenExpiry.remove(deviceId);
    }
    
    if (expiredDevices.isNotEmpty) {
      _logger.i('Cleared ${expiredDevices.length} expired tokens');
    }
  }

  /// Limpiar todo el cache
  void clearTokenCache() {
    _tokenCache.clear();
    _tokenExpiry.clear();
    _logger.i('Token cache cleared');
  }

  /// Obtener información del token desde cache
  DeviceTokenResponse? getCachedToken(String deviceId) => _isTokenValid(deviceId) ? _tokenCache[deviceId] : null;

  /// Obtener tiempo restante del token
  Duration? getTokenTimeRemaining(String deviceId) {
    final expiry = _tokenExpiry[deviceId];
    if (expiry == null) {
      return null;
    }
    
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  /// Obtener estadísticas del cache
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    int validTokens = 0;
    int expiredTokens = 0;
    
    _tokenExpiry.forEach((deviceId, expiry) {
      if (now.isBefore(expiry)) {
        validTokens++;
      } else {
        expiredTokens++;
      }
    });
    
    return {
      'totalTokens': _tokenCache.length,
      'validTokens': validTokens,
      'expiredTokens': expiredTokens,
      'cachedDevices': _tokenCache.keys.toList(),
    };
  }

  /// Cerrar servicio
  Future<void> dispose() async {
    clearTokenCache();
    _logger.i('Device Token Service disposed');
  }
}
