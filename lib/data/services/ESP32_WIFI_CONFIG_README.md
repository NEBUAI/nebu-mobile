# ESP32 WiFi Configuration Service

Servicio para configurar credenciales WiFi en dispositivos ESP32 a través de Bluetooth Low Energy (BLE).

## Protocolo BLE

El servicio utiliza el siguiente protocolo BLE para comunicarse con el ESP32:

### Service UUID
- **WiFi Configuration Service**: `12345678-1234-1234-1234-123456789abc`

### Characteristics UUIDs
- **SSID**: `12345678-1234-1234-1234-123456789abd` (Write)
- **Password**: `12345678-1234-1234-1234-123456789abe` (Write)
- **Status**: `12345678-1234-1234-1234-123456789abf` (Read/Notify)

### Estados de Conexión WiFi

```dart
enum ESP32WifiStatus {
  idle(0),        // Esperando configuración
  connecting(1),  // Conectando a WiFi
  connected(2),   // Conectado exitosamente
  failed(3)       // Fallo en la conexión
}
```

## Flujo de Uso

### 1. Inicializar los servicios

```dart
final logger = Logger();
final bluetoothService = BluetoothService(logger: logger);
final esp32Service = ESP32WifiConfigService(
  bluetoothService: bluetoothService,
  logger: logger,
);
```

### 2. Escanear dispositivos ESP32

```dart
// Buscar dispositivos ESP32 con servicio de configuración WiFi
final esp32Devices = await esp32Service.scanForESP32Devices(
  timeout: Duration(seconds: 10),
);

if (esp32Devices.isEmpty) {
  print('No ESP32 devices found');
  return;
}

// Mostrar dispositivos encontrados
for (final device in esp32Devices) {
  print('Found: ${device.platformName} - ${device.remoteId}');
}
```

### 3. Conectar a un ESP32

```dart
// Seleccionar el primer dispositivo (o el que el usuario elija)
final selectedDevice = esp32Devices.first;

// Conectar al ESP32
await esp32Service.connectToESP32(selectedDevice);
```

### 4. Suscribirse a actualizaciones de estado

```dart
// Escuchar cambios de estado en tiempo real
esp32Service.statusStream.listen((status) {
  switch (status) {
    case ESP32WifiStatus.idle:
      print('ESP32 en espera...');
      break;
    case ESP32WifiStatus.connecting:
      print('ESP32 conectando a WiFi...');
      break;
    case ESP32WifiStatus.connected:
      print('¡ESP32 conectado a WiFi exitosamente!');
      break;
    case ESP32WifiStatus.failed:
      print('Error: El ESP32 no pudo conectarse al WiFi');
      break;
  }
});
```

### 5. Enviar credenciales WiFi

```dart
// Enviar SSID y contraseña al ESP32
final result = await esp32Service.sendWifiCredentials(
  ssid: 'Mi_WiFi_Casa',
  password: 'mi_password_123',
);

if (result.success) {
  print('Credenciales enviadas correctamente');
} else {
  print('Error: ${result.message}');
}
```

### 6. Leer el estado actual (opcional)

```dart
// Leer el estado actual sin esperar notificaciones
final currentStatus = await esp32Service.readWifiStatus();
print('Estado actual: $currentStatus');
```

### 7. Desconectar

```dart
// Desconectar del ESP32 cuando termines
await esp32Service.disconnect();

// Limpiar recursos al final
esp32Service.dispose();
```

## Ejemplo Completo

```dart
import 'package:logger/logger.dart';
import 'package:nebu_mobile/data/services/bluetooth_service.dart';
import 'package:nebu_mobile/data/services/esp32_wifi_config_service.dart';

Future<void> configureESP32Wifi() async {
  final logger = Logger();
  final bluetoothService = BluetoothService(logger: logger);
  final esp32Service = ESP32WifiConfigService(
    bluetoothService: bluetoothService,
    logger: logger,
  );

  try {
    // 1. Escanear dispositivos ESP32
    print('Escaneando dispositivos ESP32...');
    final devices = await esp32Service.scanForESP32Devices();

    if (devices.isEmpty) {
      print('No se encontraron dispositivos ESP32');
      return;
    }

    print('Encontrados ${devices.length} dispositivos ESP32');

    // 2. Conectar al primer dispositivo
    final device = devices.first;
    print('Conectando a ${device.platformName}...');
    await esp32Service.connectToESP32(device);

    // 3. Suscribirse a actualizaciones de estado
    esp32Service.statusStream.listen((status) {
      print('Estado WiFi del ESP32: $status');
    });

    // 4. Enviar credenciales WiFi
    print('Enviando credenciales WiFi...');
    final result = await esp32Service.sendWifiCredentials(
      ssid: 'Mi_Red_WiFi',
      password: 'mi_contraseña_segura',
    );

    if (result.success) {
      print('✓ Credenciales enviadas exitosamente');

      // 5. Esperar a que se conecte
      await Future.delayed(Duration(seconds: 5));

      // 6. Verificar estado final
      final status = await esp32Service.readWifiStatus();

      if (status == ESP32WifiStatus.connected) {
        print('✓ ¡ESP32 conectado a WiFi!');
      } else if (status == ESP32WifiStatus.failed) {
        print('✗ Error: El ESP32 no pudo conectarse');
      }
    } else {
      print('✗ Error enviando credenciales: ${result.message}');
    }

  } catch (e) {
    print('Error: $e');
  } finally {
    // 7. Limpiar recursos
    await esp32Service.disconnect();
    esp32Service.dispose();
  }
}
```

## Manejo de Errores

### Error: No se encuentran dispositivos ESP32

**Posibles causas:**
- Bluetooth no está activado en el dispositivo móvil
- El ESP32 no está encendido o no está en modo de configuración
- El ESP32 está fuera de rango
- Permisos de Bluetooth no están otorgados

**Solución:**
```dart
// Verificar permisos antes de escanear
final hasPermissions = await bluetoothService.requestPermissions();
if (!hasPermissions) {
  print('Permisos de Bluetooth no otorgados');
  return;
}

// Verificar que Bluetooth esté disponible
final isAvailable = await bluetoothService.isBluetoothAvailable();
if (!isAvailable) {
  print('Bluetooth no está disponible o no está activado');
  return;
}
```

### Error: Características no encontradas

**Posible causa:**
- El dispositivo ESP32 no tiene el firmware correcto con el servicio de configuración WiFi

**Solución:**
- Verificar que el ESP32 esté ejecutando el firmware correcto
- Revisar que los UUIDs del servicio y características coincidan

### Error: Tiempo de espera agotado

**Posibles causas:**
- El ESP32 está tardando mucho en responder
- Problemas de conexión Bluetooth

**Solución:**
```dart
// Aumentar el timeout de conexión si es necesario
await esp32Service.scanForESP32Devices(
  timeout: Duration(seconds: 20), // Aumentar timeout
);
```

## Integración con Flutter UI

### Ejemplo de pantalla de configuración

```dart
class ESP32WifiSetupScreen extends StatefulWidget {
  @override
  _ESP32WifiSetupScreenState createState() => _ESP32WifiSetupScreenState();
}

class _ESP32WifiSetupScreenState extends State<ESP32WifiSetupScreen> {
  final _esp32Service = GetIt.I<ESP32WifiConfigService>();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  ESP32WifiStatus _status = ESP32WifiStatus.idle;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanDevices();
    _listenToStatus();
  }

  Future<void> _scanDevices() async {
    final devices = await _esp32Service.scanForESP32Devices();
    setState(() {
      _devices = devices;
    });
  }

  void _listenToStatus() {
    _esp32Service.statusStream.listen((status) {
      setState(() {
        _status = status;
      });
    });
  }

  Future<void> _sendCredentials() async {
    if (_selectedDevice == null) return;

    await _esp32Service.connectToESP32(_selectedDevice!);

    final result = await _esp32Service.sendWifiCredentials(
      ssid: _ssidController.text,
      password: _passwordController.text,
    );

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenciales enviadas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar ESP32')),
      body: Column(
        children: [
          // Lista de dispositivos ESP32
          DropdownButton<BluetoothDevice>(
            value: _selectedDevice,
            items: _devices.map((device) {
              return DropdownMenuItem(
                value: device,
                child: Text(device.platformName),
              );
            }).toList(),
            onChanged: (device) {
              setState(() {
                _selectedDevice = device;
              });
            },
          ),

          // Campos de SSID y contraseña
          TextField(
            controller: _ssidController,
            decoration: InputDecoration(labelText: 'SSID'),
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),

          // Botón para enviar credenciales
          ElevatedButton(
            onPressed: _sendCredentials,
            child: Text('Configurar WiFi'),
          ),

          // Indicador de estado
          Text('Estado: $_status'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

## Notas Importantes

1. **Seguridad**: Las credenciales WiFi se transmiten sin cifrado adicional. En producción, considera implementar cifrado en la capa de aplicación.

2. **Timeouts**: Los timeouts por defecto son suficientes para la mayoría de casos, pero pueden ajustarse según necesidades específicas.

3. **Múltiples dispositivos**: El servicio solo puede estar conectado a un ESP32 a la vez. Desconecta antes de conectar a otro dispositivo.

4. **Notificaciones**: El ESP32 debe soportar notificaciones BLE en la característica de estado para recibir actualizaciones en tiempo real.

5. **Permisos**: En Android 12+, asegúrate de solicitar `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` y `ACCESS_FINE_LOCATION`.
