import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/activity_log_screen.dart';
import '../../presentation/screens/device_management_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/my_toys_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/qr_scanner_screen.dart';
import '../../presentation/screens/setup/age_setup_screen.dart';
import '../../presentation/screens/setup/connection_setup_screen.dart';
import '../../presentation/screens/setup/favorites_setup_screen.dart';
import '../../presentation/screens/setup/personality_setup_screen.dart';
import '../../presentation/screens/setup/toy_name_setup_screen.dart';
import '../../presentation/screens/setup/voice_setup_screen.dart';
import '../../presentation/screens/setup/world_info_setup_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/welcome_screen.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final AuthState authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isSplash = state.matchedLocation == AppConstants.routeSplash;
      final isWelcome = state.matchedLocation == AppConstants.routeWelcome;
      final isLogin = state.matchedLocation == AppConstants.routeLogin;
      final isSignUp = state.matchedLocation == AppConstants.routeSignUp;
      final isSetupRoute = state.matchedLocation.startsWith('/setup/');

      // Main app routes that can be accessed without authentication
      final isMainRoute = state.matchedLocation == AppConstants.routeHome ||
          state.matchedLocation == AppConstants.routeActivityLog ||
          state.matchedLocation == AppConstants.routeMyToys ||
          state.matchedLocation == AppConstants.routeProfile;

      // Allow access to main routes even without authentication (user can skip setup)
      if (!isAuthenticated && !isWelcome && !isSplash && !isLogin && !isSignUp && !isSetupRoute && !isMainRoute) {
        return AppConstants.routeWelcome;
      }

      // If authenticated and on welcome, redirect to home
      if (isAuthenticated && isWelcome) {
        return AppConstants.routeHome;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Screen (unauthenticated)
      GoRoute(
        path: AppConstants.routeWelcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Login Screen
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Sign Up Screen
      GoRoute(
        path: AppConstants.routeSignUp,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main Screen with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // Home
          GoRoute(
            path: AppConstants.routeHome,
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),

          // Activity Log
          GoRoute(
            path: AppConstants.routeActivityLog,
            name: 'activity-log',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ActivityLogScreen(),
            ),
          ),

          // My Toys
          GoRoute(
            path: AppConstants.routeMyToys,
            name: 'my-toys',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyToysScreen(),
            ),
          ),

          // Profile
          GoRoute(
            path: AppConstants.routeProfile,
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),

      // Device Management (full screen)
      GoRoute(
        path: AppConstants.routeDeviceManagement,
        name: 'device-management',
        builder: (context, state) => const DeviceManagementScreen(),
      ),

      // QR Scanner (full screen)
      GoRoute(
        path: AppConstants.routeQRScanner,
        name: 'qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),

      // Setup Flow Routes
      GoRoute(
        path: AppConstants.routeConnectionSetup,
        name: 'connection-setup',
        builder: (context, state) => const ConnectionSetupScreen(),
      ),

      GoRoute(
        path: AppConstants.routeToyNameSetup,
        name: 'toy-name-setup',
        builder: (context, state) => const ToyNameSetupScreen(),
      ),

      GoRoute(
        path: AppConstants.routeAgeSetup,
        name: 'age-setup',
        builder: (context, state) => const AgeSetupScreen(),
      ),

      GoRoute(
        path: AppConstants.routePersonalitySetup,
        name: 'personality-setup',
        builder: (context, state) => const PersonalitySetupScreen(),
      ),

      GoRoute(
        path: AppConstants.routeVoiceSetup,
        name: 'voice-setup',
        builder: (context, state) => const VoiceSetupScreen(),
      ),

      GoRoute(
        path: AppConstants.routeFavoritesSetup,
        name: 'favorites-setup',
        builder: (context, state) => const FavoritesSetupScreen(),
      ),

      GoRoute(
        path: AppConstants.routeWorldInfoSetup,
        name: 'world-info-setup',
        builder: (context, state) => const WorldInfoSetupScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
