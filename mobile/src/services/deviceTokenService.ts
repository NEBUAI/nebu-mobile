import { apiService } from './apiService';

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

      const request: DeviceTokenRequest = {
        device_id: deviceId,
      };

      const response = await apiService.post(this.baseEndpoint, request);
      
      return {
        access_token: response.data.access_token,
        room_name: response.data.room_name,
        expires_in: response.data.expires_in,
      };
    } catch (error: any) {
      console.error('Error requesting device token:', error);
      
      // Si el dispositivo no está vinculado (404)
      if (error.response?.status === 404) {
        throw new Error('Device not linked to any user');
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
}

// Instancia singleton del servicio
export const deviceTokenService = new DeviceTokenService();
export default deviceTokenService;

