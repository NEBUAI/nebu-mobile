import AsyncStorage from '@react-native-async-storage/async-storage';

// Configuration
const API_BASE_URL = __DEV__ 
  ? 'http://localhost:3001/api/v1'  // Development
  : 'https://api.nebu.com/api/v1';  // Production

// Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}

export interface User {
  id: string;
  email: string;
  name: string;
  avatar?: string;
  createdAt: string;
  updatedAt: string;
}

export interface LoginRequest {
  email: string;
  password: string;
}

export interface VoiceAgentTokenRequest {
  userId: string;
  sessionId: string;
}

export interface IoTDevice {
  id: string;
  name: string;
  deviceType: 'sensor' | 'actuator' | 'camera' | 'microphone' | 'speaker' | 'controller';
  macAddress: string; // Obligatorio ahora
  ipAddress?: string;
  status: 'online' | 'offline' | 'error' | 'maintenance';
  location?: string;
  metadata?: Record<string, any>;
  userId?: string; // Opcional - dispositivos pueden no tener usuario
  roomName?: string; // Para LiveKit
  temperature?: number;
  humidity?: number;
  pressure?: number;
  batteryLevel?: number;
  signalStrength?: number;
  createdAt: string;
  updatedAt: string;
  lastSeen?: string;
  lastDataReceived?: string;
  // Helper methods results
  isOnline?: boolean;
  isRegistered?: boolean;
}

export interface Toy {
  id: string;
  iotDeviceId: string; // Relación obligatoria con IoTDevice
  userId: string; // Relación obligatoria con User
  name: string;
  model?: string;
  manufacturer?: string;
  status: 'inactive' | 'active' | 'connected' | 'disconnected' | 'maintenance' | 'error' | 'blocked';
  statusText: string;
  statusColor: string;
  firmwareVersion?: string;
  batteryLevel?: string;
  signalStrength?: string;
  lastSeenAt?: string;
  activatedAt?: string;
  capabilities?: {
    voice?: boolean;
    movement?: boolean;
    lights?: boolean;
    sensors?: string[];
    aiFeatures?: string[];
  };
  settings?: {
    volume?: number;
    brightness?: number;
    language?: string;
    timezone?: string;
    autoUpdate?: boolean;
  };
  notes?: string;
  createdAt: string;
  updatedAt: string;
  // Computed from relation
  macAddress: string; // Viene de iotDevice.macAddress
  // Helper methods results
  isActive: boolean;
  isConnected: boolean;
  needsAttention: boolean;
}

export interface CreateToyRequest {
  iotDeviceId: string; // ID del dispositivo IoT existente
  userId: string; // ID del usuario
  name: string;
  model?: string;
  manufacturer?: string;
  status?: 'inactive' | 'active' | 'connected' | 'disconnected' | 'maintenance' | 'error' | 'blocked';
  capabilities?: {
    voice?: boolean;
    movement?: boolean;
    lights?: boolean;
    sensors?: string[];
    aiFeatures?: string[];
  };
  settings?: {
    volume?: number;
    brightness?: number;
    language?: string;
    timezone?: string;
    autoUpdate?: boolean;
  };
  notes?: string;
}

class ApiService {
  private baseURL: string;
  private accessToken: string | null = null;

  constructor() {
    this.baseURL = API_BASE_URL;
    this.loadTokenFromStorage();
  }

  private async loadTokenFromStorage(): Promise<void> {
    try {
      const token = await AsyncStorage.getItem('accessToken');
      if (token) {
        this.accessToken = token;
      }
    } catch (error) {
      console.error('Error loading token from storage:', error);
    }
  }

  private async saveTokenToStorage(token: string): Promise<void> {
    try {
      await AsyncStorage.setItem('accessToken', token);
      this.accessToken = token;
    } catch (error) {
      console.error('Error saving token to storage:', error);
    }
  }

  private async removeTokenFromStorage(): Promise<void> {
    try {
      await AsyncStorage.removeItem('accessToken');
      await AsyncStorage.removeItem('refreshToken');
      this.accessToken = null;
    } catch (error) {
      console.error('Error removing token from storage:', error);
    }
  }

  private getHeaders(): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };

    if (this.accessToken) {
      headers.Authorization = `Bearer ${this.accessToken}`;
    }

    return headers;
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<ApiResponse<T>> {
    try {
      const url = `${this.baseURL}${endpoint}`;
      const response = await fetch(url, {
        ...options,
        headers: {
          ...this.getHeaders(),
          ...options.headers,
        },
      });

      const data = await response.json();

      if (!response.ok) {
        return {
          success: false,
          error: data.message || `HTTP ${response.status}`,
        };
      }

      return {
        success: true,
        data,
      };
    } catch (error) {
      console.error('API request error:', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Network error',
      };
    }
  }

  // Authentication
  async login(credentials: LoginRequest): Promise<ApiResponse<{ user: User; tokens: AuthTokens }>> {
    const response = await this.request<{ user: User; tokens: AuthTokens }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify(credentials),
    });

    if (response.success && response.data?.tokens) {
      await this.saveTokenToStorage(response.data.tokens.accessToken);
      await AsyncStorage.setItem('refreshToken', response.data.tokens.refreshToken);
    }

    return response;
  }

  async logout(): Promise<ApiResponse> {
    const response = await this.request('/auth/logout', {
      method: 'POST',
    });

    await this.removeTokenFromStorage();
    return response;
  }

  async refreshToken(): Promise<ApiResponse<AuthTokens>> {
    try {
      const refreshToken = await AsyncStorage.getItem('refreshToken');
      if (!refreshToken) {
        return { success: false, error: 'No refresh token available' };
      }

      const response = await this.request<AuthTokens>('/auth/refresh', {
        method: 'POST',
        body: JSON.stringify({ refreshToken }),
      });

      if (response.success && response.data) {
        await this.saveTokenToStorage(response.data.accessToken);
        await AsyncStorage.setItem('refreshToken', response.data.refreshToken);
      }

      return response;
    } catch (error) {
      return { success: false, error: 'Failed to refresh token' };
    }
  }

  // User Profile
  async getProfile(): Promise<ApiResponse<User>> {
    return this.request<User>('/users/profile');
  }

  async updateProfile(userData: Partial<User>): Promise<ApiResponse<User>> {
    return this.request<User>('/users/profile', {
      method: 'PATCH',
      body: JSON.stringify(userData),
    });
  }

  // LiveKit Integration
  async generateVoiceAgentToken(data: VoiceAgentTokenRequest): Promise<ApiResponse<{
    token: string;
    roomName: string;
    participantName: string;
    livekitUrl: string;
    type: string;
  }>> {
    return this.request('/livekit/voice-agent/token', {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }

  async generateIoTToken(deviceId: string, roomName: string): Promise<ApiResponse<{
    token: string;
    roomName: string;
    participantName: string;
    livekitUrl: string;
    type: string;
  }>> {
    return this.request('/livekit/iot/token', {
      method: 'POST',
      body: JSON.stringify({ deviceId, roomName }),
    });
  }

  async listLiveKitRooms(): Promise<ApiResponse<{ rooms: any[] }>> {
    return this.request('/livekit/rooms');
  }

  // IoT Devices
  async getIoTDevices(): Promise<ApiResponse<IoTDevice[]>> {
    return this.request<IoTDevice[]>('/iot/devices');
  }

  async getIoTDevice(deviceId: string): Promise<ApiResponse<IoTDevice>> {
    return this.request<IoTDevice>(`/iot/devices/${deviceId}`);
  }

  async createIoTDevice(deviceData: Partial<IoTDevice>): Promise<ApiResponse<IoTDevice>> {
    return this.request<IoTDevice>('/iot/devices', {
      method: 'POST',
      body: JSON.stringify(deviceData),
    });
  }

  async updateIoTDevice(deviceId: string, deviceData: Partial<IoTDevice>): Promise<ApiResponse<IoTDevice>> {
    return this.request<IoTDevice>(`/iot/devices/${deviceId}`, {
      method: 'PATCH',
      body: JSON.stringify(deviceData),
    });
  }

  async deleteIoTDevice(deviceId: string): Promise<ApiResponse> {
    return this.request(`/iot/devices/${deviceId}`, {
      method: 'DELETE',
    });
  }

  // Voice Sessions
  async getVoiceSessions(): Promise<ApiResponse<any[]>> {
    return this.request('/voice/sessions');
  }

  async createVoiceSession(sessionData: any): Promise<ApiResponse<any>> {
    return this.request('/voice/sessions', {
      method: 'POST',
      body: JSON.stringify(sessionData),
    });
  }

  async endVoiceSession(sessionId: string): Promise<ApiResponse> {
    return this.request(`/voice/sessions/${sessionId}/end`, {
      method: 'POST',
    });
  }

  // Toys
  async getToys(): Promise<ApiResponse<Toy[]>> {
    return this.request<Toy[]>('/toys');
  }

  async getMyToys(): Promise<ApiResponse<Toy[]>> {
    return this.request<Toy[]>('/toys/my-toys');
  }

  async createToy(toyData: CreateToyRequest): Promise<ApiResponse<Toy>> {
    return this.request<Toy>('/toys', {
      method: 'POST',
      body: JSON.stringify(toyData),
    });
  }

  async updateToy(toyId: string, toyData: Partial<Toy>): Promise<ApiResponse<Toy>> {
    return this.request<Toy>(`/toys/${toyId}`, {
      method: 'PATCH',
      body: JSON.stringify(toyData),
    });
  }

  async deleteToy(toyId: string): Promise<ApiResponse> {
    return this.request(`/toys/${toyId}`, {
      method: 'DELETE',
    });
  }

  async assignToy(assignData: { toyId: string; userId?: string }): Promise<ApiResponse<{ success: boolean; message: string }>> {
    return this.request('/toys/assign', {
      method: 'POST',
      body: JSON.stringify(assignData),
    });
  }

  async updateToyStatus(toyId: string, statusData: { status?: string; batteryLevel?: string; signalStrength?: string }): Promise<ApiResponse<Toy>> {
    return this.request<Toy>(`/toys/${toyId}/status`, {
      method: 'PATCH',
      body: JSON.stringify(statusData),
    });
  }

  // Health Check
  async healthCheck(): Promise<ApiResponse<{ status: string; timestamp: string }>> {
    return this.request('/health');
  }

  // Generic HTTP methods for backward compatibility
  async get(endpoint: string): Promise<any> {
    const response = await this.request(endpoint);
    return { data: response.data };
  }

  async post(endpoint: string, data: any): Promise<any> {
    const response = await this.request(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
    return { data: response.data };
  }

  async put(endpoint: string, data: any): Promise<any> {
    const response = await this.request(endpoint, {
      method: 'PUT',
      body: JSON.stringify(data),
    });
    return { data: response.data };
  }

  async delete(endpoint: string): Promise<any> {
    const response = await this.request(endpoint, {
      method: 'DELETE',
    });
    return { data: response.data };
  }

  // Utility methods
  isAuthenticated(): boolean {
    return !!this.accessToken;
  }

  setAuthToken(token: string): void {
    this.accessToken = token;
  }

  clearAuthToken(): void {
    this.accessToken = null;
  }
}

// Export singleton instance
export const apiService = new ApiService();
export default apiService;
