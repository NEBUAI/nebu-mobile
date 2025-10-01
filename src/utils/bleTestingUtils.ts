import { bluetoothService, BluetoothDevice } from '@/services/bluetoothService';

/**
 * Utilidades para testing de BLE
 */

// Dispositivos mock para testing
export const mockNebuDevices: BluetoothDevice[] = [
  {
    id: 'mock-nebu-001',
    name: 'NEBU-Robot-001',
    rssi: -45,
    isConnectable: true,
    address: '00:11:22:33:44:55',
    services: ['0000180A-0000-1000-8000-00805F9B34FB'],
    deviceInfo: {},
    isConnected: false,
    batteryLevel: 85,
  },
  {
    id: 'mock-nebu-002',
    name: 'NEBU-Robot-002',
    rssi: -65,
    isConnectable: true,
    address: '00:11:22:33:44:66',
    services: ['0000180A-0000-1000-8000-00805F9B34FB'],
    deviceInfo: {},
    isConnected: false,
    batteryLevel: 72,
  },
  {
    id: 'mock-nebu-003',
    name: 'NEBU-Robot-003',
    rssi: -80,
    isConnectable: true,
    address: '00:11:22:33:44:77',
    services: ['0000180A-0000-1000-8000-00805F9B34FB'],
    deviceInfo: {},
    isConnected: false,
    batteryLevel: 45,
  },
];

/**
 * Simular escaneo de dispositivos Nebu
 */
export const simulateBLEScan = async (): Promise<BluetoothDevice[]> => {
  console.log('🔵 Simulating BLE scan for Nebu devices...');
  
  // Simular tiempo de escaneo
  await new Promise(resolve => setTimeout(resolve, 2000));
  
  // Retornar dispositivos mock
  return mockNebuDevices;
};

/**
 * Simular conexión a dispositivo Nebu
 */
export const simulateBLEConnection = async (device: BluetoothDevice): Promise<boolean> => {
  console.log(`🔵 Simulating BLE connection to ${device.name}...`);
  
  // Simular tiempo de conexión
  await new Promise(resolve => setTimeout(resolve, 1500));
  
  // Simular conexión exitosa
  return true;
};

/**
 * Simular configuración WiFi via BLE
 */
export const simulateWiFiConfiguration = async (ssid: string, password: string): Promise<boolean> => {
  console.log(`🔵 Simulating WiFi configuration: ${ssid}...`);
  
  // Simular tiempo de configuración
  await new Promise(resolve => setTimeout(resolve, 3000));
  
  // Simular configuración exitosa (90% success rate)
  const success = Math.random() > 0.1;
  
  if (success) {
    console.log(' WiFi configuration successful');
  } else {
    console.log(' WiFi configuration failed');
  }
  
  return success;
};

/**
 * Simular obtención de estado del robot
 */
export const simulateRobotStatus = async (): Promise<any> => {
  console.log('🔵 Simulating robot status check...');
  
  // Simular tiempo de lectura
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // Simular estado del robot
  return {
    connected: true,
    batteryLevel: Math.floor(Math.random() * 40) + 60, // 60-100%
    wifiConnected: Math.random() > 0.3, // 70% connected
    lastCommand: 'wifi_configured',
    timestamp: Date.now(),
    signalStrength: Math.floor(Math.random() * 30) + 70, // 70-100%
    firmwareVersion: '1.2.3',
    serialNumber: 'NEBU-001-2024',
  };
};

/**
 * Simular verificación de capacidades Nebu
 */
export const simulateNebuCapabilities = async (deviceId: string): Promise<boolean> => {
  console.log(`🔵 Simulating Nebu capabilities check for ${deviceId}...`);
  
  // Simular tiempo de verificación
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Simular verificación exitosa para dispositivos Nebu
  return deviceId.startsWith('mock-nebu-') || deviceId.startsWith('NEBU-');
};

/**
 * Test completo del flujo BLE
 */
export const runBLETest = async (): Promise<void> => {
  console.log(' Starting complete BLE test...');
  
  try {
    // 1. Escanear dispositivos
    console.log('\n1️⃣ Scanning for devices...');
    const devices = await simulateBLEScan();
    console.log(`Found ${devices.length} Nebu devices`);
    
    if (devices.length === 0) {
      console.log(' No devices found');
      return;
    }
    
    // 2. Conectar al primer dispositivo
    console.log('\n2️⃣ Connecting to device...');
    const connected = await simulateBLEConnection(devices[0]);
    
    if (!connected) {
      console.log(' Connection failed');
      return;
    }
    
    // 3. Verificar capacidades
    console.log('\n3️⃣ Verifying capabilities...');
    const hasCapabilities = await simulateNebuCapabilities(devices[0].id);
    
    if (!hasCapabilities) {
      console.log(' Device does not have required capabilities');
      return;
    }
    
    // 4. Configurar WiFi
    console.log('\n4️⃣ Configuring WiFi...');
    const wifiConfigured = await simulateWiFiConfiguration('Mi_WiFi', 'mi_contraseña');
    
    if (!wifiConfigured) {
      console.log(' WiFi configuration failed');
      return;
    }
    
    // 5. Verificar estado
    console.log('\n5️⃣ Checking robot status...');
    const status = await simulateRobotStatus();
    console.log('Robot status:', status);
    
    console.log('\n BLE test completed successfully!');
    
  } catch (error) {
    console.error(' BLE test failed:', error);
  }
};

/**
 * Utilidades para debugging BLE
 */
export const BLE_DEBUG = {
  logDeviceInfo: (device: BluetoothDevice) => {
    console.log(' Device Info:', {
      id: device.id,
      name: device.name,
      rssi: device.rssi,
      isConnectable: device.isConnectable,
      batteryLevel: device.batteryLevel,
    });
  },
  
  logConnectionStatus: () => {
    const status = bluetoothService.getConnectionStatus();
    console.log('🔗 Connection Status:', status);
  },
  
  logNebuServices: () => {
    const services = bluetoothService.getNebuServices();
    const characteristics = bluetoothService.getNebuCharacteristics();
    console.log('Nebu Services:', services);
    console.log('⚙️ Nebu Characteristics:', characteristics);
  },
  
  logBLEState: async () => {
    const isAvailable = await bluetoothService.isBluetoothAvailable();
    console.log('📶 BLE Available:', isAvailable);
  },
};

// Exportar todo para uso en testing
export default {
  mockNebuDevices,
  simulateBLEScan,
  simulateBLEConnection,
  simulateWiFiConfiguration,
  simulateRobotStatus,
  simulateNebuCapabilities,
  runBLETest,
  BLE_DEBUG,
};
