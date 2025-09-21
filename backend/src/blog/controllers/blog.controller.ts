import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpStatus,
  HttpCode,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Public } from '../../auth/decorators/public.decorator';
import { UserRole } from '../../auth/decorators/user-role.enum';
import { BlogService } from '../services/blog.service';
import { CreateBlogPostDto, UpdateBlogPostDto } from '../dto/create-blog-post.dto';
import { BlogPostQueryDto, RelatedPostsDto } from '../dto/blog-query.dto';
import { BlogPost } from '../entities/blog-post.entity';
import { User } from '../../users/entities/user.entity';

@ApiTags('Blog')
@Controller('blog')
export class BlogController {
  constructor(private readonly blogService: BlogService) {}

  // 🌐 PUBLIC ENDPOINTS (SEO OPTIMIZED)

  @Public()
  @Get()
  @ApiOperation({ 
    summary: 'Get all published blog posts',
    description: 'Retrieve paginated list of published blog posts with advanced filtering for automation content'
  })
  @ApiResponse({ status: 200, description: 'Posts retrieved successfully' })
  async findAll(@Query() query: BlogPostQueryDto) {
    return this.blogService.findAll(query);
  }

  @Public()
  @Get('slug/:slug')
  @ApiOperation({ 
    summary: 'Get blog post by slug',
    description: 'Retrieve a single blog post by its SEO-friendly slug. Increments view count.'
  })
  @ApiResponse({ status: 200, description: 'Post found', type: BlogPost })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async findBySlug(@Param('slug') slug: string): Promise<BlogPost> {
    return this.blogService.findBySlug(slug);
  }

  @Public()
  @Get(':id/related')
  @ApiOperation({ 
    summary: 'Get related posts',
    description: 'Get posts related to the specified post based on category, tags, or automation type'
  })
  @ApiResponse({ status: 200, description: 'Related posts retrieved' })
  async getRelatedPosts(
    @Param('id', ParseUUIDPipe) postId: string,
    @Query() query: Omit<RelatedPostsDto, 'postId'>
  ): Promise<BlogPost[]> {
    return this.blogService.getRelatedPosts({ postId, ...query });
  }

  @Public()
  @Get('top-performing')
  @ApiOperation({ 
    summary: 'Get top performing posts',
    description: 'Get posts with highest conversion rates and engagement'
  })
  @ApiResponse({ status: 200, description: 'Top posts retrieved' })
  async getTopPerformingPosts(@Query('limit') limit?: number): Promise<BlogPost[]> {
    return this.blogService.getTopPerformingPosts(limit);
  }

  @Public()
  @Get('automation/:type')
  @ApiOperation({ 
    summary: 'Get posts by automation type',
    description: 'Get posts filtered by specific automation type (email, CRM, ecommerce, etc.)'
  })
  @ApiResponse({ status: 200, description: 'Posts by automation type retrieved' })
  async getPostsByAutomationType(
    @Param('type') automationType: string,
    @Query('limit') limit?: number
  ): Promise<BlogPost[]> {
    return this.blogService.getPostsByAutomationType(automationType as any, limit);
  }

  // 📊 CONVERSION TRACKING ENDPOINTS

  @Public()
  @Post(':id/track/:event')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ 
    summary: 'Track conversion events',
    description: 'Track user interactions: course clicks, leads generated, purchases'
  })
  @ApiResponse({ status: 204, description: 'Event tracked successfully' })
  async trackConversion(
    @Param('id', ParseUUIDPipe) postId: string,
    @Param('event') event: 'course_click' | 'lead' | 'purchase'
  ): Promise<void> {
    await this.blogService.trackConversion(postId, event);
  }

  // 🔐 ADMIN ENDPOINTS (PROTECTED)

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @Post()
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Create new blog post',
    description: 'Create a new blog post with automation-specific metadata'
  })
  @ApiResponse({ status: 201, description: 'Post created successfully', type: BlogPost })
  @ApiResponse({ status: 400, description: 'Invalid input data' })
  async create(
    @Body() createBlogPostDto: CreateBlogPostDto,
    @CurrentUser() user: User
  ): Promise<BlogPost> {
    return this.blogService.createPost(createBlogPostDto, user.id);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @Put(':id')
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Update blog post',
    description: 'Update existing blog post including performance metrics'
  })
  @ApiResponse({ status: 200, description: 'Post updated successfully', type: BlogPost })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateBlogPostDto: UpdateBlogPostDto
  ): Promise<BlogPost> {
    return this.blogService.updatePost(id, updateBlogPostDto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Delete blog post',
    description: 'Permanently delete a blog post'
  })
  @ApiResponse({ status: 204, description: 'Post deleted successfully' })
  @ApiResponse({ status: 404, description: 'Post not found' })
  async delete(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    await this.blogService.deletePost(id);
  }

  // 📈 ANALYTICS ENDPOINTS

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @Get('analytics/overview')
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get blog analytics overview',
    description: 'Get comprehensive analytics for blog performance'
  })
  async getAnalyticsOverview() {
    // This would be implemented with more detailed analytics
    return {
      message: 'Analytics endpoint - to be implemented with detailed metrics',
      // totalPosts, totalViews, totalConversions, topPosts, etc.
    };
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @Get('seo/performance')
  @ApiBearerAuth()
  @ApiOperation({ 
    summary: 'Get SEO performance metrics',
    description: 'Get SEO metrics: organic traffic, keyword rankings, etc.'
  })
  async getSEOPerformance() {
    return {
      message: 'SEO performance endpoint - to be implemented',
      // organicTraffic, keywordRankings, clickThroughRates, etc.
    };
  }
}
