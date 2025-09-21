import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';

export enum CommentStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  HIDDEN = 'hidden',
}

export class CreateCommentDto {
  @ApiProperty({
    description: 'Contenido del comentario',
    example: '¡Excelente lección! Me ayudó mucho a entender React.',
  })
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiProperty({
    description: 'ID del curso',
    example: 'uuid-string-here',
  })
  @IsString()
  courseId: string;

  @ApiPropertyOptional({
    description: 'ID de la lección específica (opcional)',
    example: 'uuid-string-here',
  })
  @IsString()
  @IsOptional()
  lessonId?: string;

  @ApiPropertyOptional({
    description: 'ID del comentario padre (para respuestas)',
    example: 'uuid-string-here',
  })
  @IsString()
  @IsOptional()
  parentId?: string;

  @ApiPropertyOptional({
    description: 'Estado del comentario',
    enum: CommentStatus,
    example: CommentStatus.PENDING,
    default: CommentStatus.PENDING,
  })
  @IsEnum(CommentStatus)
  @IsOptional()
  status?: CommentStatus;
}
