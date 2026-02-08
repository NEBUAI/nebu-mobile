import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/esp32_wifi_config_service.dart';

// Provider para el servicio de configuración WiFi del ESP32
// Este provider debe ser sobreescrito en main.dart
final esp32WifiConfigServiceProvider = Provider<ESP32WifiConfigService>((ref) {
  throw UnimplementedError('ESP32WifiConfigService must be overridden');
});

// Provider para el estado actual del volumen del ESP32
final esp32VolumeProvider = Provider<int?>((ref) {
  final service = ref.watch(esp32WifiConfigServiceProvider);
  return service.volume;
});

// Provider para el estado actual de mute del ESP32
final esp32MuteProvider = Provider<bool?>((ref) {
  final service = ref.watch(esp32WifiConfigServiceProvider);
  return service.isMuted;
});

// Provider para establecer el volumen del ESP32
final esp32SetVolumeProvider = Provider<Future<bool> Function(int)>((ref) {
  final service = ref.read(esp32WifiConfigServiceProvider);
  return (int volume) async => service.setVolume(volume);
});

// Provider para establecer el estado de mute del ESP32
final esp32SetMuteProvider = Provider<Future<bool> Function(bool)>((ref) {
  final service = ref.read(esp32WifiConfigServiceProvider);
  return (bool mute) async => service.setMute(mute);
});
