import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_provider.dart';

// Proveedor para el nivel de batería de un dispositivo específico.
// Usamos .family para poder pasarle el dispositivo como parámetro.
final batteryLevelProvider = FutureProvider.family<int, fbp.BluetoothDevice>((
  ref,
  device,
) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.getBatteryLevel(device);
});
