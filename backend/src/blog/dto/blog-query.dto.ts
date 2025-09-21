import {
  IsOptional,
  IsString,
  IsEnum,
  IsNumber,
  IsArray,
  Min,
  Max,
  IsUUID,
} from 'class-validator';
import { Transform, Type } from 'class-transformer';
import { BlogPostStatus, AutomationType } from '../entities/blog-post.entity';

export class BlogPostQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(50)
  limit?: number = 10;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @IsEnum(BlogPostStatus)
  status?: BlogPostStatus;

  @IsOptional()
  @IsUUID()
  categoryId?: string;

  @IsOptional()
  @IsEnum(AutomationType)
  automationType?: AutomationType;

  @IsOptional()
  @IsString()
  difficultyLevel?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => Array.isArray(value) ? value : value.split(','))
  tags?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => Array.isArray(value) ? value : value.split(','))
  automationTools?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => Array.isArray(value) ? value : value.split(','))
  businessTypes?: string[];

  @IsOptional()
  @IsString()
  sortBy?: string = 'publishedAt';

  @IsOptional()
  @IsString()
  sortOrder?: 'ASC' | 'DESC' = 'DESC';

  // SEO and Analytics filters
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  minViews?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  minConversions?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(5)
  minConversionRate?: number;

  // Date filters
  @IsOptional()
  @IsString()
  publishedAfter?: string;

  @IsOptional()
  @IsString()
  publishedBefore?: string;
}

export class BlogPostStatsDto {
  @IsOptional()
  @IsString()
  period?: 'week' | 'month' | 'quarter' | 'year' = 'month';

  @IsOptional()
  @IsEnum(AutomationType)
  automationType?: AutomationType;

  @IsOptional()
  @IsUUID()
  categoryId?: string;
}

export class RelatedPostsDto {
  @IsUUID()
  postId: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(10)
  limit?: number = 5;

  @IsOptional()
  @IsString()
  relationType?: 'category' | 'tags' | 'automation' | 'all' = 'all';
}
