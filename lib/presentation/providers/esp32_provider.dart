import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/esp32_wifi_config_service.dart';

// Provider para el servicio de configuración WiFi del ESP32
// Este provider debe ser sobreescrito en main.dart
final esp32WifiConfigServiceProvider = Provider<ESP32WifiConfigService>((ref) {
  throw UnimplementedError('ESP32WifiConfigService must be overridden');
});
