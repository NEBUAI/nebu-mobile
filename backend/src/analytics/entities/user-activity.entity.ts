import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Lesson } from '../../courses/entities/lesson.entity';

export enum ActivityType {
  COURSE_ENROLLMENT = 'course_enrollment',
  LESSON_START = 'lesson_start',
  LESSON_COMPLETE = 'lesson_complete',
  VIDEO_WATCH = 'video_watch',
  QUIZ_ATTEMPT = 'quiz_attempt',
  ASSIGNMENT_SUBMIT = 'assignment_submit',
  FORUM_POST = 'forum_post',
  RESOURCE_DOWNLOAD = 'resource_download',
  CERTIFICATE_EARNED = 'certificate_earned',
}

@Entity('user_activities')
@Index(['userId', 'activityType'])
@Index(['courseId', 'activityType'])
@Index(['createdAt'])
export class UserActivity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'uuid', nullable: true })
  courseId: string;

  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column({ type: 'uuid', nullable: true })
  lessonId: string;

  @ManyToOne(() => Lesson, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column({
    type: 'enum',
    enum: ActivityType,
  })
  activityType: ActivityType;

  @Column({ type: 'varchar', length: 255, nullable: true })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'text', nullable: true })
  metadata: string; // JSON string for additional data

  @Column({ type: 'int', default: 0 })
  duration: number; // Duration in seconds

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  score: number;

  @Column({ type: 'boolean', default: false })
  isCompleted: boolean;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;
}
