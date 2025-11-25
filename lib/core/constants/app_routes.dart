/// Rutas de navegación de la aplicación
///
/// Uso de enum para type-safety en lugar de strings mágicos.
/// Previene errores de typos y permite autocompletado en el IDE.
///
/// **Uso:**
/// ```dart
/// context.push(AppRoutes.home.path);
/// context.pushNamed(AppRoutes.profile.name);
/// ```
enum AppRoutes {
  // ============================================================================
  // RUTAS PRINCIPALES
  // ============================================================================

  /// Pantalla de splash inicial
  splash('/'),

  /// Pantalla de bienvenida (onboarding)
  welcome('/welcome'),

  /// Pantalla de inicio de sesión
  login('/login'),

  /// Pantalla de registro de usuario
  signUp('/signup'),

  /// Pantalla principal (home)
  home('/home'),

  /// Perfil del usuario
  profile('/profile'),

  /// Registro de actividad
  activityLog('/activity-log'),

  /// Mis juguetes
  myToys('/my-toys'),

  /// Gestión de dispositivos
  deviceManagement('/device-management'),

  /// Escáner QR
  qrScanner('/qr-scanner'),

  /// Editar perfil
  editProfile('/edit-profile'),

  /// Configuración del juguete
  toySettings('/toy-settings'),

  /// Notificaciones
  notifications('/notifications'),

  /// Configuración de privacidad
  privacySettings('/privacy-settings'),

  /// Ayuda y soporte
  helpSupport('/help-support'),

  /// Órdenes de compra
  orders('/orders'),

  // ============================================================================
  // FLUJO DE CONFIGURACIÓN (SETUP)
  // ============================================================================

  /// Paso 1: Configuración de conexión BLE
  connectionSetup('/setup/connection'),

  /// Paso 2: Configuración WiFi del ESP32
  wifiSetup('/setup/wifi'),

  /// Paso 3: Asignar nombre al juguete
  toyNameSetup('/setup/toy-name'),

  /// Paso 4: Configurar edad del niño
  ageSetup('/setup/age'),

  /// Paso 5: Configurar personalidad del juguete
  personalitySetup('/setup/personality'),

  /// Paso 6: Configurar voz del juguete
  voiceSetup('/setup/voice'),

  /// Paso 7: Configurar favoritos
  favoritesSetup('/setup/favorites'),

  /// Paso 8: Información del mundo del niño
  worldInfoSetup('/setup/world-info');

  const AppRoutes(this.path);

  /// Path de la ruta (usado para navegación)
  final String path;

  /// Obtener ruta por path
  static AppRoutes? fromPath(String path) {
    try {
      return AppRoutes.values.firstWhere((route) => route.path == path);
    } catch (_) {
      return null;
    }
  }

  /// Verificar si una ruta requiere autenticación
  bool get requiresAuth {
    switch (this) {
      case AppRoutes.splash:
      case AppRoutes.welcome:
      case AppRoutes.login:
      case AppRoutes.signUp:
        return false;
      default:
        return true;
    }
  }

  /// Verificar si una ruta es parte del flujo de setup
  bool get isSetupRoute => path.startsWith('/setup/');

  /// Verificar si es una ruta pública
  bool get isPublic => !requiresAuth;
}

/// Extensión para facilitar navegación con enums
extension AppRoutesNavigation on AppRoutes {
  /// Navegar a esta ruta
  String get route => path;

  /// Obtener nombre de la ruta (sin '/')
  String get routeName => path.replaceAll('/', '_').substring(1);
}

// ============================================================================
// CONSTANTES LEGACY (Deprecadas)
// ============================================================================

/// @deprecated Usar [AppRoutes] enum en su lugar
/// Migrar a enums para type-safety
class LegacyRoutes {
  LegacyRoutes._();

  @Deprecated('Use AppRoutes.splash.path instead')
  static const String routeSplash = '/';

  @Deprecated('Use AppRoutes.welcome.path instead')
  static const String routeWelcome = '/welcome';

  @Deprecated('Use AppRoutes.login.path instead')
  static const String routeLogin = '/login';

  @Deprecated('Use AppRoutes.signUp.path instead')
  static const String routeSignUp = '/signup';

  @Deprecated('Use AppRoutes.home.path instead')
  static const String routeHome = '/home';

  @Deprecated('Use AppRoutes.profile.path instead')
  static const String routeProfile = '/profile';

  @Deprecated('Use AppRoutes.activityLog.path instead')
  static const String routeActivityLog = '/activity-log';

  @Deprecated('Use AppRoutes.myToys.path instead')
  static const String routeMyToys = '/my-toys';

  @Deprecated('Use AppRoutes.deviceManagement.path instead')
  static const String routeDeviceManagement = '/device-management';

  @Deprecated('Use AppRoutes.qrScanner.path instead')
  static const String routeQRScanner = '/qr-scanner';

  @Deprecated('Use AppRoutes.editProfile.path instead')
  static const String routeEditProfile = '/edit-profile';

  @Deprecated('Use AppRoutes.toySettings.path instead')
  static const String routeToySettings = '/toy-settings';

  @Deprecated('Use AppRoutes.notifications.path instead')
  static const String routeNotifications = '/notifications';

  @Deprecated('Use AppRoutes.privacySettings.path instead')
  static const String routePrivacySettings = '/privacy-settings';

  @Deprecated('Use AppRoutes.helpSupport.path instead')
  static const String routeHelpSupport = '/help-support';

  @Deprecated('Use AppRoutes.orders.path instead')
  static const String routeOrders = '/orders';

  @Deprecated('Use AppRoutes.connectionSetup.path instead')
  static const String routeConnectionSetup = '/setup/connection';

  @Deprecated('Use AppRoutes.toyNameSetup.path instead')
  static const String routeToyNameSetup = '/setup/toy-name';

  @Deprecated('Use AppRoutes.wifiSetup.path instead')
  static const String routeWifiSetup = '/setup/wifi';

  @Deprecated('Use AppRoutes.ageSetup.path instead')
  static const String routeAgeSetup = '/setup/age';

  @Deprecated('Use AppRoutes.personalitySetup.path instead')
  static const String routePersonalitySetup = '/setup/personality';

  @Deprecated('Use AppRoutes.voiceSetup.path instead')
  static const String routeVoiceSetup = '/setup/voice';

  @Deprecated('Use AppRoutes.favoritesSetup.path instead')
  static const String routeFavoritesSetup = '/setup/favorites';

  @Deprecated('Use AppRoutes.worldInfoSetup.path instead')
  static const String routeWorldInfoSetup = '/setup/world-info';
}
