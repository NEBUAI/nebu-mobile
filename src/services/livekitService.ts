// @ts-nocheck
import { Room, RoomEvent, RemoteParticipant } from 'livekit-client';
import { ENV_CONFIG } from '@/config/env';

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

      // Use environment variables for server URL if not provided
      const serverUrl = config.serverUrl || ENV_CONFIG.LIVEKIT_URL;
      const roomName = config.roomName || 'iot-room';
      const participantName = config.participantName || `device-${Date.now()}`;

      // TODO: Implement real token generation
      // This should call your backend API to generate a valid LiveKit token
      // Example:
      // const token = await generateTokenFromBackend(participantName, roomName);
      // 
      // this.room = new Room();
      // this.setupRoomEventHandlers();
      // await this.room.connect(serverUrl, token);
      // this.onConnectionStatusCallback?.('connected');
      
      throw new Error('LiveKit token generation not implemented. Connect to real LiveKit server with valid authentication.');
    } catch (error) {
      console.error('Failed to connect to LiveKit:', error);
      this.onConnectionStatusCallback?.('error');
      throw error;
    }
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
export const liveKitIoTService = new LiveKitIoTService();