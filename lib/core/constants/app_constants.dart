// ============================================================================
// ARCHIVO LEGACY - DEPRECADO
// ============================================================================
// Este archivo se mantiene solo por compatibilidad con código existente.
// Para nuevo código, importar las clases específicas:
//
// - import 'package:nebu_mobile/core/constants/app_config.dart';
// - import 'package:nebu_mobile/core/constants/app_routes.dart';
// - import 'package:nebu_mobile/core/constants/ble_constants.dart';
// - import 'package:nebu_mobile/core/constants/storage_keys.dart';
//
// ============================================================================

// Exportar todas las nuevas clases separadas por dominio
export 'app_config.dart';
export 'app_routes.dart';
export 'ble_constants.dart';
export 'storage_keys.dart';

/// @deprecated Esta clase está deprecada. Usar las clases específicas en su lugar:
/// - [AppConfig] para configuración general
/// - [AppRoutes] para rutas (con type-safety)
/// - [BleConstants] para constantes BLE
/// - [StorageKeys] para claves de almacenamiento
@Deprecated('Use domain-specific constant classes instead')
class AppConstants {
  AppConstants._(); // Constructor privado

  // ============================================================================
  // APP INFO - Migrar a AppConfig
  // ============================================================================

  @Deprecated('Use AppConfig.appName')
  static const String appName = 'Nebu Mobile';

  @Deprecated('Use AppConfig.appVersion')
  static const String appVersion = '1.0.1';

  // ============================================================================
  // API - Migrar a AppConfig
  // ============================================================================

  @Deprecated('Use AppConfig.apiTimeout')
  static const Duration apiTimeout = Duration(seconds: 30);

  @Deprecated('Use AppConfig.maxRetries')
  static const int maxRetries = 3;

  // ============================================================================
  // STORAGE KEYS - Migrar a StorageKeys
  // ============================================================================

  @Deprecated('Use StorageKeys.secureAccessToken (secure storage)')
  static const String keyAccessToken = 'access_token';

  @Deprecated('Use StorageKeys.secureRefreshToken (secure storage)')
  static const String keyRefreshToken = 'refresh_token';

  @Deprecated('Use StorageKeys.user')
  static const String keyUser = 'user';

  @Deprecated('Use StorageKeys.language')
  static const String keyLanguage = 'language';

  @Deprecated('Use StorageKeys.themeMode')
  static const String keyThemeMode = 'theme_mode';

  @Deprecated('Use StorageKeys.currentDeviceId')
  static const String keyCurrentDeviceId = 'current_device_id';

  // ============================================================================
  // LANGUAGES - Migrar a AppConfig
  // ============================================================================

  @Deprecated('Use AppConfig.languageEnglish')
  static const String languageEnglish = 'en';

  @Deprecated('Use AppConfig.languageSpanish')
  static const String languageSpanish = 'es';

  @Deprecated('Use AppConfig.supportedLanguages')
  static const List<String> supportedLanguages = ['en', 'es'];

  // ============================================================================
  // ROUTES - Migrar a AppRoutes (enum)
  // ============================================================================

  @Deprecated('Use AppRoutes.splash.path')
  static const String routeSplash = '/';

  @Deprecated('Use AppRoutes.welcome.path')
  static const String routeWelcome = '/welcome';

  @Deprecated('Use AppRoutes.login.path')
  static const String routeLogin = '/login';

  @Deprecated('Use AppRoutes.signUp.path')
  static const String routeSignUp = '/signup';

  @Deprecated('Use AppRoutes.home.path')
  static const String routeHome = '/home';

  @Deprecated('Use AppRoutes.profile.path')
  static const String routeProfile = '/profile';

  @Deprecated('Use AppRoutes.activityLog.path')
  static const String routeActivityLog = '/activity-log';

  @Deprecated('Use AppRoutes.myToys.path')
  static const String routeMyToys = '/my-toys';

  @Deprecated('Use AppRoutes.deviceManagement.path')
  static const String routeDeviceManagement = '/device-management';

  @Deprecated('Use AppRoutes.qrScanner.path')
  static const String routeQRScanner = '/qr-scanner';

  @Deprecated('Use AppRoutes.editProfile.path')
  static const String routeEditProfile = '/edit-profile';

  @Deprecated('Use AppRoutes.toySettings.path')
  static const String routeToySettings = '/toy-settings';

  @Deprecated('Use AppRoutes.notifications.path')
  static const String routeNotifications = '/notifications';

  @Deprecated('Use AppRoutes.privacySettings.path')
  static const String routePrivacySettings = '/privacy-settings';

  @Deprecated('Use AppRoutes.helpSupport.path')
  static const String routeHelpSupport = '/help-support';

  @Deprecated('Use AppRoutes.orders.path')
  static const String routeOrders = '/orders';

  @Deprecated('Use AppRoutes.connectionSetup.path')
  static const String routeConnectionSetup = '/setup/connection';

  @Deprecated('Use AppRoutes.toyNameSetup.path')
  static const String routeToyNameSetup = '/setup/toy-name';

  @Deprecated('Use AppRoutes.wifiSetup.path')
  static const String routeWifiSetup = '/setup/wifi';

  @Deprecated('Use AppRoutes.ageSetup.path')
  static const String routeAgeSetup = '/setup/age';

  @Deprecated('Use AppRoutes.personalitySetup.path')
  static const String routePersonalitySetup = '/setup/personality';

  @Deprecated('Use AppRoutes.voiceSetup.path')
  static const String routeVoiceSetup = '/setup/voice';

  @Deprecated('Use AppRoutes.favoritesSetup.path')
  static const String routeFavoritesSetup = '/setup/favorites';

  @Deprecated('Use AppRoutes.worldInfoSetup.path')
  static const String routeWorldInfoSetup = '/setup/world-info';

  // ============================================================================
  // BLUETOOTH - Migrar a BleConstants
  // ============================================================================

  @Deprecated('Use BleConstants.scanTimeout')
  static const Duration scanTimeout = Duration(seconds: 10);

  @Deprecated('Use BleConstants.connectionTimeout')
  static const Duration connectionTimeout = Duration(seconds: 15);

  @Deprecated('Use BleConstants.batteryServiceUuid')
  static const String batteryServiceUuid =
      '0000180f-0000-1000-8000-00805f9b34fb';

  @Deprecated('Use BleConstants.batteryLevelCharUuid')
  static const String batteryLevelCharUuid =
      '00002a19-0000-1000-8000-00805f9b34fb';

  @Deprecated('Use BleConstants.esp32WifiServiceUuid')
  static const String esp32WifiServiceUuid =
      '0000bc9a-7856-3412-3412-341278563412';

  @Deprecated('Use BleConstants.esp32SsidCharUuid')
  static const String esp32SsidCharUuid =
      '0000bd9a-7856-3412-3412-341278563412';

  @Deprecated('Use BleConstants.esp32PasswordCharUuid')
  static const String esp32PasswordCharUuid =
      '0000be9a-7856-3412-3412-341278563412';

  @Deprecated('Use BleConstants.esp32StatusCharUuid')
  static const String esp32StatusCharUuid =
      '0000bf9a-7856-3412-3412-341278563412';

  @Deprecated('Use BleConstants.esp32DeviceIdCharUuid')
  static const String esp32DeviceIdCharUuid =
      '0000c09a-7856-3412-3412-341278563412';

  // ============================================================================
  // ANIMATIONS - Migrar a AppConfig
  // ============================================================================

  @Deprecated('Use AppConfig.animationShort')
  static const Duration animationShort = Duration(milliseconds: 200);

  @Deprecated('Use AppConfig.animationMedium')
  static const Duration animationMedium = Duration(milliseconds: 300);

  @Deprecated('Use AppConfig.animationLong')
  static const Duration animationLong = Duration(milliseconds: 500);
}
