import { IsString, IsOptional, IsEnum, IsObject, IsUUID, Matches, Length } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ToyStatus } from '../entities/toy.entity';

export class CreateToyDto {
  @ApiProperty({
    description: 'MAC address del juguete en formato XX:XX:XX:XX:XX:XX',
    example: '00:1B:44:11:3A:B7',
    pattern: '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
  })
  @IsString()
  @Matches(/^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/, {
    message: 'MAC address debe estar en formato XX:XX:XX:XX:XX:XX o XX-XX-XX-XX-XX-XX',
  })
  macAddress: string;

  @ApiProperty({
    description: 'Nombre del juguete',
    example: 'Mi Robot Azul',
    minLength: 1,
    maxLength: 100,
  })
  @IsString()
  @Length(1, 100)
  name: string;

  @ApiPropertyOptional({
    description: 'Modelo del juguete',
    example: 'NebuBot Pro',
    maxLength: 50,
  })
  @IsOptional()
  @IsString()
  @Length(1, 50)
  model?: string;

  @ApiPropertyOptional({
    description: 'Fabricante del juguete',
    example: 'Nebu Technologies',
    maxLength: 100,
  })
  @IsOptional()
  @IsString()
  @Length(1, 100)
  manufacturer?: string;

  @ApiPropertyOptional({
    description: 'Estado inicial del juguete',
    enum: ToyStatus,
    default: ToyStatus.INACTIVE,
  })
  @IsOptional()
  @IsEnum(ToyStatus)
  status?: ToyStatus;

  @ApiPropertyOptional({
    description: 'Versión del firmware',
    example: '1.2.3',
    maxLength: 50,
  })
  @IsOptional()
  @IsString()
  @Length(1, 50)
  firmwareVersion?: string;

  @ApiPropertyOptional({
    description: 'Capacidades del juguete',
    example: {
      voice: true,
      movement: true,
      lights: true,
      sensors: ['temperature', 'proximity'],
      aiFeatures: ['speech_recognition', 'face_detection']
    },
  })
  @IsOptional()
  @IsObject()
  capabilities?: {
    voice?: boolean;
    movement?: boolean;
    lights?: boolean;
    sensors?: string[];
    aiFeatures?: string[];
  };

  @ApiPropertyOptional({
    description: 'Configuraciones iniciales del juguete',
    example: {
      volume: 70,
      brightness: 80,
      language: 'es',
      timezone: 'America/Mexico_City',
      autoUpdate: true
    },
  })
  @IsOptional()
  @IsObject()
  settings?: {
    volume?: number;
    brightness?: number;
    language?: string;
    timezone?: string;
    autoUpdate?: boolean;
  };

  @ApiPropertyOptional({
    description: 'Notas adicionales sobre el juguete',
    example: 'Regalo de cumpleaños para mi hijo',
  })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({
    description: 'ID del usuario propietario (opcional)',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsOptional()
  @IsUUID()
  userId?: string;
}
