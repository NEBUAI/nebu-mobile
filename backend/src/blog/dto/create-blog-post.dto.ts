import {
  IsString,
  IsOptional,
  IsEnum,
  IsArray,
  IsNumber,
  IsDateString,
  IsUUID,
  Length,
  Min,
  Max,
  IsDecimal,
} from 'class-validator';
import { Transform } from 'class-transformer';
import { BlogPostStatus, AutomationType } from '../entities/blog-post.entity';

export class CreateBlogPostDto {
  @IsString()
  @Length(1, 255)
  title: string;

  @IsString()
  @Length(1, 255)
  slug: string;

  @IsOptional()
  @IsString()
  excerpt?: string;

  @IsString()
  content: string;

  @IsOptional()
  @IsString()
  metaDescription?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  metaKeywords?: string[];

  @IsOptional()
  @IsString()
  featuredImage?: string;

  @IsOptional()
  @IsString()
  featuredImageAlt?: string;

  @IsOptional()
  @IsEnum(BlogPostStatus)
  status?: BlogPostStatus;

  @IsOptional()
  @IsDateString()
  publishedAt?: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(120)
  readingTime?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  // 🚀 AUTOMATION FIELDS
  @IsOptional()
  @IsEnum(AutomationType)
  automationType?: AutomationType;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  automationTools?: string[];

  @IsOptional()
  @IsString()
  difficultyLevel?: string;

  @IsOptional()
  @IsString()
  implementationTime?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  problemsSolved?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  businessTypes?: string[];

  @IsOptional()
  @IsDecimal({ decimal_digits: '2' })
  @Transform(({ value }) => parseFloat(value))
  estimatedTimeSaved?: number;

  @IsOptional()
  @IsDecimal({ decimal_digits: '2' })
  @Transform(({ value }) => parseFloat(value))
  estimatedCostSaved?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  prerequisites?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  outcomes?: string[];

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  targetKeywords?: string[];

  // RELATIONSHIPS
  @IsOptional()
  @IsUUID()
  categoryId?: string;

  @IsOptional()
  @IsArray()
  @IsUUID('4', { each: true })
  relatedCourseIds?: string[];
}

export class UpdateBlogPostDto extends CreateBlogPostDto {
  @IsOptional()
  @IsNumber()
  @Min(0)
  viewCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  likeCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  shareCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  courseClickCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  leadGeneratedCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  conversionCount?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  organicTraffic?: number;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  averagePosition?: number;
}
