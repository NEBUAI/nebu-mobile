import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { DeviceTokenRequest } from './deviceTokenService';

// Configuración base de la API
const API_BASE_URL = 'http://62.169.30.44:3000/api';

// Crear instancia de axios
const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para agregar token de autenticación
apiClient.interceptors.request.use(
  (config) => {
    // Obtener token del almacenamiento local
    const token = localStorage.getItem('authToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para manejar respuestas
apiClient.interceptors.response.use(
  (response: AxiosResponse) => {
    return response;
  },
  (error) => {
    // Manejar errores de autenticación
    if (error.response?.status === 401) {
      // Token expirado o inválido
      localStorage.removeItem('authToken');
      // Redirigir al login si es necesario
    }
    return Promise.reject(error);
  }
);

// Tipos para las respuestas de la API
export interface AuthResponse {
  accessToken: string;
  refreshToken?: string;
  user: {
    id: string;
    email: string;
    username: string;
    firstName: string;
    lastName: string;
    role: string;
  };
}

export interface Toy {
  id: string;
  macAddress: string;
  name: string;
  model?: string;
  manufacturer?: string;
  status: string;
  statusText: string;
  statusColor: string;
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
  userId?: string;
  createdAt: string;
  updatedAt: string;
  isActive: boolean;
  isConnected: boolean;
  needsAttention: boolean;
}

export interface CreateToyRequest {
  macAddress: string;
  name: string;
  model?: string;
  manufacturer?: string;
  status?: string;
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

export interface AssignToyRequest {
  toyId: string;
  userId?: string;
}

export interface UpdateToyStatusRequest {
  status: string;
  batteryLevel?: string;
  signalStrength?: string;
}

// Servicio principal de API
class ApiService {
  // Método genérico para hacer peticiones POST
  async post(endpoint: string, data: any): Promise<any> {
    try {
      const response = await apiClient.post(endpoint, data);
      return response;
    } catch (error) {
      console.error('API POST error:', error);
      throw error;
    }
  }

  // Método genérico para hacer peticiones GET
  async get(endpoint: string): Promise<any> {
    try {
      const response = await apiClient.get(endpoint);
      return response;
    } catch (error) {
      console.error('API GET error:', error);
      throw error;
    }
  }

  // Método genérico para hacer peticiones PUT
  async put(endpoint: string, data: any): Promise<any> {
    try {
      const response = await apiClient.put(endpoint, data);
      return response;
    } catch (error) {
      console.error('API PUT error:', error);
      throw error;
    }
  }

  // Método genérico para hacer peticiones DELETE
  async delete(endpoint: string): Promise<any> {
    try {
      const response = await apiClient.delete(endpoint);
      return response;
    } catch (error) {
      console.error('API DELETE error:', error);
      throw error;
    }
  }
  // Autenticación
  async login(email: string, password: string): Promise<AuthResponse> {
    const response = await apiClient.post('/auth/login', { email, password });
    const authData = response.data;
    
    // Guardar token en localStorage
    if (authData.accessToken) {
      localStorage.setItem('authToken', authData.accessToken);
    }
    
    return authData;
  }

  async register(userData: {
    firstName: string;
    lastName: string;
    email: string;
    username: string;
    password: string;
    role?: string;
  }): Promise<AuthResponse> {
    const response = await apiClient.post('/auth/register', userData);
    const authData = response.data;
    
    // Guardar token en localStorage
    if (authData.accessToken) {
      localStorage.setItem('authToken', authData.accessToken);
    }
    
    return authData;
  }

  async logout(): Promise<void> {
    localStorage.removeItem('authToken');
  }

  // Juguetes
  async getMyToys(): Promise<Toy[]> {
    const response = await apiClient.get('/toys/my-toys');
    return response.data;
  }

  async createToy(toyData: CreateToyRequest): Promise<Toy> {
    const response = await apiClient.post('/toys', toyData);
    return response.data;
  }

  async assignToy(assignData: AssignToyRequest): Promise<{ success: boolean; message: string }> {
    const response = await apiClient.post('/toys/assign', assignData);
    return response.data;
  }

  async updateToyStatus(macAddress: string, statusData: UpdateToyStatusRequest): Promise<Toy> {
    const response = await apiClient.patch(`/toys/connection/${macAddress}`, statusData);
    return response.data;
  }

  // Health check
  async healthCheck(): Promise<any> {
    const response = await apiClient.get('/health-simple');
    return response.data;
  }
}

// Exportar instancia singleton
export const apiService = new ApiService();
export default apiService;
