import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/activity_service.dart';
import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/bluetooth_service.dart';
import '../../data/services/device_service.dart';
import '../../data/services/esp32_wifi_config_service.dart';
import '../../data/services/iot_service.dart';
import '../../data/services/local_child_data_service.dart';
import '../../data/services/notification_service.dart';
import '../../data/services/order_service.dart';
import '../../data/services/toy_service.dart';
import '../../data/services/user_service.dart';
import '../../data/services/user_setup_service.dart';
import '../../data/services/voice_session_service.dart';

// Low-level dependency providers

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

final dioProvider = Provider<Dio>((ref) => Dio());

final loggerProvider = Provider<Logger>(
  (ref) => Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 3,
      lineLength: 80,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  ),
);

// Service providers

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  return ApiService(dio: dio, secureStorage: secureStorage, logger: logger);
});

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final dio = ref.watch(dioProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthService(dio: dio, prefs: prefs, secureStorage: secureStorage);
});

final bluetoothServiceProvider = Provider<BluetoothService>((ref) {
  final logger = ref.watch(loggerProvider);
  return BluetoothService(logger: logger);
});

final deviceServiceProvider = Provider<DeviceService>((ref) {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  final logger = ref.watch(loggerProvider);
  return DeviceService(bluetoothService: bluetoothService, logger: logger);
});

final esp32WifiConfigServiceProvider = FutureProvider<ESP32WifiConfigService>((
  ref,
) async {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  final logger = ref.watch(loggerProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return ESP32WifiConfigService(
    bluetoothService: bluetoothService,
    logger: logger,
    prefs: prefs,
  );
});

final userServiceProvider = Provider<UserService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return UserService(apiService: apiService, logger: logger);
});

final toyServiceProvider = Provider<ToyService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return ToyService(apiService: apiService, logger: logger);
});

final iotServiceProvider = Provider<IoTService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return IoTService(apiService: apiService, logger: logger);
});

final activityServiceProvider = Provider<ActivityService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return ActivityService(apiService: apiService, logger: logger);
});

final userSetupServiceProvider = Provider<UserSetupService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return UserSetupService(apiService: apiService, logger: logger);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return NotificationService(apiService: apiService, logger: logger);
});

final orderServiceProvider = Provider<OrderService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return OrderService(apiService: apiService, logger: logger);
});

final voiceSessionServiceProvider = Provider<VoiceSessionService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final logger = ref.watch(loggerProvider);
  return VoiceSessionService(apiService: apiService, logger: logger);
});

final localChildDataServiceProvider = FutureProvider<LocalChildDataService>((
  ref,
) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return LocalChildDataService(prefs);
});
