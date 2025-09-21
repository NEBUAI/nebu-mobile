import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsBoolean, IsNumber, Min, Max } from 'class-validator';

export class CreateCategoryDto {
  @ApiProperty({
    description: 'Nombre de la categoría',
    example: 'Desarrollo Web',
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({
    description: 'Descripción de la categoría',
    example: 'Aprende las tecnologías más demandadas para desarrollo web',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'Icono de la categoría',
    example: 'code',
  })
  @IsString()
  @IsOptional()
  icon?: string;

  @ApiPropertyOptional({
    description: 'Color de la categoría en formato hexadecimal',
    example: '#4F46E5',
  })
  @IsString()
  @IsOptional()
  color?: string;

  @ApiPropertyOptional({
    description: 'Orden de visualización',
    example: 1,
    minimum: 0,
    maximum: 999,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(999)
  sortOrder?: number;

  @ApiPropertyOptional({
    description: 'Si la categoría está activa',
    example: true,
    default: true,
  })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiPropertyOptional({
    description: 'ID de la categoría padre (para subcategorías)',
    example: 'uuid-string',
  })
  @IsString()
  @IsOptional()
  parentId?: string;
}
