import { apiService } from './api';

// Tipos para el servicio de token de dispositivo
export interface DeviceTokenRequest {
  device_id: string;
}

export interface DeviceTokenResponse {
  access_token: string;
  room_name: string;
  expires_in: number;
}

export interface DeviceTokenError {
  error: string;
}

class DeviceTokenService {
  private baseEndpoint = '/livekit/iot/token';

  /**
   * Solicitar token LiveKit para dispositivo ESP32
   */
  async requestDeviceToken(deviceId: string): Promise<DeviceTokenResponse> {
    try {
      console.log('Requesting device token for:', deviceId);

      // Validar formato del device_id
      if (!this.isValidDeviceId(deviceId)) {
        throw new Error('Invalid device ID format');
      }

      const response = await apiService.generateIoTToken(deviceId, `room_${deviceId}`);

      // Validar que la respuesta sea exitosa
      if (!response.success || !response.data) {
        throw new Error('Invalid response from server');
      }

      return {
        access_token: response.data.token,
        room_name: response.data.roomName,
        expires_in: 7200, // Default 2 hours
      };
    } catch (error: any) {
      console.error('Error requesting device token:', error);
      
      // Si el dispositivo no está vinculado (404)
      if (error.response?.status === 404) {
        throw new Error('Device not linked to any user');
      }
      
      // Si el formato del device_id es inválido
      if (error.message === 'Invalid device ID format') {
        throw error;
      }
      
      // Si la respuesta del servidor es inválida
      if (error.message === 'Invalid response from server') {
        throw error;
      }
      
      // Otros errores
      throw new Error('Failed to get device token. Please check your internet connection.');
    }
  }

  /**
   * Verificar si un dispositivo está vinculado a un usuario
   */
  async isDeviceLinked(deviceId: string): Promise<boolean> {
    try {
      await this.requestDeviceToken(deviceId);
      return true;
    } catch (error) {
      return false;
    }
  }

  /**
   * Obtener información del token (sin hacer la llamada real)
   */
  getTokenInfo(token: string): { roomName: string; expiresIn: number } | null {
    try {
      // Decodificar JWT para obtener información
      const payload = JSON.parse(atob(token.split('.')[1]));
      
      return {
        roomName: payload.room || 'unknown',
        expiresIn: payload.exp ? (payload.exp * 1000 - Date.now()) : 0,
      };
    } catch (error) {
      console.error('Error parsing token:', error);
      return null;
    }
  }

  /**
   * Validar formato de device_id
   */
  isValidDeviceId(deviceId: string): boolean {
    // Formato esperado: A1B2-C3D4 (8 caracteres + guión)
    const deviceIdPattern = /^[A-Z0-9]{4}-[A-Z0-9]{4}$/;
    return deviceIdPattern.test(deviceId);
  }

  /**
   * Generar device_id a partir de MAC address
   */
  generateDeviceIdFromMac(macAddress: string): string {
    // Convertir MAC address a formato device_id
    // Ejemplo: "AA:BB:CC:DD:EE:FF" -> "AABB-CCDD"
    const cleanMac = macAddress.replace(/:/g, '').toUpperCase();
    return `${cleanMac.substring(0, 4)}-${cleanMac.substring(4, 8)}`;
  }

  /**
   * Extraer device_id de QR code
   */
  extractDeviceIdFromQR(qrData: string): string | null {
    // Buscar patrones de device_id en el QR
    const patterns = [
      /^([A-Z0-9]{4}-[A-Z0-9]{4})$/, // Formato directo
      /device_id[=:]([A-Z0-9]{4}-[A-Z0-9]{4})/i, // Con prefijo
      /"device_id":"([A-Z0-9]{4}-[A-Z0-9]{4})"/, // JSON
    ];

    for (const pattern of patterns) {
      const match = qrData.match(pattern);
      if (match) {
        return match[1];
      }
    }

    return null;
  }

  /**
   * Obtener información del dispositivo desde el backend
   */
  async getDeviceInfo(deviceId: string): Promise<any> {
    try {
      console.log('Getting device info for:', deviceId);

      if (!this.isValidDeviceId(deviceId)) {
        throw new Error('Invalid device ID format');
      }

      const response = await apiService.getIoTDevice(deviceId);

      if (!response.success || !response.data) {
        throw new Error('Failed to get device information');
      }

      return response.data;
    } catch (error: any) {
      console.error('Error getting device info:', error);
      
      if (error.response?.status === 404) {
        throw new Error('Device not found');
      }
      
      throw new Error('Failed to get device information');
    }
  }

  /**
   * Vincular dispositivo a usuario (crear toy)
   */
  async linkDeviceToUser(deviceId: string, userId: string, toyName: string = 'My Toy'): Promise<boolean> {
    try {
      console.log('Linking device to user:', deviceId, userId);

      if (!this.isValidDeviceId(deviceId)) {
        throw new Error('Invalid device ID format');
      }

      // Crear el toy que vincula el dispositivo al usuario
      const response = await apiService.createToy({
        iotDeviceId: deviceId,
        userId: userId,
        name: toyName,
        status: 'inactive',
      });

      return response.success;
    } catch (error: any) {
      console.error('Error linking device to user:', error);
      throw new Error('Failed to link device to user');
    }
  }
}

// Instancia singleton del servicio
export const deviceTokenService = new DeviceTokenService();
export default deviceTokenService;

