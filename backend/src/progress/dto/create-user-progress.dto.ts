import {
  IsString,
  IsNumber,
  IsBoolean,
  IsOptional,
  IsEnum,
  IsUUID,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ProgressStatus } from '../entities/user-progress.entity';

export class CreateUserProgressDto {
  @ApiProperty({ description: 'ID del usuario' })
  @IsString()
  @IsUUID()
  userId: string;

  @ApiProperty({ description: 'ID del curso' })
  @IsString()
  @IsUUID()
  courseId: string;

  @ApiProperty({ description: 'ID de la lección', required: false })
  @IsOptional()
  @IsString()
  @IsUUID()
  lessonId?: string;

  @ApiProperty({ description: 'Estado del progreso', enum: ProgressStatus })
  @IsOptional()
  @IsEnum(ProgressStatus)
  status?: ProgressStatus;

  @ApiProperty({ description: 'Porcentaje de completado (0-100)', minimum: 0, maximum: 100 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(100)
  completionPercentage?: number;

  @ApiProperty({ description: 'Si el usuario está inscrito en el curso' })
  @IsOptional()
  @IsBoolean()
  isEnrolled?: boolean;

  @ApiProperty({ description: 'Número de lecciones completadas' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  completedLessons?: number;

  @ApiProperty({ description: 'Número total de lecciones' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  totalLessons?: number;

  @ApiProperty({ description: 'Número de slides' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  slidesCount?: number;

  @ApiProperty({ description: 'Tiempo gastado en segundos' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  timeSpent?: number;

  @ApiProperty({ description: 'Metadatos adicionales', required: false })
  @IsOptional()
  metadata?: Record<string, any>;
}
