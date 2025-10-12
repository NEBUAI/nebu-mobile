import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';

// Providers
final authServiceProvider = Provider<AuthService>((ref) => throw UnimplementedError());
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// Auth state
class AuthState {

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
  });
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
  }) => AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
}

// Auth notifier
class AuthNotifier extends Notifier<AuthState> {
  late AuthService _authService;
  late SharedPreferences _prefs;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _prefs = ref.watch(sharedPreferencesProvider);
    Future.microtask(_loadUser);
    return AuthState(isLoading: true);
  }

  // Load user from storage
  Future<void> _loadUser() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      final userJson = _prefs.getString(AppConstants.keyUser);
      if (userJson != null) {
        final user = User.fromJson(json.decode(userJson) as Map<String, dynamic>);
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      }
    }
  }

  // Login with email/password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Register
  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Google login
  Future<bool> loginWithGoogle(String googleToken) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _authService.googleLogin(googleToken);

      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Google login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Facebook login
  Future<bool> loginWithFacebook(String facebookToken) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _authService.facebookLogin(facebookToken);

      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Facebook login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Apple login
  Future<bool> loginWithApple(String appleToken) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _authService.appleLogin(appleToken);

      if (response.success && response.user != null) {
        await _saveUser(response.user!);
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.error ?? 'Apple login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    await _prefs.remove(AppConstants.keyUser);
    state = AuthState();
  }

  // Save user to storage
  Future<void> _saveUser(User user) async {
    await _prefs.setString(
      AppConstants.keyUser,
      json.encode(user.toJson()),
    );
  }

  // Update user
  Future<void> updateUser(User user) async {
    await _saveUser(user);
    state = state.copyWith(user: user);
  }
}

// Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
