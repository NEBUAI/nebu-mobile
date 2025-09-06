import { createSlice, createAsyncThunk, PayloadAction } from '@reduxjs/toolkit';
import { liveKitIoTService, LiveKitConfig, IoTDeviceData } from '@/services/livekitService';

export interface IoTDevice {
  id: string;
  name: string;
  type: 'sensor' | 'actuator' | 'camera' | 'microphone';
  status: 'online' | 'offline';
  lastSeen: number;
  data?: any;
}

export interface IoTState {
  isConnected: boolean;
  connectionStatus: 'connected' | 'disconnected' | 'connecting' | 'error';
  devices: IoTDevice[];
  config: LiveKitConfig | null;
  recentData: IoTDeviceData[];
  isLoading: boolean;
  error: string | null;
}

const initialState: IoTState = {
  isConnected: false,
  connectionStatus: 'disconnected',
  devices: [],
  config: null,
  recentData: [],
  isLoading: false,
  error: null,
};

// Async thunks
export const connectToLiveKit = createAsyncThunk(
  'iot/connect',
  async (config: LiveKitConfig, { rejectWithValue }) => {
    try {
      await liveKitIoTService.connect(config);
      return config;
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Failed to connect');
    }
  }
);

export const disconnectFromLiveKit = createAsyncThunk(
  'iot/disconnect',
  async (_, { rejectWithValue }) => {
    try {
      await liveKitIoTService.disconnect();
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Failed to disconnect');
    }
  }
);

export const sendIoTData = createAsyncThunk(
  'iot/sendData',
  async (data: IoTDeviceData, { rejectWithValue }) => {
    try {
      await liveKitIoTService.sendIoTData(data);
      return data;
    } catch (error) {
      return rejectWithValue(error instanceof Error ? error.message : 'Failed to send data');
    }
  }
);

const iotSlice = createSlice({
  name: 'iot',
  initialState,
  reducers: {
    setConnectionStatus: (state, action: PayloadAction<'connected' | 'disconnected' | 'connecting' | 'error'>) => {
      state.connectionStatus = action.payload;
      state.isConnected = action.payload === 'connected';
    },
    addDeviceData: (state, action: PayloadAction<IoTDeviceData>) => {
      const data = action.payload;
      
      // Add to recent data (keep last 100 entries)
      state.recentData.unshift(data);
      if (state.recentData.length > 100) {
        state.recentData = state.recentData.slice(0, 100);
      }

      // Update device info
      const existingDeviceIndex = state.devices.findIndex(d => d.id === data.deviceId);
      if (existingDeviceIndex >= 0) {
        state.devices[existingDeviceIndex] = {
          ...state.devices[existingDeviceIndex],
          status: 'online',
          lastSeen: data.timestamp,
          data: data.data,
        };
      } else {
        // Add new device
        state.devices.push({
          id: data.deviceId,
          name: data.deviceId,
          type: data.deviceType,
          status: 'online',
          lastSeen: data.timestamp,
          data: data.data,
        });
      }
    },
    updateDeviceStatus: (state, action: PayloadAction<{ deviceId: string; status: 'online' | 'offline' }>) => {
      const { deviceId, status } = action.payload;
      const device = state.devices.find(d => d.id === deviceId);
      if (device) {
        device.status = status;
        if (status === 'offline') {
          device.lastSeen = Date.now();
        }
      }
    },
    removeDevice: (state, action: PayloadAction<string>) => {
      const deviceId = action.payload;
      state.devices = state.devices.filter(d => d.id !== deviceId);
    },
    clearRecentData: (state) => {
      state.recentData = [];
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder
      // Connect
      .addCase(connectToLiveKit.pending, (state) => {
        state.isLoading = true;
        state.error = null;
        state.connectionStatus = 'connecting';
      })
      .addCase(connectToLiveKit.fulfilled, (state, action) => {
        state.isLoading = false;
        state.config = action.payload;
        state.connectionStatus = 'connected';
        state.isConnected = true;
      })
      .addCase(connectToLiveKit.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
        state.connectionStatus = 'error';
        state.isConnected = false;
      })
      // Disconnect
      .addCase(disconnectFromLiveKit.pending, (state) => {
        state.isLoading = true;
      })
      .addCase(disconnectFromLiveKit.fulfilled, (state) => {
        state.isLoading = false;
        state.connectionStatus = 'disconnected';
        state.isConnected = false;
        state.devices = state.devices.map(device => ({ ...device, status: 'offline' as const }));
      })
      .addCase(disconnectFromLiveKit.rejected, (state, action) => {
        state.isLoading = false;
        state.error = action.payload as string;
      })
      // Send data
      .addCase(sendIoTData.pending, (state) => {
        state.error = null;
      })
      .addCase(sendIoTData.fulfilled, () => {
        // Data sent successfully
      })
      .addCase(sendIoTData.rejected, (state, action) => {
        state.error = action.payload as string;
      });
  },
});

export const {
  setConnectionStatus,
  addDeviceData,
  updateDeviceStatus,
  removeDevice,
  clearRecentData,
  setError,
} = iotSlice.actions;

export default iotSlice.reducer;