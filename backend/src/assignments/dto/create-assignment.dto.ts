import {
  IsString,
  IsOptional,
  IsEnum,
  IsInt,
  IsBoolean,
  IsDateString,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AssignmentType, AssignmentStatus } from '../entities/assignment.entity';

export class CreateAssignmentDto {
  @ApiProperty({ description: 'Assignment title' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Assignment slug' })
  @IsString()
  slug: string;

  @ApiProperty({ description: 'Assignment description' })
  @IsString()
  description: string;

  @ApiPropertyOptional({ description: 'Assignment instructions' })
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiProperty({ enum: AssignmentType, description: 'Assignment type' })
  @IsEnum(AssignmentType)
  type: AssignmentType;

  @ApiPropertyOptional({ enum: AssignmentStatus, description: 'Assignment status' })
  @IsOptional()
  @IsEnum(AssignmentStatus)
  status?: AssignmentStatus;

  @ApiProperty({ description: 'Course ID' })
  @IsString()
  courseId: string;

  @ApiPropertyOptional({ description: 'Lesson ID' })
  @IsOptional()
  @IsString()
  lessonId?: string;

  @ApiPropertyOptional({ description: 'Assignment points', minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  points?: number;

  @ApiPropertyOptional({ description: 'Due date' })
  @IsOptional()
  @IsDateString()
  dueDate?: string;

  @ApiPropertyOptional({ description: 'Allow late submission' })
  @IsOptional()
  @IsBoolean()
  allowLateSubmission?: boolean;

  @ApiPropertyOptional({ description: 'Late penalty percentage', minimum: 0, maximum: 100 })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  latePenalty?: number;

  @ApiPropertyOptional({ description: 'Maximum submissions (0 = unlimited)', minimum: 0 })
  @IsOptional()
  @IsInt()
  @Min(0)
  maxSubmissions?: number;

  @ApiPropertyOptional({ description: 'Allow resubmission' })
  @IsOptional()
  @IsBoolean()
  allowResubmission?: boolean;

  @ApiPropertyOptional({ description: 'Assignment rubric' })
  @IsOptional()
  @IsString()
  rubric?: string;

  @ApiPropertyOptional({ description: 'File attachments', type: 'array' })
  @IsOptional()
  attachments?: any[];

  @ApiPropertyOptional({ description: 'External resources', type: 'array' })
  @IsOptional()
  resources?: any[];
}
