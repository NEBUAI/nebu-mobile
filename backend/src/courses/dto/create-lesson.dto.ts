import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsNumber,
  IsEnum,
  IsUrl,
  Min,
  Max,
} from 'class-validator';

export enum LessonType {
  VIDEO = 'video',
  TEXT = 'text',
  QUIZ = 'quiz',
  ASSIGNMENT = 'assignment',
  LIVE = 'live',
  DOCUMENT = 'document',
}

export enum LessonStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

export class CreateLessonDto {
  @ApiProperty({
    description: 'Título de la lección',
    example: 'Introducción a React',
  })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiPropertyOptional({
    description: 'Descripción de la lección',
    example: 'En esta lección aprenderás los conceptos básicos de React',
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    description: 'Contenido de la lección en formato HTML/Markdown',
    example: '<p>Bienvenido a la lección de React...</p>',
  })
  @IsString()
  @IsOptional()
  content?: string;

  @ApiProperty({
    description: 'Tipo de lección',
    enum: LessonType,
    example: LessonType.VIDEO,
  })
  @IsEnum(LessonType)
  type: LessonType;

  @ApiPropertyOptional({
    description: 'Estado de la lección',
    enum: LessonStatus,
    example: LessonStatus.DRAFT,
    default: LessonStatus.DRAFT,
  })
  @IsEnum(LessonStatus)
  @IsOptional()
  status?: LessonStatus;

  @ApiPropertyOptional({
    description: 'Duración en minutos',
    example: 25,
    minimum: 1,
    maximum: 300,
  })
  @IsNumber()
  @IsOptional()
  @Min(1)
  @Max(300)
  duration?: number;

  @ApiPropertyOptional({
    description: 'Orden de la lección en el curso',
    example: 1,
    minimum: 1,
    maximum: 999,
  })
  @IsNumber()
  @IsOptional()
  @Min(1)
  @Max(999)
  sortOrder?: number;

  @ApiPropertyOptional({
    description: 'URL del video (para lecciones de video)',
    example: 'https://vimeo.com/123456789',
  })
  @IsUrl()
  @IsOptional()
  videoUrl?: string;

  @ApiPropertyOptional({
    description: 'URL de la imagen de portada',
    example: 'https://example.com/lesson-cover.jpg',
  })
  @IsUrl()
  @IsOptional()
  thumbnailUrl?: string;

  @ApiPropertyOptional({
    description: 'Si la lección es una vista previa gratuita',
    example: false,
    default: false,
  })
  @IsBoolean()
  @IsOptional()
  isPreview?: boolean;

  @ApiPropertyOptional({
    description: 'Si la lección es obligatoria para completar el curso',
    example: true,
    default: true,
  })
  @IsBoolean()
  @IsOptional()
  isRequired?: boolean;

  @ApiProperty({
    description: 'ID del curso al que pertenece la lección',
    example: 'uuid-string',
  })
  @IsString()
  courseId: string;

  @ApiPropertyOptional({
    description: 'Recursos adicionales (archivos, links, etc.)',
    example: {
      files: [
        { name: 'Código fuente', url: 'https://github.com/example/repo' },
        { name: 'Slides', url: 'https://example.com/slides.pdf' },
      ],
    },
  })
  @IsOptional()
  resources?: any;

  @ApiPropertyOptional({
    description: 'Configuración del quiz (para lecciones tipo quiz)',
    example: {
      questions: [
        {
          question: '¿Qué es React?',
          type: 'multiple_choice',
          options: ['Librería', 'Framework', 'Lenguaje'],
          correct: 0,
        },
      ],
      passingScore: 80,
      timeLimit: 10,
    },
  })
  @IsOptional()
  quizConfig?: any;
}
