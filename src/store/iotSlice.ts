import { createSlice, PayloadAction } from '@reduxjs/toolkit';

export interface IoTDevice {
  id: string;
  name: string;
  type: string;
  status: 'online' | 'offline';
  lastSeen: string;
  temperature?: number;
  humidity?: number;
  batteryLevel?: number;
}

export interface IoTMetrics {
  totalDevices: number;
  onlineDevices: number;
  offlineDevices: number;
  averageTemperature: number;
  averageHumidity: number;
}

interface IoTState {
  devices: IoTDevice[];
  metrics: IoTMetrics;
  isLoading: boolean;
  error: string | null;
  selectedDevice: IoTDevice | null;
}

const initialState: IoTState = {
  devices: [],
  metrics: {
    totalDevices: 0,
    onlineDevices: 0,
    offlineDevices: 0,
    averageTemperature: 0,
    averageHumidity: 0,
  },
  isLoading: false,
  error: null,
  selectedDevice: null,
};

const iotSlice = createSlice({
  name: 'iot',
  initialState,
  reducers: {
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload;
    },
    setDevices: (state, action: PayloadAction<IoTDevice[]>) => {
      state.devices = action.payload;
      state.metrics = calculateMetrics(action.payload);
    },
    addDevice: (state, action: PayloadAction<IoTDevice>) => {
      state.devices.push(action.payload);
      state.metrics = calculateMetrics(state.devices);
    },
    updateDevice: (state, action: PayloadAction<IoTDevice>) => {
      const index = state.devices.findIndex(device => device.id === action.payload.id);
      if (index !== -1) {
        state.devices[index] = action.payload;
        state.metrics = calculateMetrics(state.devices);
      }
    },
    removeDevice: (state, action: PayloadAction<string>) => {
      state.devices = state.devices.filter(device => device.id !== action.payload);
      state.metrics = calculateMetrics(state.devices);
    },
    setSelectedDevice: (state, action: PayloadAction<IoTDevice | null>) => {
      state.selectedDevice = action.payload;
    },
  },
});

function calculateMetrics(devices: IoTDevice[]): IoTMetrics {
  const totalDevices = devices.length;
  const onlineDevices = devices.filter(device => device.status === 'online').length;
  const offlineDevices = totalDevices - onlineDevices;
  
  const temperatures = devices.filter(device => device.temperature !== undefined).map(device => device.temperature!);
  const humidities = devices.filter(device => device.humidity !== undefined).map(device => device.humidity!);
  
  const averageTemperature = temperatures.length > 0 
    ? temperatures.reduce((sum, temp) => sum + temp, 0) / temperatures.length 
    : 0;
    
  const averageHumidity = humidities.length > 0 
    ? humidities.reduce((sum, hum) => sum + hum, 0) / humidities.length 
    : 0;

  return {
    totalDevices,
    onlineDevices,
    offlineDevices,
    averageTemperature,
    averageHumidity,
  };
}

export const {
  setLoading,
  setError,
  setDevices,
  addDevice,
  updateDevice,
  removeDevice,
  setSelectedDevice,
} = iotSlice.actions;

export default iotSlice.reducer;