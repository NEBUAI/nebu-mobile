// Tipos para el servicio WiFi
export interface WiFiNetwork {
  ssid: string;
  rssi: number;
  security: 'Open' | 'WPA' | 'WPA2' | 'WPA3' | 'WEP';
  frequency: number;
  isConnected?: boolean;
}

export interface WiFiCredentials {
  ssid: string;
  password: string;
}

export interface WiFiConnectionResult {
  success: boolean;
  message: string;
  connectedNetwork?: WiFiNetwork;
}

class WiFiService {
  private isScanning: boolean = false;
  private currentNetwork: WiFiNetwork | null = null;

  /**
   * Escanear redes WiFi disponibles
   */
  async scanNetworks(): Promise<WiFiNetwork[]> {
    if (this.isScanning) {
      console.warn('WiFi scan already in progress');
      return [];
    }

    try {
      this.isScanning = true;

      // Simular escaneo de redes WiFi
      const mockNetworks: WiFiNetwork[] = [
        {
          ssid: 'Mi Casa WiFi',
          rssi: -30,
          security: 'WPA2',
          frequency: 2400,
        },
        {
          ssid: 'Vecino WiFi',
          rssi: -60,
          security: 'WPA3',
          frequency: 5000,
        },
        {
          ssid: 'Café Internet',
          rssi: -70,
          security: 'Open',
          frequency: 2400,
        },
        {
          ssid: 'Oficina WiFi',
          rssi: -45,
          security: 'WPA2',
          frequency: 2400,
        },
        {
          ssid: 'NEBU-Setup',
          rssi: -35,
          security: 'Open',
          frequency: 2400,
        },
      ];

      // Simular tiempo de escaneo
      await new Promise(resolve => setTimeout(resolve, 2000));

      this.isScanning = false;
      
      // Ordenar por intensidad de señal (RSSI más alto = mejor señal)
      return mockNetworks.sort((a, b) => b.rssi - a.rssi);
    } catch (error) {
      this.isScanning = false;
      console.error('Error scanning WiFi networks:', error);
      throw error;
    }
  }

  /**
   * Conectar a una red WiFi
   */
  async connectToNetwork(credentials: WiFiCredentials): Promise<WiFiConnectionResult> {
    try {
      console.log(`Attempting to connect to WiFi: ${credentials.ssid}`);

      // Simular proceso de conexión
      await new Promise(resolve => setTimeout(resolve, 3000));

      // Simular diferentes resultados basados en las credenciales
      const connectionSuccess = this.simulateConnectionResult(credentials);

      if (connectionSuccess) {
        const connectedNetwork: WiFiNetwork = {
          ssid: credentials.ssid,
          rssi: -40,
          security: 'WPA2',
          frequency: 2400,
          isConnected: true,
        };

        this.currentNetwork = connectedNetwork;

        return {
          success: true,
          message: 'Successfully connected to WiFi network',
          connectedNetwork,
        };
      } else {
        return {
          success: false,
          message: 'Failed to connect to WiFi network. Please check your credentials.',
        };
      }
    } catch (error) {
      console.error('Error connecting to WiFi:', error);
      return {
        success: false,
        message: 'An error occurred while connecting to WiFi',
      };
    }
  }

  /**
   * Verificar conexión a internet
   */
  async checkInternetConnection(): Promise<boolean> {
    try {
      // Simular verificación de conexión a internet
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Simular 90% de éxito en la conexión
      return Math.random() > 0.1;
    } catch (error) {
      console.error('Error checking internet connection:', error);
      return false;
    }
  }

  /**
   * Obtener información de la red actual
   */
  getCurrentNetwork(): WiFiNetwork | null {
    return this.currentNetwork;
  }

  /**
   * Desconectar de la red actual
   */
  async disconnect(): Promise<void> {
    try {
      console.log('Disconnecting from current WiFi network');
      
      // Simular desconexión
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      this.currentNetwork = null;
      console.log('Disconnected from WiFi network');
    } catch (error) {
      console.error('Error disconnecting from WiFi:', error);
      throw error;
    }
  }

  /**
   * Validar credenciales WiFi
   */
  validateCredentials(credentials: WiFiCredentials): { isValid: boolean; message: string } {
    if (!credentials.ssid || credentials.ssid.trim().length === 0) {
      return {
        isValid: false,
        message: 'WiFi network name (SSID) is required',
      };
    }

    if (credentials.ssid.length < 2) {
      return {
        isValid: false,
        message: 'WiFi network name must be at least 2 characters long',
      };
    }

    if (credentials.ssid.length > 32) {
      return {
        isValid: false,
        message: 'WiFi network name cannot exceed 32 characters',
      };
    }

    // Validar contraseña si no es una red abierta
    if (credentials.password && credentials.password.length > 0) {
      if (credentials.password.length < 8) {
        return {
          isValid: false,
          message: 'WiFi password must be at least 8 characters long',
        };
      }

      if (credentials.password.length > 63) {
        return {
          isValid: false,
          message: 'WiFi password cannot exceed 63 characters',
        };
      }
    }

    return {
      isValid: true,
      message: 'Credentials are valid',
    };
  }

  /**
   * Obtener nivel de señal como texto
   */
  getSignalLevel(rssi: number): string {
    if (rssi >= -30) return 'Excellent';
    if (rssi >= -50) return 'Good';
    if (rssi >= -70) return 'Fair';
    if (rssi >= -80) return 'Weak';
    return 'Very Weak';
  }

  /**
   * Obtener ícono de seguridad para la red
   */
  getSecurityIcon(security: string): string {
    switch (security) {
      case 'Open':
        return '🔓';
      case 'WEP':
        return '🔒';
      case 'WPA':
        return '🔐';
      case 'WPA2':
        return '🔐';
      case 'WPA3':
        return '🔐';
      default:
        return '❓';
    }
  }

  /**
   * Simular resultado de conexión (para testing)
   */
  private simulateConnectionResult(credentials: WiFiCredentials): boolean {
    // Simular diferentes escenarios
    if (credentials.ssid.toLowerCase().includes('casa') || 
        credentials.ssid.toLowerCase().includes('home')) {
      return Math.random() > 0.1; // 90% success for home networks
    }
    
    if (credentials.ssid.toLowerCase().includes('oficina') || 
        credentials.ssid.toLowerCase().includes('office')) {
      return Math.random() > 0.2; // 80% success for office networks
    }
    
    if (credentials.ssid.toLowerCase().includes('cafe') || 
        credentials.ssid.toLowerCase().includes('public')) {
      return Math.random() > 0.3; // 70% success for public networks
    }
    
    // Redes con contraseñas muy simples fallan más
    if (credentials.password && credentials.password.length < 8) {
      return Math.random() > 0.5; // 50% success for weak passwords
    }
    
    // Por defecto, 85% de éxito
    return Math.random() > 0.15;
  }

  /**
   * Obtener estado del escaneo
   */
  getScanStatus(): { isScanning: boolean } {
    return {
      isScanning: this.isScanning,
    };
  }
}

// Instancia singleton del servicio
export const wifiService = new WiFiService();
export default wifiService;
