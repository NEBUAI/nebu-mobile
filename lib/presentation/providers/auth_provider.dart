import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/user.dart';
import 'api_provider.dart';

// Re-export sharedPreferencesProvider for use in other files
export 'api_provider.dart' show sharedPreferencesProvider;

// Auth provider using AsyncNotifier for cleaner state management
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    // On startup, check if the user is already authenticated and load user data
    return _loadUserFromStorage();
  }

  Future<User?> _loadUserFromStorage() async {
    try {
      final authService = await ref.watch(authServiceProvider.future);
      final prefs = await ref.watch(sharedPreferencesProvider.future);

      final isAuthenticated = await authService.isAuthenticated();
      if (isAuthenticated) {
        final userJson = prefs.getString(StorageKeys.user);
        if (userJson != null) {
          return User.fromJson(json.decode(userJson) as Map<String, dynamic>);
        }
      }
    } catch (e, st) {
      // If loading fails, treat as unauthenticated
      ref.read(loggerProvider).e('Failed to load user from storage', error: e, stackTrace: st);
    }
    return null;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(StorageKeys.user, json.encode(user.toJson()));
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authService.login(email: email, password: password);
      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        return response.user;
      }
      throw Exception(response.error ?? 'Login failed');
    });
  }

  Future<void> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        return response.user;
      }
      throw Exception(response.error ?? 'Registration failed');
    });
  }

  Future<void> loginWithGoogle(String googleToken) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authService.googleLogin(googleToken);
      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        return response.user;
      }
      throw Exception(response.error ?? 'Google login failed');
    });
  }

  Future<void> loginWithFacebook(String facebookToken) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authService.facebookLogin(facebookToken);
      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        return response.user;
      }
      throw Exception(response.error ?? 'Facebook login failed');
    });
  }

  Future<void> loginWithApple(String appleToken) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authService.appleLogin(appleToken);
      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        return response.user;
      }
      throw Exception(response.error ?? 'Apple login failed');
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final authService = await ref.read(authServiceProvider.future);
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await authService.logout();
      await prefs.remove(StorageKeys.user);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(User user) async {
    await _saveUser(user);
    state = AsyncValue.data(user);
  }
}