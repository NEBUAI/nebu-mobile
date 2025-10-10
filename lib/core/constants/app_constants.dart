class AppConstants {
  // App Info
  static const String appName = 'Nebu Mobile';
  static const String appVersion = '1.0.0';

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';

  // Languages
  static const String languageEnglish = 'en';
  static const String languageSpanish = 'es';
  static const List<String> supportedLanguages = [
    languageEnglish,
    languageSpanish,
  ];

  // Routes (will be defined in go_router)
  static const String routeSplash = '/';
  static const String routeWelcome = '/welcome';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeVoiceAgent = '/voice-agent';
  static const String routeIoTDashboard = '/iot-dashboard';
  static const String routeDeviceManagement = '/device-management';
  static const String routeQRScanner = '/qr-scanner';

  // Setup Flow Routes
  static const String routeConnectionSetup = '/setup/connection';
  static const String routeToyNameSetup = '/setup/toy-name';
  static const String routeAgeSetup = '/setup/age';
  static const String routePersonalitySetup = '/setup/personality';
  static const String routeVoiceSetup = '/setup/voice';
  static const String routeFavoritesSetup = '/setup/favorites';
  static const String routeWorldInfoSetup = '/setup/world-info';

  // Bluetooth
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
}
