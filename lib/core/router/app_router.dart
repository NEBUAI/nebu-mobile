import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/toy.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/activity_log_screen.dart';
import '../../presentation/screens/child_profile_screen.dart';
import '../../presentation/screens/device_management_screen.dart';
import '../../presentation/screens/edit_profile_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/iot_devices_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/main_screen.dart';
import '../../presentation/screens/my_toys_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/qr_scanner_screen.dart';
import '../../presentation/screens/setup/age_setup_screen.dart';
import '../../presentation/screens/setup/connection_setup_screen.dart';
import '../../presentation/screens/setup/favorites_setup_screen.dart';
import '../../presentation/screens/setup/local_child_setup_screen.dart';
import '../../presentation/screens/setup/personality_setup_screen.dart';
import '../../presentation/screens/setup/toy_name_setup_screen.dart';
import '../../presentation/screens/setup/voice_setup_screen.dart';
import '../../presentation/screens/setup/wifi_setup_screen.dart';
import '../../presentation/screens/setup/world_info_setup_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/toy_settings_screen.dart';
import '../../presentation/screens/welcome_screen.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final AuthState authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash.path,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isSplash = state.matchedLocation == AppRoutes.splash.path;
      final isWelcome = state.matchedLocation == AppRoutes.welcome.path;
      final isLogin = state.matchedLocation == AppRoutes.login.path;
      final isSignUp = state.matchedLocation == AppRoutes.signUp.path;
      final isSetupRoute = state.matchedLocation.startsWith('/setup/');

      // Main app routes that can be accessed without authentication
      final isMainRoute =
          state.matchedLocation == AppRoutes.home.path ||
          state.matchedLocation == AppRoutes.activityLog.path ||
          state.matchedLocation == AppRoutes.myToys.path ||
          state.matchedLocation == AppRoutes.profile.path;

      // Allow access to main routes even without authentication (user can skip setup)
      if (!isAuthenticated &&
          !isWelcome &&
          !isSplash &&
          !isLogin &&
          !isSignUp &&
          !isSetupRoute &&
          !isMainRoute) {
        return AppRoutes.welcome.path;
      }

      // If authenticated and on welcome, redirect to home
      if (isAuthenticated && isWelcome) {
        return AppRoutes.home.path;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash.path,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Welcome Screen (unauthenticated)
      GoRoute(
        path: AppRoutes.welcome.path,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // Login Screen
      GoRoute(
        path: AppRoutes.login.path,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Sign Up Screen
      GoRoute(
        path: AppRoutes.signUp.path,
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main Screen with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // Home
          GoRoute(
            path: AppRoutes.home.path,
            name: 'home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),

          // Activity Log
          GoRoute(
            path: AppRoutes.activityLog.path,
            name: 'activity-log',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: ActivityLogScreen()),
          ),

          // My Toys
          GoRoute(
            path: AppRoutes.myToys.path,
            name: 'my-toys',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: MyToysScreen()),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile.path,
            name: 'profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Device Management (full screen)
      GoRoute(
        path: AppRoutes.deviceManagement.path,
        name: 'device-management',
        builder: (context, state) => const DeviceManagementScreen(),
      ),

      // IoT Devices (full screen)
      GoRoute(
        path: AppRoutes.iotDevices.path,
        name: 'iot-devices',
        builder: (context, state) => const IoTDevicesScreen(),
      ),

      // QR Scanner (full screen)
      GoRoute(
        path: AppRoutes.qrScanner.path,
        name: 'qr-scanner',
        builder: (context, state) => QRScannerScreen(),
      ),

      // Edit Profile (full screen)
      GoRoute(
        path: AppRoutes.editProfile.path,
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),

      // Toy Settings (full screen)
      GoRoute(
        path: AppRoutes.toySettings.path,
        name: 'toy-settings',
        builder: (context, state) {
          final toy = state.extra! as Toy;
          return ToySettingsScreen(toy: toy);
        },
      ),

      // Setup Flow Routes
      GoRoute(
        path: AppRoutes.connectionSetup.path,
        name: 'connection-setup',
        builder: (context, state) => const ConnectionSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.toyNameSetup.path,
        name: 'toy-name-setup',
        builder: (context, state) => const ToyNameSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.wifiSetup.path,
        name: 'wifi-setup',
        builder: (context, state) => const WifiSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.ageSetup.path,
        name: 'age-setup',
        builder: (context, state) => const AgeSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.personalitySetup.path,
        name: 'personality-setup',
        builder: (context, state) => const PersonalitySetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.voiceSetup.path,
        name: 'voice-setup',
        builder: (context, state) => const VoiceSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.favoritesSetup.path,
        name: 'favorites-setup',
        builder: (context, state) => const FavoritesSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.worldInfoSetup.path,
        name: 'world-info-setup',
        builder: (context, state) => const WorldInfoSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.localChildSetup.path,
        name: 'local-child-setup',
        builder: (context, state) => const LocalChildSetupScreen(),
      ),

      GoRoute(
        path: AppRoutes.childProfile.path,
        name: 'child-profile',
        builder: (context, state) => const ChildProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
});
