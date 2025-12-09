import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../data/models/toy.dart';
import '../../data/models/user.dart';
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

// Router provider that exposes the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return AppRouter(authState).router;
});

class AppRouter {
  AppRouter(AsyncValue<User?> authState)
    : router = GoRouter(
        initialLocation: AppRoutes.splash.path,
        debugLogDiagnostics: true,
        redirect: (context, state) => _redirectLogic(authState, state),
        routes: _getRoutesStatic(),
        errorBuilder: (context, state) => Scaffold(
          body: Center(child: Text('Page not found: ${state.error?.message}')),
        ),
      );

  final GoRouter router;

  static String? _redirectLogic(
    AsyncValue<User?> authState,
    GoRouterState state,
  ) {
    final isAuthenticated = authState.value != null;
    final location = state.matchedLocation;

    // Allow splash screen to be shown only on initial load
    // If we're coming from login/signup, skip splash
    if (location == AppRoutes.splash.path) {
      // If auth state is loaded (not initial app startup), redirect appropriately
      if (!authState.isLoading) {
        return isAuthenticated ? AppRoutes.home.path : AppRoutes.welcome.path;
      }
      return null; // Allow splash on initial load
    }

    // Routes accessible only when not authenticated
    final unauthenticatedRoutes = [
      AppRoutes.welcome.path,
      AppRoutes.login.path,
      AppRoutes.signUp.path,
    ];

    if (isAuthenticated) {
      // If authenticated, redirect from unauthenticated-only routes directly to home
      // This will NOT go through splash
      if (unauthenticatedRoutes.contains(location)) {
        return AppRoutes.home.path;
      }
    } else {
      // For unauthenticated users, only a specific set of routes are allowed.
      // All other routes will redirect to the welcome screen.
      final allowedUnauthRoutes = [
        ...unauthenticatedRoutes,
        AppRoutes.home.path,
        AppRoutes.activityLog.path,
        AppRoutes.myToys.path,
        AppRoutes.profile.path,
      ];

      final isSetupRoute = location.startsWith('/setup');

      if (!allowedUnauthRoutes.contains(location) && !isSetupRoute) {
        return AppRoutes.welcome.path;
      }
    }

    return null; // No redirection needed
  }

  static List<RouteBase> _getRoutesStatic() => [
    GoRoute(
      path: AppRoutes.splash.path,
      builder: (_, _) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome.path,
      builder: (_, _) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login.path,
      builder: (_, _) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp.path,
      builder: (_, __) => const SignUpScreen(),
    ),

    // Main application shell
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home.path,
          pageBuilder: (_, _) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.activityLog.path,
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: ActivityLogScreen()),
        ),
        GoRoute(
          path: AppRoutes.myToys.path,
          pageBuilder: (_, _) => const NoTransitionPage(child: MyToysScreen()),
        ),
        GoRoute(
          path: AppRoutes.profile.path,
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),

    // Other top-level screens
    GoRoute(
      path: AppRoutes.deviceManagement.path,
      builder: (_, __) => const DeviceManagementScreen(),
    ),
    GoRoute(
      path: AppRoutes.iotDevices.path,
      builder: (_, __) => const IoTDevicesScreen(),
    ),
    GoRoute(
      path: AppRoutes.qrScanner.path,
      builder: (_, __) => QRScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.editProfile.path,
      builder: (_, __) => const EditProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.toySettings.path,
      builder: (context, state) {
        final toy = state.extra as Toy?;
        if (toy == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Toy data is missing or invalid.')),
          );
        }
        return ToySettingsScreen(toy: toy);
      },
    ),
    GoRoute(
      path: AppRoutes.childProfile.path,
      builder: (_, __) => const ChildProfileScreen(),
    ),

    // Setup flow
    ..._getSetupRoutesStatic(),
  ];

  static List<RouteBase> _getSetupRoutesStatic() => [
    GoRoute(
      path: AppRoutes.connectionSetup.path,
      builder: (_, __) => const ConnectionSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.toyNameSetup.path,
      builder: (_, __) => const ToyNameSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.wifiSetup.path,
      builder: (_, __) => const WifiSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.ageSetup.path,
      builder: (_, __) => const AgeSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.personalitySetup.path,
      builder: (_, _) => const PersonalitySetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.voiceSetup.path,
      builder: (_, _) => const VoiceSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.favoritesSetup.path,
      builder: (_, _) => const FavoritesSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.worldInfoSetup.path,
      builder: (_, _) => const WorldInfoSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.localChildSetup.path,
      builder: (_, _) => const LocalChildSetupScreen(),
    ),
  ];
}
