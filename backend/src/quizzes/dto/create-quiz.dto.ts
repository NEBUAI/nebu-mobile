import { IsString, IsOptional, IsEnum, IsInt, IsBoolean, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { QuizType, QuizStatus } from '../entities/quiz.entity';

export class CreateQuizDto {
  @ApiProperty({ description: 'Quiz title' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Quiz slug' })
  @IsString()
  slug: string;

  @ApiPropertyOptional({ description: 'Quiz description' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ enum: QuizType, description: 'Quiz type' })
  @IsEnum(QuizType)
  type: QuizType;

  @ApiPropertyOptional({ enum: QuizStatus, description: 'Quiz status' })
  @IsOptional()
  @IsEnum(QuizStatus)
  status?: QuizStatus;

  @ApiProperty({ description: 'Course ID' })
  @IsString()
  courseId: string;

  @ApiPropertyOptional({ description: 'Lesson ID' })
  @IsOptional()
  @IsString()
  lessonId?: string;

  @ApiPropertyOptional({ description: 'Time limit in minutes (0 = no limit)', minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  timeLimit?: number;

  @ApiPropertyOptional({ description: 'Maximum attempts (0 = unlimited)', minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  maxAttempts?: number;

  @ApiPropertyOptional({ description: 'Passing score percentage', minimum: 0, maximum: 100 })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  passingScore?: number;

  @ApiPropertyOptional({ description: 'Shuffle questions' })
  @IsOptional()
  @IsBoolean()
  shuffleQuestions?: boolean;

  @ApiPropertyOptional({ description: 'Shuffle answers' })
  @IsOptional()
  @IsBoolean()
  shuffleAnswers?: boolean;

  @ApiPropertyOptional({ description: 'Show correct answers after completion' })
  @IsOptional()
  @IsBoolean()
  showCorrectAnswers?: boolean;

  @ApiPropertyOptional({ description: 'Show feedback after completion' })
  @IsOptional()
  @IsBoolean()
  showFeedback?: boolean;

  @ApiPropertyOptional({ description: 'Allow review after completion' })
  @IsOptional()
  @IsBoolean()
  allowReview?: boolean;
}
