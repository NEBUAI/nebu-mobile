import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsUUID, IsDateString } from 'class-validator';

export class GenerateCertificateDto {
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
    description: 'Plantilla de certificado a usar',
    example: 'default',
  })
  @IsOptional()
  @IsString()
  template?: string;

  @ApiPropertyOptional({
    description: 'Fecha de emisión del certificado',
    example: '2024-01-15T10:00:00Z',
  })
  @IsOptional()
  @IsDateString()
  issuedAt?: Date;

  @ApiPropertyOptional({
    description: 'Fecha de expiración del certificado',
    example: '2025-01-15T10:00:00Z',
  })
  @IsOptional()
  @IsDateString()
  expiresAt?: Date;

  @ApiPropertyOptional({
    description: 'Metadatos personalizados para el certificado',
    example: {
      instructor: 'John Doe',
      duration: '40 hours',
      customText: 'Congratulations on completing this course!',
    },
  })
  @IsOptional()
  customData?: Record<string, any>;
}
