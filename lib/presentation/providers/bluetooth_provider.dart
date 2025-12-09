import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_provider.dart';

// Proveedor que devuelve la lista de dispositivos Bluetooth conectados actualmente.
final connectedDevicesProvider = FutureProvider<List<fbp.BluetoothDevice>>((
  ref,
) {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  return bluetoothService.getConnectedDevices();
});
