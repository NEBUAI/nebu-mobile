import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  ManyToMany,
  JoinTable,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { BlogComment } from './blog-comment.entity';
import { BlogCategory } from './blog-category.entity';

export enum BlogPostStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  SCHEDULED = 'scheduled',
  ARCHIVED = 'archived',
}

export enum AutomationType {
  EMAIL_MARKETING = 'email_marketing',
  CRM_AUTOMATION = 'crm_automation',
  ECOMMERCE = 'ecommerce',
  SOCIAL_MEDIA = 'social_media',
  LEAD_GENERATION = 'lead_generation',
  DATA_PROCESSING = 'data_processing',
  CUSTOMER_SERVICE = 'customer_service',
  WORKFLOW_OPTIMIZATION = 'workflow_optimization',
}

@Entity('blog_posts')
@Index(['slug'])
@Index(['status', 'publishedAt'])
@Index(['categoryId', 'status'])
@Index(['automationType', 'status'])
export class BlogPost {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  title: string;

  @Column({ unique: true, length: 255 })
  slug: string;

  @Column({ type: 'text', nullable: true })
  excerpt: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ type: 'text', nullable: true })
  metaDescription: string;

  @Column({ type: 'simple-array', nullable: true })
  metaKeywords: string[];

  @Column({ type: 'timestamptz', nullable: true })
  featuredImage: string;

  @Column({ type: 'timestamptz', nullable: true })
  featuredImageAlt: string;

  @Column({
    type: 'enum',
    enum: BlogPostStatus,
    default: BlogPostStatus.DRAFT,
  })
  status: BlogPostStatus;

  @Column({ type: 'timestamp without time zone', nullable: true })
  publishedAt: Date;

  @Column({ default: 0 })
  viewCount: number;

  @Column({ default: 0 })
  likeCount: number;

  @Column({ default: 0 })
  shareCount: number;

  @Column({ default: 0 })
  commentCount: number;

  @Column({ type: 'int', nullable: true })
  readingTime: number; // in minutes

  @Column({ type: 'simple-array', nullable: true })
  tags: string[];

  // 🚀 AUTOMATION-SPECIFIC FIELDS (This is where the magic happens!)
  @Column({
    type: 'enum',
    enum: AutomationType,
    nullable: true,
  })
  automationType: AutomationType;

  @Column({ type: 'simple-array', nullable: true })
  automationTools: string[]; // ['Zapier', 'Make', 'Power Automate']

  @Column({ type: 'timestamptz', nullable: true })
  difficultyLevel: string; // 'Beginner', 'Intermediate', 'Advanced'

  @Column({ type: 'timestamptz', nullable: true })
  implementationTime: string; // '30 minutes', '2 hours', '1 day'

  @Column({ type: 'simple-array', nullable: true })
  problemsSolved: string[]; // What specific problems this solves

  @Column({ type: 'simple-array', nullable: true })
  businessTypes: string[]; // ['Small Business', 'E-commerce', 'Freelancer', 'Agency']

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  estimatedTimeSaved: number; // Hours saved per week/month

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  estimatedCostSaved: number; // Money saved per month

  @Column({ type: 'simple-array', nullable: true })
  prerequisites: string[]; // What you need before starting

  @Column({ type: 'simple-array', nullable: true })
  outcomes: string[]; // What you'll achieve after implementation

  // 💰 CONVERSION TRACKING FIELDS
  @Column({ default: 0 })
  courseClickCount: number; // How many clicked to related courses

  @Column({ default: 0 })
  leadGeneratedCount: number; // How many leads this post generated

  @Column({ default: 0 })
  conversionCount: number; // How many actual sales/enrollments

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  conversionRate: number; // Conversion percentage

  // 📊 SEO PERFORMANCE FIELDS
  @Column({ type: 'simple-array', nullable: true })
  targetKeywords: string[]; // Primary keywords we're targeting

  @Column({ type: 'int', default: 0 })
  organicTraffic: number; // Monthly organic traffic

  @Column({ type: 'int', nullable: true })
  averagePosition: number; // Average Google ranking position

  // RELATIONSHIPS
  @Column({ type: 'uuid' })
  authorId: string;

  @ManyToOne(() => User, { eager: true })
  @JoinColumn({ name: 'authorId' })
  author: User;

  @Column({ type: 'uuid', nullable: true })
  categoryId: string;

  @ManyToOne(() => BlogCategory, (category) => category.posts, { eager: true })
  @JoinColumn({ name: 'categoryId' })
  category: BlogCategory;

  @OneToMany(() => BlogComment, (comment) => comment.post, { cascade: true })
  comments: BlogComment[];

  @ManyToMany(() => Course, { eager: false })
  @JoinTable({
    name: 'blog_post_related_courses',
    joinColumn: { name: 'blogPostId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'courseId', referencedColumnName: 'id' },
  })
  relatedCourses: Course[];

  @CreateDateColumn({ type: 'timestamp without time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp without time zone' })
  updatedAt: Date;

  // 🔥 VIRTUAL FIELDS AND METHODS
  get url(): string {
    return `/blog/${this.slug}`;
  }

  get isPublished(): boolean {
    return (
      this.status === BlogPostStatus.PUBLISHED &&
      this.publishedAt &&
      new Date(this.publishedAt) <= new Date()
    );
  }

  get ctaText(): string {
    switch (this.automationType) {
      case AutomationType.EMAIL_MARKETING:
        return 'Domina el Email Marketing Automation';
      case AutomationType.CRM_AUTOMATION:
        return 'Automatiza tu CRM como un Pro';
      case AutomationType.ECOMMERCE:
        return 'Optimiza tu E-commerce con Automatización';
      default:
        return 'Aprende Automatización Profesional';
    }
  }

  get estimatedROI(): string {
    if (this.estimatedTimeSaved && this.estimatedCostSaved) {
      const monthlyValue = (this.estimatedTimeSaved * 25) + this.estimatedCostSaved; // $25/hour
      return `$${monthlyValue.toFixed(0)}/mes`;
    }
    return 'ROI calculable tras implementación';
  }
}
