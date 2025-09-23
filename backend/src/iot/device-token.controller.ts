import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { IoTService } from './iot.service';
import { DeviceTokenRequestDto, DeviceTokenResponseDto } from './dto/device-token.dto';

@ApiTags('iot')
@Controller('iot')
export class DeviceTokenController {
  constructor(private readonly iotService: IoTService) {}

  @Post('device/token')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Get access token for IoT device' })
  @ApiResponse({ 
    status: 200, 
    description: 'Device token generated successfully', 
    type: DeviceTokenResponseDto 
  })
  @ApiResponse({ status: 400, description: 'Invalid device ID' })
  @ApiResponse({ status: 404, description: 'Device not found' })
  async getDeviceToken(@Body() deviceTokenRequest: DeviceTokenRequestDto): Promise<DeviceTokenResponseDto> {
    return this.iotService.generateDeviceToken(deviceTokenRequest.device_id);
  }
}
