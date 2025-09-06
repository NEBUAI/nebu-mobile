import { liveKitIoTService, IoTDeviceData } from '@/services/livekitService';
import { LIVEKIT_URL, DEFAULT_IOT_ROOM, DEFAULT_PARTICIPANT_PREFIX } from '@env';

export interface TestResult {
  success: boolean;
  message: string;
  details?: any;
}

export class LiveKitTester {
  
  static async testConnection(): Promise<TestResult> {
    try {
      console.log('🔍 Testing LiveKit connection...');
      console.log('Server URL:', LIVEKIT_URL);
      console.log('Room:', DEFAULT_IOT_ROOM);
      
      const participantName = `${DEFAULT_PARTICIPANT_PREFIX}-test-${Date.now()}`;
      
      await liveKitIoTService.connect({
        roomName: DEFAULT_IOT_ROOM,
        participantName: participantName,
      });
      
      // Wait a moment for connection to establish
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      if (liveKitIoTService.isConnected()) {
        await liveKitIoTService.disconnect();
        return {
          success: true,
          message: '✅ Connection successful!',
          details: {
            serverUrl: LIVEKIT_URL,
            room: DEFAULT_IOT_ROOM,
            participant: participantName,
          }
        };
      } else {
        return {
          success: false,
          message: '❌ Connection failed - not connected after timeout',
        };
      }
      
    } catch (error) {
      console.error('Connection test failed:', error);
      return {
        success: false,
        message: `❌ Connection failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
        details: error,
      };
    }
  }
  
  static async testDataSending(): Promise<TestResult> {
    try {
      console.log('📤 Testing data sending...');
      
      const participantName = `${DEFAULT_PARTICIPANT_PREFIX}-data-test-${Date.now()}`;
      
      await liveKitIoTService.connect({
        roomName: DEFAULT_IOT_ROOM,
        participantName: participantName,
      });
      
      // Wait for connection
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      if (!liveKitIoTService.isConnected()) {
        throw new Error('Not connected to room');
      }
      
      const testData: IoTDeviceData = {
        deviceId: 'test-device-001',
        deviceType: 'sensor',
        data: {
          temperature: 23.5,
          humidity: 45,
          pressure: 1013.25,
          location: { lat: 40.7128, lng: -74.0060 },
          status: 'testing',
          timestamp: Date.now(),
        },
        timestamp: Date.now(),
      };
      
      await liveKitIoTService.sendIoTData(testData);
      
      await liveKitIoTService.disconnect();
      
      return {
        success: true,
        message: '✅ Data sending successful!',
        details: testData,
      };
      
    } catch (error) {
      console.error('Data sending test failed:', error);
      return {
        success: false,
        message: `❌ Data sending failed: ${error instanceof Error ? error.message : 'Unknown error'}`,
        details: error,
      };
    }
  }
  
  static async runAllTests(): Promise<TestResult[]> {
    console.log('🚀 Running LiveKit tests...');
    
    const results = [];
    
    // Test 1: Basic connection
    results.push(await this.testConnection());
    
    // Wait between tests
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Test 2: Data sending
    results.push(await this.testDataSending());
    
    console.log('✅ All tests completed');
    return results;
  }
}

// Quick test function for debugging
export const quickTest = async () => {
  console.log('🔥 Quick LiveKit test starting...');
  
  try {
    const result = await LiveKitTester.testConnection();
    console.log('Test result:', result);
    return result;
  } catch (error) {
    console.error('Quick test error:', error);
    return {
      success: false,
      message: `Quick test failed: ${error}`,
    };
  }
};