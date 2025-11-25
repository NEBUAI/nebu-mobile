class AppConstants {
  // App Info
  static const String appName = 'Nebu Mobile';
  static const String appVersion = '1.0.1';

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUser = 'user';
  static const String keyLanguage = 'language';
  static const String keyThemeMode = 'theme_mode';
  static const String keyCurrentDeviceId = 'current_device_id';

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
  static const String routeLogin = '/login';
  static const String routeSignUp = '/signup';
  static const String routeHome = '/home';
  static const String routeProfile = '/profile';
  static const String routeActivityLog = '/activity-log';
  static const String routeMyToys = '/my-toys';
  static const String routeDeviceManagement = '/device-management';
  static const String routeQRScanner = '/qr-scanner';
  static const String routeEditProfile = '/edit-profile';
  static const String routeToySettings = '/toy-settings';
  static const String routeNotifications = '/notifications';
  static const String routePrivacySettings = '/privacy-settings';
  static const String routeHelpSupport = '/help-support';
  static const String routeOrders = '/orders';

  // Setup Flow Routes
  static const String routeConnectionSetup = '/setup/connection';
  static const String routeToyNameSetup = '/setup/toy-name';
  static const String routeWifiSetup = '/setup/wifi';
  static const String routeAgeSetup = '/setup/age';
  static const String routePersonalitySetup = '/setup/personality';
  static const String routeVoiceSetup = '/setup/voice';
  static const String routeFavoritesSetup = '/setup/favorites';
  static const String routeWorldInfoSetup = '/setup/world-info';

  // Bluetooth
  static const Duration scanTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 15);

  // Standard BLE Services & Characteristics
  static const String batteryServiceUuid =
      '0000180f-0000-1000-8000-00805f9b34fb';
  static const String batteryLevelCharUuid =
      '00002a19-0000-1000-8000-00805f9b34fb';

  // ESP32 WiFi Configuration BLE Protocol
  // Service UUID: "ESP32-WiFi-Config"
  static const String esp32WifiServiceUuid =
      '0000bc9a-7856-3412-3412-3412-7856-3412';
  // SSID Characteristic (READ | WRITE_NO_RESPONSE)
  static const String esp32SsidCharUuid =
      '0000bd9a-7856-3412-3412-3412-7856-3412';
  // Password Characteristic (READ | WRITE_NO_RESPONSE)
  static const String esp32PasswordCharUuid =
      '0000be9a-7856-3412-3412-3412-7856-3412';
  // Status Characteristic (READ | NOTIFY) - Returns: IDLE, CONNECTING, CONNECTED, FAILED
  static const String esp32StatusCharUuid =
      '0000bf9a-7856-3412-3412-3412-7856-3412';
  // Device ID Characteristic (READ | NOTIFY) - Format: "ESP32_XXXXXXXXXXXX"
  static const String esp32DeviceIdCharUuid =
      '0000c09a-7856-3412-3412-3412-7856-3412';

  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);
}
