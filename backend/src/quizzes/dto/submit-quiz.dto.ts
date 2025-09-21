import { IsString, IsOptional, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SubmitQuizDto {
  @ApiProperty({ description: 'Quiz ID' })
  @IsString()
  quizId: string;

  @ApiProperty({ description: 'User ID' })
  @IsString()
  userId: string;

  @ApiProperty({ description: 'Quiz responses', type: 'object' })
  @IsObject()
  responses: Record<string, any>; // questionId -> answer

  @ApiPropertyOptional({ description: 'Time spent in seconds' })
  @IsOptional()
  timeSpent?: number;

  @ApiPropertyOptional({ description: 'Additional notes' })
  @IsOptional()
  @IsString()
  notes?: string;
}
