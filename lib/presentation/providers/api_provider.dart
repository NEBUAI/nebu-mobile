import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_service.dart';
import '../../data/services/toy_service.dart';
import '../../data/services/user_service.dart';

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
