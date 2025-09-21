import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  ManyToMany,
  JoinColumn,
  JoinTable,
  Index,
} from 'typeorm';
import { Transform } from 'class-transformer';
import { User } from '../../users/entities/user.entity';
import { Category } from './category.entity';
import { Lesson } from './lesson.entity';
import { Progress } from '../../progress/entities/progress.entity';
import { Review } from '../../community/entities/review.entity';
import { Purchase } from '../../payments/entities/purchase.entity';
import { CartItem } from '../../payments/entities/cart-item.entity';
import { UserCourseEnrollment } from './user-course-enrollment.entity';
import { CourseMedia } from './course-media.entity';

export enum CourseLevel {
  BEGINNER = 'beginner',
  INTERMEDIATE = 'intermediate',
  ADVANCED = 'advanced',
}

export enum CourseStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

@Entity('courses')
@Index(['status', 'publishedAt'])
@Index(['slug'], { unique: true })
export class Course {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ unique: true })
  slug: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'text', nullable: true })
  shortDescription: string;

  @Column({ nullable: true })
  thumbnail: string;

  @Column({ nullable: true })
  trailer: string;

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0 })
  @Transform(({ value }) => parseFloat(value))
  price: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  @Transform(({ value }) => (value ? parseFloat(value) : null))
  discountPrice: number;

  @Column({
    type: 'enum',
    enum: CourseLevel,
    default: CourseLevel.BEGINNER,
  })
  level: CourseLevel;

  @Column({
    type: 'enum',
    enum: CourseStatus,
    default: CourseStatus.DRAFT,
  })
  status: CourseStatus;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ default: false })
  isFeatured: boolean;

  @Column({ default: false })
  isPublished: boolean;

  @Column({ type: 'timestamptz', nullable: true })
  publishedAt: Date;

  @Column({ type: 'text', array: true, default: [] })
  tags: string[];

  @Column({ type: 'json', nullable: true })
  requirements: string[];

  @Column({ type: 'json', nullable: true })
  learningOutcomes: string[];

  @Column({ type: 'json', nullable: true })
  targetAudience: string[];

  @Column({ default: 0 })
  duration: number; // in minutes

  @Column({ default: 0 })
  lessonsCount: number;

  @Column({ default: 0 })
  studentsCount: number;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  @Transform(({ value }) => parseFloat(value))
  averageRating: number;

  @Column({ default: 0 })
  reviewsCount: number;

  @Column({ default: 0 })
  viewsCount: number;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  // Stripe Integration
  @Column({ nullable: true })
  stripeProductId: string;

  @Column({ nullable: true })
  stripePriceId: string;

  @Column({ type: 'boolean', default: false })
  isStripeEnabled: boolean;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, user => user.instructorCourses)
  @JoinColumn({ name: 'instructorId' })
  instructor: User;

  @Column({ type: 'uuid', nullable: true })
  instructorId: string;

  @ManyToOne(() => Category, category => category.courses)
  @JoinColumn({ name: 'categoryId' })
  category: Category;

  @Column({ type: 'uuid', nullable: true })
  categoryId: string;

  @OneToMany(() => Lesson, lesson => lesson.course, { cascade: true })
  lessons: Lesson[];

  @ManyToMany(() => User)
  @JoinTable({
    name: 'course_students',
    joinColumn: { name: 'courseId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'userId', referencedColumnName: 'id' },
  })
  students: User[];

  @OneToMany(() => Progress, progress => progress.course)
  progress: Progress[];

  @OneToMany(() => Review, review => review.course)
  reviews: Review[];

  @OneToMany(() => Purchase, purchase => purchase.course)
  purchases: Purchase[];

  @OneToMany(() => CartItem, cartItem => cartItem.course)
  cartItems: CartItem[];

  @OneToMany(() => UserCourseEnrollment, enrollment => enrollment.course)
  enrollments: UserCourseEnrollment[];

  @OneToMany(() => CourseMedia, media => media.course)
  media: CourseMedia[];

  // Virtual properties
  get isPublic(): boolean {
    return this.status === CourseStatus.PUBLISHED && this.isPublished;
  }

  get isPaid(): boolean {
    return this.price > 0;
  }

  get hasDiscount(): boolean {
    return this.discountPrice !== null && this.discountPrice < this.price;
  }

  get currentPrice(): number {
    return this.hasDiscount ? this.discountPrice : this.price;
  }
}
