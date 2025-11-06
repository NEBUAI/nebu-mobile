import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../data/services/api_service.dart';
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

// Toy provider instance (ChangeNotifier)
final toyProviderInstance = Provider<ToyProvider>((ref) {
  final toyService = ref.watch(toyServiceProvider);
  final logger = ref.watch(loggerProvider);
  return ToyProvider(toyService: toyService, logger: logger);
});
