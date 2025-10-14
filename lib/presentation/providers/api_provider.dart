import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/api_service.dart';

// This provider is meant to be overridden in the main.dart file
final apiServiceProvider = Provider<ApiService>((ref) {
  throw UnimplementedError();
});
