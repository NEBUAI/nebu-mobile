import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/bluetooth_service.dart';
import 'data/services/device_service.dart';
import 'data/services/esp32_wifi_config_service.dart';
import 'presentation/providers/api_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/bluetooth_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/setup/wifi_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load();
  } on Exception catch (e) {
    debugPrint('Error loading .env file: $e');
  }

  // Initialize dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  final dio = Dio();
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
    ),
  );

  // Initialize services
  final apiService = ApiService(
    dio: dio,
    secureStorage: secureStorage,
    logger: logger,
  );

  final authService = AuthService(
    dio: dio,
    prefs: sharedPreferences,
    secureStorage: secureStorage,
  );

  final bluetoothService = BluetoothService(logger: logger);

  final deviceService = DeviceService(
    bluetoothService: bluetoothService,
    logger: logger,
  );

  final esp32WifiConfigService = ESP32WifiConfigService(
    bluetoothService: bluetoothService,
    logger: logger,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ProviderScope(
        overrides: [
          // Override providers with actual instances
          apiServiceProvider.overrideWithValue(apiService),
          authServiceProvider.overrideWithValue(authService),
          bluetoothServiceProvider.overrideWithValue(bluetoothService),
          deviceServiceProvider.overrideWithValue(deviceService),
          esp32WifiConfigServiceProvider.overrideWithValue(esp32WifiConfigService),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          authProvider.overrideWith(AuthNotifier.new),
          themeProvider.overrideWith(ThemeNotifier.new),
          languageProvider.overrideWith(LanguageNotifier.new),
        ],
        child: const NebuApp(),
      ),
    ),
  );
}

class NebuApp extends ConsumerWidget {
  const NebuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeState themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,

      // Router
      routerConfig: router,
    );
  }
}
