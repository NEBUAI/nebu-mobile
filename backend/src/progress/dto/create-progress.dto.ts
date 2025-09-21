import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNumber, IsEnum, IsOptional, Min, Max } from 'class-validator';

export enum ProgressStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

export class CreateProgressDto {
  @ApiProperty({
    description: 'ID del usuario',
    example: 'uuid-string',
  })
  @IsString()
  userId: string;

  @ApiProperty({
    description: 'ID del curso',
    example: 'uuid-string',
  })
  @IsString()
  courseId: string;

  @ApiPropertyOptional({
    description: 'ID de la lección específica (opcional)',
    example: 'uuid-string',
  })
  @IsString()
  @IsOptional()
  lessonId?: string;

  @ApiPropertyOptional({
    description: 'Estado del progreso',
    enum: ProgressStatus,
    example: ProgressStatus.IN_PROGRESS,
    default: ProgressStatus.NOT_STARTED,
  })
  @IsEnum(ProgressStatus)
  @IsOptional()
  status?: ProgressStatus;

  @ApiPropertyOptional({
    description: 'Porcentaje de finalización (0-100)',
    example: 75,
    minimum: 0,
    maximum: 100,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(100)
  completionPercentage?: number;

  @ApiPropertyOptional({
    description: 'Progreso actual (0-100)',
    example: 75,
    minimum: 0,
    maximum: 100,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(100)
  progress?: number;

  @ApiPropertyOptional({
    description: 'Tiempo total invertido en minutos',
    example: 120,
    minimum: 0,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  timeSpent?: number;

  @ApiPropertyOptional({
    description: 'Tiempo de visualización de video en minutos (para lecciones de video)',
    example: 45,
    minimum: 0,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  watchTime?: number;

  @ApiPropertyOptional({
    description: 'Puntuación obtenida (para quizzes)',
    example: 85,
    minimum: 0,
    maximum: 100,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  @Max(100)
  score?: number;

  @ApiPropertyOptional({
    description: 'Número de intentos realizados',
    example: 2,
    minimum: 0,
  })
  @IsNumber()
  @IsOptional()
  @Min(0)
  attempts?: number;
}
