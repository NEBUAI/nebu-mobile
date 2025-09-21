import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsUUID,
  IsDecimal,
  IsInt,
  IsDateString,
  Min,
  Max,
} from 'class-validator';

export class CreateCertificateDto {
  @ApiProperty({
    description: 'ID del usuario',
    example: 'uuid-string',
  })
  @IsUUID()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({
    description: 'ID del curso',
    example: 'uuid-string',
  })
  @IsUUID()
  @IsNotEmpty()
  courseId: string;

  @ApiPropertyOptional({
    description: 'Puntuación final del curso',
    example: 85.5,
    minimum: 0,
    maximum: 100,
  })
  @IsOptional()
  @IsDecimal({ decimal_digits: '0,2' })
  @Min(0)
  @Max(100)
  finalScore?: number;

  @ApiPropertyOptional({
    description: 'Porcentaje de finalización del curso',
    example: 100,
    minimum: 0,
    maximum: 100,
  })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  completionPercentage?: number;

  @ApiPropertyOptional({
    description: 'Fecha de finalización del curso',
    example: '2024-01-15T10:00:00Z',
  })
  @IsOptional()
  @IsDateString()
  completedAt?: Date;

  @ApiPropertyOptional({
    description: 'Fecha de expiración del certificado',
    example: '2025-01-15T10:00:00Z',
  })
  @IsOptional()
  @IsDateString()
  expiresAt?: Date;

  @ApiPropertyOptional({
    description: 'Metadatos adicionales en formato JSON',
    example: { instructor: 'John Doe', duration: '40 hours' },
  })
  @IsOptional()
  metadata?: Record<string, any>;

  @ApiPropertyOptional({
    description: 'Estado del certificado',
    example: 'pending',
  })
  @IsOptional()
  status?: string;
}
