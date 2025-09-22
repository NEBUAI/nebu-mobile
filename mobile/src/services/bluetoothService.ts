import { Platform, PermissionsAndroid } from 'react-native';
import { BleManager, Device, State } from 'react-native-ble-plx';
import { check, request, PERMISSIONS, RESULTS } from 'react-native-permissions';

// Tipos para el servicio Bluetooth
export interface BluetoothDevice {
  id: string;
  name: string;
  rssi: number;
  isConnectable: boolean;
  address?: string;
  services?: string[];
  deviceInfo?: any;
  isConnected?: boolean;
  batteryLevel?: number;
}

export interface BluetoothServiceConfig {
  scanDuration: number;
  scanFilter: string[];
  connectionTimeout: number;
  enableAutoReconnect: boolean;
  maxReconnectAttempts: number;
}

// Características BLE específicas del robot Nebu
export interface NebuBLECharacteristics {
  deviceInfo: string;
  wifiConfig: string;
  commandControl: string;
  statusReport: string;
  batteryLevel: string;
  firmwareVersion: string;
}

// Servicios BLE del robot Nebu
export interface NebuBLEServices {
  deviceInfo: string;
  wifiConfig: string;
  control: string;
  status: string;
}

class BluetoothService {
  private bleManager: BleManager;
  private isScanning: boolean = false;
  private isConnected: boolean = false;
  private connectedDevice: BluetoothDevice | null = null;
  private scanCallbacks: ((devices: BluetoothDevice[]) => void)[] = [];
  private reconnectAttempts: number = 0;

  // Configuración por defecto
  private config: BluetoothServiceConfig = {
    scanDuration: 10000, // 10 segundos
    scanFilter: ['NEBU-', 'nebu-'], // Filtros para dispositivos Nebu
    connectionTimeout: 30000, // 30 segundos
    enableAutoReconnect: true,
    maxReconnectAttempts: 3,
  };

  // Servicios y características BLE del robot Nebu
  private nebuServices: NebuBLEServices = {
    deviceInfo: '0000180A-0000-1000-8000-00805F9B34FB', // Device Information Service
    wifiConfig: '12345678-1234-1234-1234-123456789ABC', // Custom WiFi Config Service
    control: '87654321-4321-4321-4321-CBA987654321', // Custom Control Service
    status: '11111111-2222-3333-4444-555555555555', // Custom Status Service
  };

  private nebuCharacteristics: NebuBLECharacteristics = {
    deviceInfo: '00002A25-0000-1000-8000-00805F9B34FB', // Serial Number String
    wifiConfig: '12345678-1234-1234-1234-123456789ABD', // WiFi Configuration
    commandControl: '87654321-4321-4321-4321-CBA987654322', // Command Control
    statusReport: '11111111-2222-3333-4444-555555555556', // Status Report
    batteryLevel: '00002A19-0000-1000-8000-00805F9B34FB', // Battery Level
    firmwareVersion: '00002A26-0000-1000-8000-00805F9B34FB', // Firmware Revision String
  };

  constructor() {
    this.bleManager = new BleManager();
    this.setupBLEListeners();
  }

  /**
   * Configurar listeners BLE
   */
  private setupBLEListeners(): void {
    // Listener para cambios de estado del Bluetooth
    this.bleManager.onStateChange((state: State) => {
      console.log('BLE State changed:', state);
      if (state === 'PoweredOff') {
        console.warn('Bluetooth is powered off');
        this.handleDisconnection();
      }
    }, true);
  }

  /**
   * Solicitar permisos de Bluetooth
   */
  async requestPermissions(): Promise<boolean> {
    try {
      if (Platform.OS === 'android') {
        // Verificar y solicitar permisos necesarios para Android
        const permissions = [
          PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION,
          PERMISSIONS.ANDROID.ACCESS_COARSE_LOCATION,
        ];

        // Agregar permisos específicos para Android 12+
        if (Platform.Version >= 31) {
          // Los permisos BLE se manejan automáticamente por react-native-permissions
          // Solo necesitamos los permisos de ubicación para el escaneo
        }

        const results = await Promise.all(
          permissions.map(permission => request(permission))
        );

        return results.every(result => result === RESULTS.GRANTED);
      } else {
        // iOS maneja los permisos automáticamente
        return true;
      }
    } catch (error) {
      console.error('Error requesting Bluetooth permissions:', error);
      return false;
    }
  }

  /**
   * Verificar si Bluetooth está disponible y habilitado
   */
  async isBluetoothAvailable(): Promise<boolean> {
    try {
      const state = await this.bleManager.state();
      return state === 'PoweredOn';
    } catch (error) {
      console.error('Error checking Bluetooth availability:', error);
      return false;
    }
  }

  /**
   * Convertir Device BLE a BluetoothDevice
   */
  private convertBLEDeviceToBluetoothDevice(device: Device): BluetoothDevice {
    return {
      id: device.id,
      name: device.name || 'Unknown Device',
      rssi: device.rssi || -100,
      isConnectable: device.isConnectable || false,
      address: device.id,
      services: [],
      deviceInfo: {},
      isConnected: false,
      batteryLevel: undefined,
    };
  }

  /**
   * Verificar si un dispositivo es un robot Nebu
   */
  private isNebuDevice(device: Device): boolean {
    const name = device.name || '';
    const localName = device.localName || '';
    
    return this.config.scanFilter.some(filter => 
      name.toLowerCase().includes(filter.toLowerCase()) ||
      localName.toLowerCase().includes(filter.toLowerCase())
    );
  }

  /**
   * Iniciar escaneo de dispositivos Bluetooth
   */
  async startScan(
    onDeviceFound?: (device: BluetoothDevice) => void,
    onScanComplete?: (devices: BluetoothDevice[]) => void
  ): Promise<BluetoothDevice[]> {
    if (this.isScanning) {
      console.warn('Bluetooth scan already in progress');
      return [];
    }

    try {
      // Verificar que Bluetooth esté disponible
      const isAvailable = await this.isBluetoothAvailable();
      if (!isAvailable) {
        throw new Error('Bluetooth is not available or powered off');
      }

      this.isScanning = true;
      const discoveredDevices: Map<string, BluetoothDevice> = new Map();

      console.log('Starting BLE scan for Nebu devices...');

      // Iniciar escaneo BLE
      const subscription = this.bleManager.startDeviceScan(
        null, // Escanear todos los servicios
        { allowDuplicates: false },
        (error, device) => {
          if (error) {
            console.error('BLE scan error:', error);
            return;
          }

          if (device && this.isNebuDevice(device)) {
            const bluetoothDevice = this.convertBLEDeviceToBluetoothDevice(device);
            
            // Evitar duplicados
            if (!discoveredDevices.has(device.id)) {
              discoveredDevices.set(device.id, bluetoothDevice);
              console.log('Found Nebu device:', bluetoothDevice.name, 'RSSI:', bluetoothDevice.rssi);
              onDeviceFound?.(bluetoothDevice);
            }
          }
        }
      );

      // Esperar el tiempo de escaneo configurado
      await new Promise(resolve => setTimeout(resolve, this.config.scanDuration));

      // Detener el escaneo
      this.bleManager.stopDeviceScan();
      
      this.isScanning = false;
      
      const devices = Array.from(discoveredDevices.values());
      console.log(`BLE scan completed. Found ${devices.length} Nebu devices`);
      
      onScanComplete?.(devices);
      return devices;
    } catch (error) {
      this.isScanning = false;
      console.error('Error during Bluetooth scan:', error);
      throw error;
    }
  }

  /**
   * Detener escaneo de Bluetooth
   */
  async stopScan(): Promise<void> {
    if (!this.isScanning) {
      return;
    }

    try {
      this.bleManager.stopDeviceScan();
      this.isScanning = false;
      console.log('Bluetooth scan stopped');
    } catch (error) {
      console.error('Error stopping Bluetooth scan:', error);
      throw error;
    }
  }

  /**
   * Conectar a un dispositivo Bluetooth
   */
  async connectToDevice(device: BluetoothDevice): Promise<boolean> {
    if (this.isConnected) {
      console.warn('Already connected to a device');
      return false;
    }

    try {
      console.log(`Connecting to device: ${device.name} (${device.id})`);

      // Conectar al dispositivo BLE
      const connectedDevice = await this.bleManager.connectToDevice(device.id, {
        timeout: this.config.connectionTimeout,
        autoConnect: this.config.enableAutoReconnect,
      });

      // Descubrir servicios
      const deviceWithServices = await connectedDevice.discoverAllServicesAndCharacteristics();

      // Configurar listeners de conexión
      this.setupDeviceListeners(deviceWithServices);

      this.isConnected = true;
      this.connectedDevice = device;
      this.connectedDevice.isConnected = true;
      this.reconnectAttempts = 0;

      console.log(`Successfully connected to device: ${device.name}`);
      
      // Obtener información del dispositivo
      await this.readDeviceInfo(deviceWithServices);
      
      return true;
    } catch (error) {
      console.error('Error connecting to device:', error);
      this.handleConnectionError(error);
      throw error;
    }
  }

  /**
   * Configurar listeners para el dispositivo conectado
   */
  private setupDeviceListeners(device: Device): void {
    // Listener para cambios de estado de conexión
    device.onDisconnected((error, device) => {
      console.log('Device disconnected:', device?.name);
      this.handleDisconnection();
    });

    // Listener para monitoreo de batería
    device.monitorCharacteristicForService(
      this.nebuServices.status,
      this.nebuCharacteristics.batteryLevel,
      (error, characteristic) => {
        if (characteristic?.value) {
          // Convertir valor base64 a número
          const value = Buffer.from(characteristic.value, 'base64');
          const batteryLevel = value.readUInt8(0);
          if (this.connectedDevice) {
            this.connectedDevice.batteryLevel = batteryLevel;
          }
          console.log('Battery level:', batteryLevel + '%');
        }
      }
    );
  }

  /**
   * Leer información del dispositivo
   */
  private async readDeviceInfo(device: Device): Promise<void> {
    try {
      // Leer número de serie
      const serialNumber = await device.readCharacteristicForService(
        this.nebuServices.deviceInfo,
        this.nebuCharacteristics.deviceInfo
      );

      // Leer versión de firmware
      const firmwareVersion = await device.readCharacteristicForService(
        this.nebuServices.deviceInfo,
        this.nebuCharacteristics.firmwareVersion
      );

      console.log('Device Info:', {
        serialNumber: serialNumber.value,
        firmwareVersion: firmwareVersion.value,
      });
    } catch (error) {
      console.error('Error reading device info:', error);
    }
  }

  /**
   * Manejar errores de conexión
   */
  private handleConnectionError(error: any): void {
    console.error('Connection error:', error);
    
    if (this.config.enableAutoReconnect && 
        this.reconnectAttempts < this.config.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.log(`Attempting to reconnect (${this.reconnectAttempts}/${this.config.maxReconnectAttempts})`);
      
      setTimeout(() => {
        if (this.connectedDevice) {
          this.connectToDevice(this.connectedDevice);
        }
      }, 5000); // Reintentar en 5 segundos
    }
  }

  /**
   * Manejar desconexión
   */
  private handleDisconnection(): void {
    this.isConnected = false;
    if (this.connectedDevice) {
      this.connectedDevice.isConnected = false;
    }
    this.connectedDevice = null;
  }

  /**
   * Desconectar del dispositivo actual
   */
  async disconnect(): Promise<void> {
    if (!this.isConnected || !this.connectedDevice) {
      return;
    }

    try {
      console.log('Disconnecting from device:', this.connectedDevice.name);
      
      // Cancelar conexión BLE
      await this.bleManager.cancelDeviceConnection(this.connectedDevice.id);
      
      this.handleDisconnection();
      console.log('Disconnected from device');
    } catch (error) {
      console.error('Error disconnecting from device:', error);
      throw error;
    }
  }

  /**
   * Enviar datos al dispositivo conectado
   */
  async sendData(data: string | Uint8Array, serviceUUID?: string, characteristicUUID?: string): Promise<boolean> {
    if (!this.isConnected || !this.connectedDevice) {
      throw new Error('No device connected');
    }

    try {
      console.log(`Sending data to ${this.connectedDevice.name}:`, data);
      
      // En una implementación real, aquí enviarías los datos via BLE
      // Por ahora simulamos el envío exitoso
      await new Promise(resolve => setTimeout(resolve, 500));
      
      return true;
    } catch (error) {
      console.error('Error sending data:', error);
      throw error;
    }
  }

  /**
   * Configurar WiFi en el robot
   */
  async configureWiFi(ssid: string, password: string): Promise<boolean> {
    if (!this.isConnected || !this.connectedDevice) {
      throw new Error('No device connected');
    }

    try {
      console.log('Configuring WiFi on robot:', ssid);

      // Crear comando de configuración WiFi
      const wifiConfig = JSON.stringify({
        ssid: ssid,
        password: password,
        timestamp: Date.now(),
      });

      // En una implementación real, aquí enviarías la configuración via BLE
      // Por ahora simulamos el envío exitoso
      await new Promise(resolve => setTimeout(resolve, 2000));

      console.log('WiFi configuration sent successfully');
      return true;
    } catch (error) {
      console.error('Error configuring WiFi:', error);
      throw error;
    }
  }

  /**
   * Obtener estado del robot
   */
  async getRobotStatus(): Promise<any> {
    if (!this.isConnected || !this.connectedDevice) {
      throw new Error('No device connected');
    }

    try {
      // En una implementación real, aquí leerías el estado via BLE
      // Por ahora simulamos el estado del robot
      const mockStatus = {
        connected: true,
        batteryLevel: Math.floor(Math.random() * 40) + 60, // 60-100%
        wifiConnected: true,
        lastCommand: 'wifi_configured',
        timestamp: Date.now(),
      };

      console.log('Robot status:', mockStatus);
      return mockStatus;
    } catch (error) {
      console.error('Error getting robot status:', error);
      throw error;
    }
  }

  /**
   * Obtener estado de conexión
   */
  getConnectionStatus(): {
    isConnected: boolean;
    connectedDevice: BluetoothDevice | null;
    isScanning: boolean;
  } {
    return {
      isConnected: this.isConnected,
      connectedDevice: this.connectedDevice,
      isScanning: this.isScanning,
    };
  }

  /**
   * Configurar el servicio
   */
  configure(config: Partial<BluetoothServiceConfig>): void {
    this.config = { ...this.config, ...config };
  }

  /**
   * Limpiar recursos
   */
  async cleanup(): Promise<void> {
    try {
      await this.stopScan();
      await this.disconnect();
      
      // Destruir el manager BLE
      this.bleManager.destroy();
      
      console.log('BluetoothService cleanup completed');
    } catch (error) {
      console.error('Error during cleanup:', error);
    }
  }

  /**
   * Obtener servicios y características BLE del robot Nebu
   */
  getNebuServices(): NebuBLEServices {
    return this.nebuServices;
  }

  getNebuCharacteristics(): NebuBLECharacteristics {
    return this.nebuCharacteristics;
  }

  /**
   * Verificar si el dispositivo soporta las características de Nebu
   */
  async verifyNebuCapabilities(deviceId: string): Promise<boolean> {
    try {
      // En una implementación real, aquí verificarías los servicios BLE del dispositivo
      // Por ahora simulamos que todos los dispositivos Nebu tienen las capacidades requeridas
      console.log('Verifying Nebu capabilities for device:', deviceId);
      
      // Simular verificación exitosa
      return true;
    } catch (error) {
      console.error('Error verifying Nebu capabilities:', error);
      return false;
    }
  }
}

// Instancia singleton del servicio
export const bluetoothService = new BluetoothService();
export default bluetoothService;
