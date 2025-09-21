import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum, Min, Max } from 'class-validator';

export enum ReviewStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  HIDDEN = 'hidden',
}

export class CreateReviewDto {
  @ApiProperty({
    description: 'Calificación del curso (1-5 estrellas)',
    example: 5,
    minimum: 1,
    maximum: 5,
  })
  @IsNumber()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiPropertyOptional({
    description: 'Comentario de la reseña',
    example: 'Curso excelente, muy bien explicado y con ejemplos prácticos.',
  })
  @IsString()
  @IsOptional()
  comment?: string;

  @ApiProperty({
    description: 'ID del curso',
    example: 'uuid-string-here',
  })
  @IsString()
  courseId: string;

  @ApiPropertyOptional({
    description: 'Estado de la reseña',
    enum: ReviewStatus,
    example: ReviewStatus.PENDING,
    default: ReviewStatus.PENDING,
  })
  @IsEnum(ReviewStatus)
  @IsOptional()
  status?: ReviewStatus;
}
