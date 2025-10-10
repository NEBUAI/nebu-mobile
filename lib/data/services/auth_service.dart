import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/env_config.dart';
import '../../core/constants/app_constants.dart';
import '../models/user.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  AuthService({
    required Dio dio,
    required SharedPreferences prefs,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _prefs = prefs,
        _secureStorage = secureStorage {
    _dio.options.baseUrl = EnvConfig.urlBackend;
    _dio.options.connectTimeout = Duration(milliseconds: EnvConfig.apiTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: EnvConfig.apiTimeout);
  }

  // Email/Password Authentication
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.tokens != null) {
        await _storeTokens(authResponse.tokens!);
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        error: e.response?.data['message'] ?? 'Login failed. Please check your credentials.',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.tokens != null) {
        await _storeTokens(authResponse.tokens!);
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        error: e.response?.data['message'] ?? 'Registration failed. Please try again.',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  // Social Authentication
  Future<SocialAuthResult> googleLogin(String googleToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'token': googleToken},
      );

      final authResult = SocialAuthResult.fromJson(response.data);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error: e.response?.data['message'] ?? 'Google login failed. Please try again.',
      );
    } catch (e) {
      return SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<SocialAuthResult> facebookLogin(String facebookToken) async {
    try {
      final response = await _dio.post(
        '/auth/facebook',
        data: {'token': facebookToken},
      );

      final authResult = SocialAuthResult.fromJson(response.data);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error: e.response?.data['message'] ?? 'Facebook login failed. Please try again.',
      );
    } catch (e) {
      return SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  Future<SocialAuthResult> appleLogin(String appleToken) async {
    try {
      final response = await _dio.post(
        '/auth/apple',
        data: {'token': appleToken},
      );

      final authResult = SocialAuthResult.fromJson(response.data);

      if (authResult.success && authResult.tokens != null) {
        await _storeTokens(authResult.tokens!);
      }

      return authResult;
    } on DioException catch (e) {
      return SocialAuthResult(
        success: false,
        error: e.response?.data['message'] ?? 'Apple login failed. Please try again.',
      );
    } catch (e) {
      return SocialAuthResult(
        success: false,
        error: 'An unexpected error occurred.',
      );
    }
  }

  // Token Management
  Future<void> _storeTokens(AuthTokens tokens) async {
    await _secureStorage.write(
      key: AppConstants.keyAccessToken,
      value: tokens.accessToken,
    );
    await _secureStorage.write(
      key: AppConstants.keyRefreshToken,
      value: tokens.refreshToken,
    );
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      await _secureStorage.write(
        key: AppConstants.keyAccessToken,
        value: newAccessToken,
      );

      return newAccessToken;
    } catch (e) {
      await logout();
      return null;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.keyAccessToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
    await _prefs.remove(AppConstants.keyUser);
  }

  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  // Password Reset
  Future<bool> requestPasswordReset(String email) async {
    try {
      await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'password': newPassword,
        },
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Email Verification
  Future<bool> verifyEmail(String token) async {
    try {
      await _dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> resendVerificationEmail(String email) async {
    try {
      await _dio.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
