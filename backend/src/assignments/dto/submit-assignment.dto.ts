import { IsString, IsOptional, IsArray, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SubmitAssignmentDto {
  @ApiProperty({ description: 'Assignment ID' })
  @IsString()
  assignmentId: string;

  @ApiProperty({ description: 'User ID' })
  @IsString()
  userId: string;

  @ApiProperty({ description: 'Submission content' })
  @IsString()
  content: string;

  @ApiPropertyOptional({ description: 'File attachments', type: 'array' })
  @IsOptional()
  @IsArray()
  attachments?: any[];

  @ApiPropertyOptional({ description: 'Additional notes' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Additional metadata', type: 'object' })
  @IsOptional()
  @IsObject()
  metadata?: any;
}
