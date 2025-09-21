import {
  Injectable,
  NotFoundException,
  BadRequestException,
  Logger,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, SelectQueryBuilder, In } from 'typeorm';
import { BlogPost, BlogPostStatus, AutomationType } from '../entities/blog-post.entity';
import { BlogCategory } from '../entities/blog-category.entity';
import { Course } from '../../courses/entities/course.entity';
import { CreateBlogPostDto, UpdateBlogPostDto } from '../dto/create-blog-post.dto';
import { BlogPostQueryDto, RelatedPostsDto } from '../dto/blog-query.dto';

@Injectable()
export class BlogService {
  private readonly logger = new Logger(BlogService.name);

  constructor(
    @InjectRepository(BlogPost)
    private readonly blogPostRepository: Repository<BlogPost>,
    @InjectRepository(BlogCategory)
    private readonly blogCategoryRepository: Repository<BlogCategory>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>,
  ) {}

  // 🚀 CREATE BLOG POST WITH AUTOMATION MAGIC
  async createPost(createBlogPostDto: CreateBlogPostDto, authorId: string): Promise<BlogPost> {
    const { relatedCourseIds, ...postData } = createBlogPostDto;

    // Check if slug is unique
    const existingPost = await this.blogPostRepository.findOne({
      where: { slug: postData.slug },
    });

    if (existingPost) {
      throw new BadRequestException('Slug already exists');
    }

    // Create the post
    const post = this.blogPostRepository.create({
      ...postData,
      authorId,
    });

    // Add related courses if provided
    if (relatedCourseIds && relatedCourseIds.length > 0) {
      const courses = await this.courseRepository.find({
        where: { id: In(relatedCourseIds) },
      });
      post.relatedCourses = courses;
    }

    // Auto-calculate reading time if not provided
    if (!post.readingTime && post.content) {
      post.readingTime = this.calculateReadingTime(post.content);
    }

    const savedPost = await this.blogPostRepository.save(post);
    
    this.logger.log(`Created blog post: ${savedPost.title} (${savedPost.id})`);
    
    return this.findBySlug(savedPost.slug);
  }

  // 📊 FIND POSTS WITH ADVANCED FILTERING (SEO OPTIMIZED)
  async findAll(query: BlogPostQueryDto) {
    const {
      page = 1,
      limit = 10,
      search,
      status = BlogPostStatus.PUBLISHED,
      categoryId,
      automationType,
      difficultyLevel,
      tags,
      automationTools,
      businessTypes,
      sortBy = 'publishedAt',
      sortOrder = 'DESC',
      minViews,
      minConversions,
      publishedAfter,
      publishedBefore,
    } = query;

    const queryBuilder = this.blogPostRepository
      .createQueryBuilder('post')
      .leftJoinAndSelect('post.category', 'category')
      .leftJoinAndSelect('post.author', 'author')
      .leftJoinAndSelect('post.relatedCourses', 'courses');

    // Status filter (always apply for public endpoints)
    queryBuilder.where('post.status = :status', { status });

    // Published date range
    if (status === BlogPostStatus.PUBLISHED) {
      queryBuilder.andWhere('post.publishedAt <= :now', { now: new Date() });
    }

    // Search functionality
    if (search) {
      queryBuilder.andWhere(
        '(post.title LIKE :search OR post.excerpt LIKE :search OR post.content LIKE :search OR post.tags LIKE :search)',
        { search: `%${search}%` }
      );
    }

    // Category filter
    if (categoryId) {
      queryBuilder.andWhere('post.categoryId = :categoryId', { categoryId });
    }

    // Automation type filter
    if (automationType) {
      queryBuilder.andWhere('post.automationType = :automationType', { automationType });
    }

    // Difficulty level filter
    if (difficultyLevel) {
      queryBuilder.andWhere('post.difficultyLevel = :difficultyLevel', { difficultyLevel });
    }

    // Tags filter (any of the provided tags)
    if (tags && tags.length > 0) {
      const tagConditions = tags.map((_, index) => `post.tags LIKE :tag${index}`);
      queryBuilder.andWhere(`(${tagConditions.join(' OR ')})`, 
        tags.reduce((acc, tag, index) => ({ ...acc, [`tag${index}`]: `%${tag}%` }), {})
      );
    }

    // Automation tools filter
    if (automationTools && automationTools.length > 0) {
      const toolConditions = automationTools.map((_, index) => `post.automationTools LIKE :tool${index}`);
      queryBuilder.andWhere(`(${toolConditions.join(' OR ')})`, 
        automationTools.reduce((acc, tool, index) => ({ ...acc, [`tool${index}`]: `%${tool}%` }), {})
      );
    }

    // Business types filter
    if (businessTypes && businessTypes.length > 0) {
      const businessConditions = businessTypes.map((_, index) => `post.businessTypes LIKE :business${index}`);
      queryBuilder.andWhere(`(${businessConditions.join(' OR ')})`, 
        businessTypes.reduce((acc, type, index) => ({ ...acc, [`business${index}`]: `%${type}%` }), {})
      );
    }

    // Performance filters
    if (minViews) {
      queryBuilder.andWhere('post.viewCount >= :minViews', { minViews });
    }

    if (minConversions) {
      queryBuilder.andWhere('post.conversionCount >= :minConversions', { minConversions });
    }

    // Date range filters
    if (publishedAfter) {
      queryBuilder.andWhere('post.publishedAt >= :publishedAfter', { publishedAfter });
    }

    if (publishedBefore) {
      queryBuilder.andWhere('post.publishedAt <= :publishedBefore', { publishedBefore });
    }

    // Sorting
    const validSortFields = ['publishedAt', 'viewCount', 'likeCount', 'conversionRate', 'title'];
    const sortField = validSortFields.includes(sortBy) ? sortBy : 'publishedAt';
    queryBuilder.orderBy(`post.${sortField}`, sortOrder);

    // Pagination
    const offset = (page - 1) * limit;
    queryBuilder.skip(offset).take(limit);

    const [posts, total] = await queryBuilder.getManyAndCount();

    return {
      posts,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  // 🎯 FIND BY SLUG (SEO OPTIMIZED)
  async findBySlug(slug: string): Promise<BlogPost> {
    const post = await this.blogPostRepository.findOne({
      where: { slug },
      relations: ['category', 'author', 'relatedCourses', 'comments'],
    });

    if (!post) {
      throw new NotFoundException(`Blog post with slug "${slug}" not found`);
    }

    // Increment view count
    await this.incrementViewCount(post.id);

    return post;
  }

  // 🔗 GET RELATED POSTS (CONVERSION OPTIMIZATION)
  async getRelatedPosts(dto: RelatedPostsDto): Promise<BlogPost[]> {
    const { postId, limit = 5, relationType = 'all' } = dto;

    const post = await this.blogPostRepository.findOne({
      where: { id: postId },
      relations: ['category'],
    });

    if (!post) {
      throw new NotFoundException('Post not found');
    }

    const queryBuilder = this.blogPostRepository
      .createQueryBuilder('post')
      .leftJoinAndSelect('post.category', 'category')
      .leftJoinAndSelect('post.author', 'author')
      .where('post.id != :postId', { postId })
      .andWhere('post.status = :status', { status: BlogPostStatus.PUBLISHED })
      .andWhere('post.publishedAt <= :now', { now: new Date() });

    switch (relationType) {
      case 'category':
        if (post.categoryId) {
          queryBuilder.andWhere('post.categoryId = :categoryId', { categoryId: post.categoryId });
        }
        break;
      
      case 'automation':
        if (post.automationType) {
          queryBuilder.andWhere('post.automationType = :automationType', { 
            automationType: post.automationType 
          });
        }
        break;
      
      case 'tags':
        if (post.tags && post.tags.length > 0) {
          const tagConditions = post.tags.map((_, index) => `post.tags LIKE :tag${index}`);
          queryBuilder.andWhere(`(${tagConditions.join(' OR ')})`, 
            post.tags.reduce((acc, tag, index) => ({ ...acc, [`tag${index}`]: `%${tag}%` }), {})
          );
        }
        break;
      
      default: // 'all' - use multiple criteria
        const conditions = [];
        const parameters: any = {};
        
        if (post.categoryId) {
          conditions.push('post.categoryId = :categoryId');
          parameters.categoryId = post.categoryId;
        }
        
        if (post.automationType) {
          conditions.push('post.automationType = :automationType');
          parameters.automationType = post.automationType;
        }
        
        if (conditions.length > 0) {
          queryBuilder.andWhere(`(${conditions.join(' OR ')})`, parameters);
        }
        break;
    }

    return queryBuilder
      .orderBy('post.viewCount', 'DESC')
      .addOrderBy('post.publishedAt', 'DESC')
      .limit(limit)
      .getMany();
  }

  // 📈 TRACK CONVERSION EVENTS
  async trackConversion(postId: string, conversionType: 'course_click' | 'lead' | 'purchase'): Promise<void> {
    const post = await this.blogPostRepository.findOne({ where: { id: postId } });
    
    if (!post) {
      throw new NotFoundException('Post not found');
    }

    switch (conversionType) {
      case 'course_click':
        post.courseClickCount++;
        break;
      case 'lead':
        post.leadGeneratedCount++;
        break;
      case 'purchase':
        post.conversionCount++;
        break;
    }

    // Recalculate conversion rate
    if (post.viewCount > 0) {
      post.conversionRate = (post.conversionCount / post.viewCount) * 100;
    }

    await this.blogPostRepository.save(post);
    
    this.logger.log(`Tracked ${conversionType} for post: ${post.title}`);
  }

  // 🔥 GET TOP PERFORMING POSTS
  async getTopPerformingPosts(limit: number = 10): Promise<BlogPost[]> {
    return this.blogPostRepository.find({
      where: { status: BlogPostStatus.PUBLISHED },
      relations: ['category', 'author'],
      order: { conversionRate: 'DESC', viewCount: 'DESC' },
      take: limit,
    });
  }

  // 🎯 GET POSTS BY AUTOMATION TYPE (FOR COURSE RECOMMENDATIONS)
  async getPostsByAutomationType(automationType: AutomationType, limit: number = 5): Promise<BlogPost[]> {
    return this.blogPostRepository.find({
      where: { 
        automationType,
        status: BlogPostStatus.PUBLISHED,
      },
      relations: ['category', 'author', 'relatedCourses'],
      order: { publishedAt: 'DESC' },
      take: limit,
    });
  }

  // HELPER METHODS
  private async incrementViewCount(postId: string): Promise<void> {
    await this.blogPostRepository.increment({ id: postId }, 'viewCount', 1);
  }

  private calculateReadingTime(content: string): number {
    const wordsPerMinute = 200;
    const wordCount = content.split(/\s+/).length;
    return Math.ceil(wordCount / wordsPerMinute);
  }

  // UPDATE AND DELETE METHODS
  async updatePost(id: string, updateBlogPostDto: UpdateBlogPostDto): Promise<BlogPost> {
    const { relatedCourseIds, ...updateData } = updateBlogPostDto;

    const post = await this.blogPostRepository.findOne({ where: { id } });
    if (!post) {
      throw new NotFoundException('Post not found');
    }

    // Update related courses if provided
    if (relatedCourseIds !== undefined) {
      if (relatedCourseIds.length > 0) {
        const courses = await this.courseRepository.find({
          where: { id: In(relatedCourseIds) },
        });
        post.relatedCourses = courses;
      } else {
        post.relatedCourses = [];
      }
    }

    Object.assign(post, updateData);

    const updatedPost = await this.blogPostRepository.save(post);
    return this.blogPostRepository.findOne({
      where: { id },
      relations: ['category', 'author', 'relatedCourses'],
    });
  }

  async deletePost(id: string): Promise<void> {
    const result = await this.blogPostRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('Post not found');
    }
  }
}
