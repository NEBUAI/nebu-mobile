import { IsString, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class DeviceTokenRequestDto {
  @ApiProperty({
    description: 'Device ID (MAC address or unique identifier)',
    example: 'ESP32_AA:BB:CC:DD:EE:FF',
  })
  @IsString()
  @IsNotEmpty()
  device_id: string;
}

export class DeviceTokenResponseDto {
  @ApiProperty({
    description: 'JWT access token for device authentication',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  access_token: string;

  @ApiProperty({
    description: 'Token type',
    example: 'Bearer',
  })
  token_type: string;
}
