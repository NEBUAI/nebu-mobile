import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/storage_keys.dart';
import '../../data/models/user.dart';
import '../../data/services/activity_migration_service.dart';
import 'api_provider.dart';

// Re-export sharedPreferencesProvider for use in other files
export 'api_provider.dart' show sharedPreferencesProvider;

// Auth provider using AsyncNotifier for cleaner state management
final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => _loadUserFromStorage();

  Future<User?> _loadUserFromStorage() async {
    try {
      final authService = await ref.watch(authServiceProvider.future);
      final prefs = await ref.watch(sharedPreferencesProvider.future);

      final isAuthenticated = await authService.isAuthenticated();
      if (isAuthenticated) {
        final userJson = prefs.getString(StorageKeys.user);
        if (userJson != null) {
          final user = User.fromJson(json.decode(userJson) as Map<String, dynamic>);
          ref.read(loggerProvider).d('👤 [AUTH] Loaded user from storage: ${user.toJson()}');
          ref.read(loggerProvider).d('👤 [AUTH] User.name getter returns: ${user.name}');
          return user;
        }
      }
    } on Exception catch (e, st) {
      // If loading fails, treat as unauthenticated
      ref
          .read(loggerProvider)
          .e('Failed to load user from storage', error: e, stackTrace: st);
    }
    return null;
  }

  Future<void> _saveUser(User user) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    ref.read(loggerProvider).d('💾 [AUTH] Saving user to storage: ${user.toJson()}');
    ref.read(loggerProvider).d('💾 [AUTH] User.name getter returns: ${user.name}');
    await prefs.setString(StorageKeys.user, json.encode(user.toJson()));
  }

  /// Migrate activities from local UUID to authenticated user
  /// This is called automatically after successful login/register
  Future<void> _migrateActivities(String newUserId) async {
    try {
      final migrationService = ref.read(activityMigrationServiceProvider);
      final migratedCount = await migrationService.migrateIfNeeded(newUserId);

      if (migratedCount != null && migratedCount > 0) {
        ref
            .read(loggerProvider)
            .i(
              '✅ [AUTH] Successfully migrated $migratedCount activities for user $newUserId',
            );
      }
    } on Exception catch (e) {
      // Log error but don't fail the login/register process
      ref
          .read(loggerProvider)
          .e(
            '⚠️ [AUTH] Failed to migrate activities, but authentication succeeded: $e',
          );
    }
  }

  Future<void> login({required String identifier, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = await ref.read(authServiceProvider.future);
      final response = await authService.login(
        identifier: identifier,
        password: password,
      );
      if (response.success && response.user != null) {
        await _saveUser(response.user!);

        // Migrate activities if needed
        await _migrateActivities(response.user!.id);

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

        // Migrate activities if needed
        await _migrateActivities(response.user!.id);

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

        // Migrate activities if needed
        await _migrateActivities(response.user!.id);

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

        // Migrate activities if needed
        await _migrateActivities(response.user!.id);

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

        // Migrate activities if needed
        await _migrateActivities(response.user!.id);

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
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(User user) async {
    await _saveUser(user);
    state = AsyncValue.data(user);
  }
}
