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
import { Course } from './course.entity';

export enum EnrollmentStatus {
  ACTIVE = 'active',
  COMPLETED = 'completed',
  PAUSED = 'paused',
  DROPPED = 'dropped',
}

@Entity('user_course_enrollments')
@Unique(['userId', 'courseId'])
@Index(['userId'])
@Index(['courseId'])
@Index(['status'])
@Index(['enrolledAt'])
export class UserCourseEnrollment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  courseId: string;

  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column({ default: () => 'CURRENT_TIMESTAMP' })
  enrolledAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  lastAccessed: Date;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  completionPercentage: number;

  @Column({
    type: 'enum',
    enum: EnrollmentStatus,
    default: EnrollmentStatus.ACTIVE,
  })
  status: EnrollmentStatus;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Virtual properties
  get isActive(): boolean {
    return this.status === EnrollmentStatus.ACTIVE;
  }

  get isCompleted(): boolean {
    return this.status === EnrollmentStatus.COMPLETED;
  }

  get hasProgress(): boolean {
    return this.completionPercentage > 0;
  }

  get daysSinceEnrollment(): number {
    const now = new Date();
    const diffTime = Math.abs(now.getTime() - this.enrolledAt.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }
}
