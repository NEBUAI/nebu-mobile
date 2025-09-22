// @ts-nocheck
import { Room, RoomEvent, RemoteParticipant, DataPacket_Kind } from 'livekit-client';
import { ENV_CONFIG } from '@/config/env';
import { apiService } from './api';

export interface LiveKitConfig {
  serverUrl?: string;
  roomName: string;
  participantName: string;
}

export interface IoTDeviceData {
  deviceId: string;
  deviceType: 'sensor' | 'actuator' | 'camera' | 'microphone';
  data: any;
  timestamp: number;
}

export class LiveKitIoTService {
  private room: Room | null = null;
  private config: LiveKitConfig | null = null;
  private onDeviceDataCallback?: (data: IoTDeviceData) => void;
  private onConnectionStatusCallback?: (status: 'connected' | 'disconnected' | 'connecting' | 'error') => void;

  constructor() {
    // Initialize polyfills for React Native
    require('react-native-get-random-values');
  }

  async connect(config: LiveKitConfig): Promise<void> {
    try {
      this.config = config;
      this.onConnectionStatusCallback?.('connecting');

      // Use local LiveKit server in development, demo server as fallback
      const serverUrl = config.serverUrl || (__DEV__ ? 'ws://localhost:7880' : 'wss://livekit-demo.livekit.cloud');
      const roomName = config.roomName || 'nebu-test-room';
      const participantName = config.participantName || `tester-${Date.now()}`;

      // Generate demo token for LiveKit demo server
      const token = await this.generateDemoToken(participantName, roomName);

      this.room = new Room();
      this.setupRoomEventHandlers();
      
      await this.room.connect(serverUrl, token);
      this.onConnectionStatusCallback?.('connected');
    } catch (error) {
      console.error('Failed to connect to LiveKit:', error);
      this.onConnectionStatusCallback?.('error');
      throw error;
    }
  }

  private async generateDemoToken(participantName: string, roomName: string): Promise<string> {
    try {
      // Try to get real token from backend first
      const response = await apiService.generateVoiceAgentToken({
        userId: 'demo-user',
        sessionId: `${Date.now()}`
      });

      if (response.success && response.data?.token) {
        return response.data.token;
      }
    } catch (error) {
      console.warn('Failed to get token from backend, using demo token:', error);
    }

    // Fallback to demo token for development
    const demoToken = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzU2Nzg4MDAsImlzcyI6ImRlbW8iLCJuYW1lIjoiJHtwYXJ0aWNpcGFudE5hbWV9Iiwic3ViIjoiJHtwYXJ0aWNpcGFudE5hbWV9IiwidmlkZW8iOnsicm9vbSI6IiR7cm9vbU5hbWV9Iiwicm9vbUpvaW4iOnRydWUsImNhblB1Ymxpc2giOnRydWUsImNhblN1YnNjcmliZSI6dHJ1ZX19.demo-token-${Date.now()}`;
    return demoToken;
  }

  async disconnect(): Promise<void> {
    try {
      if (this.room) {
        await this.room.disconnect();
        this.room = null;
      }
      this.onConnectionStatusCallback?.('disconnected');
    } catch (error) {
      console.error('Failed to disconnect from LiveKit:', error);
      throw error;
    }
  }

  async sendIoTData(data: IoTDeviceData): Promise<void> {
    if (!this.room || !this.room.localParticipant) {
      throw new Error('Not connected to room');
    }

    try {
      const message = JSON.stringify(data);
      const encoder = new TextEncoder();
      const dataArray = encoder.encode(message);
      
      await this.room.localParticipant.publishData(dataArray, {
        reliable: true,
      });
    } catch (error) {
      console.error('Failed to send IoT data:', error);
      throw error;
    }
  }

  onDeviceData(callback: (data: IoTDeviceData) => void): void {
    this.onDeviceDataCallback = callback;
  }

  onConnectionStatus(callback: (status: 'connected' | 'disconnected' | 'connecting' | 'error') => void): void {
    this.onConnectionStatusCallback = callback;
  }

  async enableMicrophone(): Promise<void> {
    if (!this.room) throw new Error('Not connected to room');
    
    try {
      await this.room.localParticipant.setMicrophoneEnabled(true);
    } catch (error) {
      console.error('Failed to enable microphone:', error);
      throw error;
    }
  }

  async disableMicrophone(): Promise<void> {
    if (!this.room) throw new Error('Not connected to room');
    
    try {
      await this.room.localParticipant.setMicrophoneEnabled(false);
    } catch (error) {
      console.error('Failed to disable microphone:', error);
      throw error;
    }
  }

  async sendData(data: any): Promise<void> {
    if (!this.room) throw new Error('Not connected to room');
    
    try {
      const encoder = new TextEncoder();
      const dataBytes = encoder.encode(JSON.stringify(data));
      await this.room.localParticipant.publishData(dataBytes, DataPacket_Kind.RELIABLE);
    } catch (error) {
      console.error('Failed to send data:', error);
      throw error;
    }
  }

  async sendIoTSensorData(): Promise<void> {
    const sensorData = {
      type: 'sensor_reading',
      deviceId: `sensor-${Date.now()}`,
      timestamp: Date.now(),
      temperature: 20 + Math.random() * 15, // 20-35°C
      humidity: 40 + Math.random() * 40,    // 40-80%
      pressure: 1000 + Math.random() * 50,  // 1000-1050 hPa
      location: {
        lat: 40.7128 + (Math.random() - 0.5) * 0.01,
        lng: -74.0060 + (Math.random() - 0.5) * 0.01
      }
    };

    await this.sendData(sensorData);
  }

  getConnectedParticipants(): number {
    return this.room ? this.room.participants.size : 0;
  }

  getRoomInfo(): { name: string; participants: number; isConnected: boolean } | null {
    if (!this.room) return null;
    
    return {
      name: this.room.name || 'Unknown Room',
      participants: this.room.participants.size + 1, // +1 for local participant
      isConnected: this.room.state === 'connected'
    };
  }

  getConnectedDevices(): RemoteParticipant[] {
    if (!this.room) return [];
    return Array.from(this.room.remoteParticipants.values());
  }

  isConnected(): boolean {
    return this.room?.state === 'connected';
  }

  // Method removed - now using generateLiveKitToken utility

  private setupRoomEventHandlers(): void {
    if (!this.room) return;

    this.room.on(RoomEvent.Connected, () => {
      console.log('Connected to LiveKit room');
      this.onConnectionStatusCallback?.('connected');
    });

    this.room.on(RoomEvent.Disconnected, () => {
      console.log('Disconnected from LiveKit room');
      this.onConnectionStatusCallback?.('disconnected');
    });

    this.room.on(RoomEvent.ParticipantConnected, (participant: RemoteParticipant) => {
      console.log('IoT Device connected:', participant.identity);
    });

    this.room.on(RoomEvent.ParticipantDisconnected, (participant: RemoteParticipant) => {
      console.log('IoT Device disconnected:', participant.identity);
    });

    this.room.on(RoomEvent.DataReceived, (payload: Uint8Array, participant?: RemoteParticipant) => {
      try {
        const decoder = new TextDecoder();
        const message = decoder.decode(payload);
        const data: IoTDeviceData = JSON.parse(message);
        
        console.log('Received IoT data from:', participant?.identity || 'unknown', data);
        this.onDeviceDataCallback?.(data);
      } catch (error) {
        console.error('Failed to parse received data:', error);
      }
    });

    this.room.on(RoomEvent.RoomMetadataChanged, (metadata: string) => {
      console.log('Room metadata changed:', metadata);
    });
  }
}

// Singleton instance
const livekitService = new LiveKitIoTService();
export default livekitService;