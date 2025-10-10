import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/utils/performance_optimizer.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar optimizaciones de rendimiento
  PerformanceOptimizer.configurePerformanceOptimizations();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
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
      colors: true,
      printEmojis: true,
    ),
  );

  // Initialize services
  ApiService(
    dio: dio,
    secureStorage: secureStorage,
    logger: logger,
  );

  final authService = AuthService(
    dio: dio,
    prefs: sharedPreferences,
    secureStorage: secureStorage,
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override providers with actual instances
        authProvider.overrideWith(
          (ref) => AuthNotifier(
            authService: authService,
            prefs: sharedPreferences,
          ),
        ),
        themeProvider.overrideWith(
          (ref) => ThemeNotifier(prefs: sharedPreferences),
        ),
        languageProvider.overrideWith(
          (ref) => LanguageNotifier(prefs: sharedPreferences),
        ),
      ],
      child: const NebuApp(),
    ),
  );
}

class NebuApp extends ConsumerWidget {
  const NebuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,

      // Router
      routerConfig: router,
    );
  }
}
