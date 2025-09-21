import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';

export enum ReviewStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  HIDDEN = 'hidden',
}

@Entity('reviews')
@Unique(['userId', 'courseId'])
@Index(['courseId', 'rating'])
@Index(['createdAt'])
export class Review {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'int', width: 1 })
  rating: number; // 1-5 stars

  @Column({ type: 'text', nullable: true })
  comment: string;

  @Column({
    type: 'enum',
    enum: ReviewStatus,
    default: ReviewStatus.PENDING,
  })
  status: ReviewStatus;

  @Column({ default: 0 })
  helpfulCount: number;

  @Column({ default: false })
  isVerifiedPurchase: boolean;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, user => user.reviews)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @ManyToOne(() => Course, course => course.reviews)
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column()
  courseId: string;

  // Virtual properties
  get isApproved(): boolean {
    return this.status === ReviewStatus.APPROVED;
  }

  get isPositive(): boolean {
    return this.rating >= 4;
  }

  get isNegative(): boolean {
    return this.rating <= 2;
  }
}
