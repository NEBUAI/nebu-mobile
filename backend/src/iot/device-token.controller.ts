import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { IoTService } from './iot.service';
import { DeviceTokenRequestDto } from './dto/device-token.dto';

@ApiTags('iot')
@Controller('iot')
export class DeviceTokenController {
  private readonly logger = new Logger(DeviceTokenController.name);
  
  constructor(private readonly iotService: IoTService) {}

  @Post('device/token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Create LiveKit session and get LiveKit access token for IoT device' })
  @ApiResponse({ 
    status: 200, 
    description: 'LiveKit session created and token generated successfully',
    schema: {
      type: 'object',
      properties: {
        access_token: {
          type: 'string',
          description: 'LiveKit access token for real-time communication',
          example: 'eyJhbGciOiJIUzI1NiJ9.eyJtZXRhZGF0YSI6IntcInR5cGVcI...'
        },
        roomName: {
          type: 'string',
          description: 'LiveKit room name where the device will connect',
          example: 'iot-device-a4538271-c9a3-43c8-8754-76fdd9a90520'
        }
      }
    }
  })
  @ApiResponse({ status: 400, description: 'Invalid device ID' })
  @ApiResponse({ status: 404, description: 'Device not found' })
  async getDeviceToken(@Body() deviceTokenRequest: DeviceTokenRequestDto): Promise<{ access_token: string; roomName: string }> {
    this.logger.log(' IoT Device Token Request Received');
    this.logger.log(` Device ID: ${deviceTokenRequest.device_id}`);
    this.logger.log(` Request Time: ${new Date().toISOString()}`);
    
    try {
      // Generate LiveKit session and token for the device
      const livekitResult = await this.iotService.generateLiveKitTokenForDevice(deviceTokenRequest.device_id);
      
      this.logger.log(' LiveKit Session Created Successfully');
      this.logger.log(` Room Name: ${livekitResult.roomName}`);
      this.logger.log(` Participant: ${livekitResult.participantName}`);
      this.logger.log(` LiveKit URL: ${livekitResult.livekitUrl}`);
      this.logger.log(` LiveKit Token Preview: ${livekitResult.token.substring(0, 30)}...`);
      this.logger.log(` LiveKit Token Length: ${livekitResult.token.length} characters`);
      
      return {
        access_token: livekitResult.token,
        roomName: livekitResult.roomName
      };
    } catch (error) {
      this.logger.error(' Failed to create LiveKit session for IoT Device');
      this.logger.error(` Error: ${error.message}`);
      this.logger.error(` Device ID: ${deviceTokenRequest.device_id}`);
      throw error;
    }
  }
}
