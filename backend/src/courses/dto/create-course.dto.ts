import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsEnum,
  IsArray,
  MinLength,
  MaxLength,
  Min,
} from 'class-validator';
import { CourseLevel } from '../entities/course.entity';

export class CreateCourseDto {
  @ApiProperty({
    description: 'Título del curso',
    example: 'Desarrollo Web con React y Next.js',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(5)
  @MaxLength(200)
  title: string;

  @ApiProperty({
    description: 'Descripción completa del curso',
    example: 'Aprende a crear aplicaciones web modernas con React y Next.js desde cero.',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(20)
  description: string;

  @ApiProperty({
    description: 'Descripción corta del curso',
    example: 'Curso completo de React y Next.js',
    required: false,
  })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  shortDescription?: string;

  @ApiProperty({
    description: 'URL de la imagen/thumbnail del curso',
    required: false,
  })
  @IsOptional()
  @IsString()
  thumbnail?: string;

  @ApiProperty({
    description: 'URL del video trailer del curso',
    required: false,
  })
  @IsOptional()
  @IsString()
  trailer?: string;

  @ApiProperty({
    description: 'Precio del curso',
    example: 99.99,
  })
  @IsNumber()
  @Min(0)
  price: number;

  @ApiProperty({
    description: 'Precio con descuento',
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  discountPrice?: number;

  @ApiProperty({
    description: 'Nivel del curso',
    enum: CourseLevel,
    example: CourseLevel.BEGINNER,
  })
  @IsEnum(CourseLevel)
  level: CourseLevel;

  @ApiProperty({
    description: 'ID de la categoría',
    required: false,
  })
  @IsOptional()
  @IsString()
  categoryId?: string;

  @ApiProperty({
    description: 'Tags del curso',
    type: [String],
    required: false,
    example: ['react', 'nextjs', 'javascript', 'web-development'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiProperty({
    description: 'Requisitos previos del curso',
    type: [String],
    required: false,
    example: ['Conocimientos básicos de HTML y CSS', 'Familiaridad con JavaScript'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  requirements?: string[];

  @ApiProperty({
    description: 'Objetivos de aprendizaje',
    type: [String],
    required: false,
    example: ['Crear aplicaciones React desde cero', 'Implementar SSR con Next.js'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  learningOutcomes?: string[];

  @ApiProperty({
    description: 'Audiencia objetivo',
    type: [String],
    required: false,
    example: ['Desarrolladores principiantes', 'Estudiantes de programación'],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  targetAudience?: string[];
}
