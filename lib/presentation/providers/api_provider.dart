import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/api_service.dart';
import '../../data/services/local_child_data_service.dart';
import '../../data/services/toy_service.dart';
import '../../data/services/user_service.dart';
import 'toy_provider.dart';

// This provider is meant to be overridden in the main.dart file
final apiServiceProvider = Provider<ApiService>((ref) {
  throw UnimplementedError();
});

// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  throw UnimplementedError();
});

// Toy service provider
final toyServiceProvider = Provider<ToyService>((ref) {
  throw UnimplementedError();
});

// Logger provider
final loggerProvider = Provider<Logger>((ref) {
  throw UnimplementedError();
});

// Toy provider instance
final toyProviderInstance = Provider<ToyProvider>((ref) {
  final ToyService toyService = ref.watch(toyServiceProvider);
  final Logger logger = ref.watch(loggerProvider);
  return ToyProvider(toyService: toyService, logger: logger);
});

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Local child data service provider
final localChildDataServiceProvider = Provider<LocalChildDataService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalChildDataService(prefs);
});
