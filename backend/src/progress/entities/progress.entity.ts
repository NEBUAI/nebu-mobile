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
  FAILED = 'failed',
}

@Entity('progress')
@Unique(['userId', 'courseId', 'lessonId'])
@Index(['userId', 'courseId'])
@Index(['completedAt'])
export class Progress {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({
    type: 'enum',
    enum: ProgressStatus,
    default: ProgressStatus.NOT_STARTED,
  })
  status: ProgressStatus;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  completionPercentage: number;

  @Column({ default: 0 })
  timeSpent: number; // in seconds

  @Column({ default: 0 })
  watchTime: number; // for video lessons, in seconds

  @Column({ type: 'timestamptz', nullable: true })
  lastPosition: number; // for video lessons, last watched position in seconds

  @Column({ type: 'timestamptz', nullable: true })
  score: number; // for quizzes/assignments

  @Column({ default: 0 })
  attempts: number;

  @Column({ type: 'timestamptz', nullable: true })
  completedAt: Date;

  @Column({ type: 'timestamptz', nullable: true })
  startedAt: Date;

  @Column({ type: 'json', nullable: true })
  answers: Record<string, any>; // for quizzes/assignments

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, user => user.progress)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @ManyToOne(() => Course, course => course.progress)
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column()
  courseId: string;

  @ManyToOne(() => Lesson, lesson => lesson.progress)
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column()
  lessonId: string;

  // Virtual properties
  get isCompleted(): boolean {
    return this.status === ProgressStatus.COMPLETED;
  }

  get isInProgress(): boolean {
    return this.status === ProgressStatus.IN_PROGRESS;
  }

  get isPassed(): boolean {
    return this.score !== null && this.score >= 70; // 70% passing score
  }
}
