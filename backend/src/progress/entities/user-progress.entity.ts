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
import { Lesson } from '../../courses/entities/lesson.entity';

export enum ProgressStatus {
  NOT_STARTED = 'not_started',
  IN_PROGRESS = 'in_progress',
  COMPLETED = 'completed',
  PAUSED = 'paused',
}

@Entity('user_progress')
@Unique(['userId', 'courseId'])
@Index(['userId', 'courseId'])
@Index(['courseId'])
@Index(['lastAccessed'])
export class UserProgress {
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

  @Column({ type: 'timestamptz', nullable: true })
  lessonId: string;

  @ManyToOne(() => Lesson, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column({
    type: 'enum',
    enum: ProgressStatus,
    default: ProgressStatus.NOT_STARTED,
  })
  status: ProgressStatus;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  completionPercentage: number;

  @Column({ default: false })
  isEnrolled: boolean;

  @Column({ type: 'timestamptz', nullable: true })
  lastAccessed: Date;

  @Column({ default: 0 })
  completedLessons: number;

  @Column({ default: 0 })
  totalLessons: number;

  @Column({ default: 0 })
  slidesCount: number;

  @Column({ default: 0 })
  timeSpent: number; // en segundos

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Virtual properties
  get isCompleted(): boolean {
    return this.status === ProgressStatus.COMPLETED;
  }

  get isInProgress(): boolean {
    return this.status === ProgressStatus.IN_PROGRESS;
  }

  get completionRate(): number {
    if (this.totalLessons === 0) return 0;
    return Math.round((this.completedLessons / this.totalLessons) * 100);
  }

  get hasProgress(): boolean {
    return this.completionPercentage > 0 || this.completedLessons > 0;
  }
}
