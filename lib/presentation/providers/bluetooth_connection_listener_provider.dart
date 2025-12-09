import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/toy.dart';
import '../../data/services/activity_tracker_service.dart';
import 'api_provider.dart';
import 'toy_provider.dart';

/// Provider que escucha los cambios de conexión Bluetooth
/// y registra actividades automáticamente
final bluetoothConnectionListenerProvider = Provider<void>((ref) {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  final activityTracker = ref.watch(activityTrackerServiceProvider);
  final logger = ref.watch(loggerProvider);

  // Escuchar el stream de estado de conexión
  bluetoothService.connectionState.listen((connectionState) {
    logger.d('🔵 [BT_LISTENER] Connection state changed: $connectionState');

    // Obtener toys del provider
    final toysAsync = ref.read(toyProvider);
    // Usar hasValue para evitar ProviderException si está en error
    final toys = toysAsync.hasValue ? toysAsync.value! : <Toy>[];
    final currentToy = toys.isNotEmpty ? toys.first : null;

    if (connectionState == fbp.BluetoothConnectionState.connected) {
      logger.i('🔵 [BT_LISTENER] Device connected - tracking activity');

      if (currentToy != null) {
        // Registrar actividad de conexión
        activityTracker.trackToyConnection(currentToy);
      } else {
        logger.w(
          '🔵 [BT_LISTENER] Connected but no current toy set - creating generic toy',
        );
        // Crear un toy genérico con la info del dispositivo BT
        final device = bluetoothService.connectedDevice;
        if (device != null) {
          final genericToy = Toy(
            id: device.remoteId.toString(),
            iotDeviceId: device.remoteId.toString(),
            name: device.platformName.isNotEmpty
                ? device.platformName
                : 'Unknown Device',
            userId: '', // Se obtendrá en el tracker
            model: 'BLE Device',
            manufacturer: 'Unknown',
            status: ToyStatus.active,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          activityTracker.trackToyConnection(genericToy);
        }
      }
    } else if (connectionState == fbp.BluetoothConnectionState.disconnected) {
      logger.i('🔵 [BT_LISTENER] Device disconnected - tracking activity');

      if (currentToy != null) {
        // Registrar actividad de desconexión
        activityTracker.trackToyDisconnection(currentToy);
      } else {
        logger.w('🔵 [BT_LISTENER] Disconnected but no current toy reference');
      }
    }
  });

  return;
});
