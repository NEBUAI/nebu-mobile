import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_provider.dart';

/// Provider que escucha los cambios de conexión Bluetooth
/// y registra actividades automáticamente
final bluetoothConnectionListenerProvider = Provider<void>((ref) {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  // final activityTracker = ref.watch(activityTrackerServiceProvider);
  final logger = ref.watch(loggerProvider);

  // Escuchar el stream de estado de conexión
  bluetoothService.connectionState.listen((connectionState) {
    logger.d('🔵 [BT_LISTENER] Connection state changed: $connectionState');

    // TODO: Cuando tengamos el toy conectado, registrar la actividad
    // Por ahora solo logueamos el estado
    if (connectionState == fbp.BluetoothConnectionState.connected) {
      logger.i('🔵 [BT_LISTENER] Device connected - ready to track activity');
      // activityTracker.trackToyConnection(toy);
    } else if (connectionState == fbp.BluetoothConnectionState.disconnected) {
      logger.i(
        '🔵 [BT_LISTENER] Device disconnected - ready to track activity',
      );
      // activityTracker.trackToyDisconnection(toy);
    }
  });

  return;
});
