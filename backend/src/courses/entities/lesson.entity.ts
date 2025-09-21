import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
  Index,
} from 'typeorm';
import { Course } from './course.entity';
import { Progress } from '../../progress/entities/progress.entity';
import { CourseMedia } from './course-media.entity';

export enum LessonType {
  VIDEO = 'video',
  TEXT = 'text',
  QUIZ = 'quiz',
  ASSIGNMENT = 'assignment',
  LIVE = 'live',
  DOCUMENT = 'document',
}

export enum LessonStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

@Entity('lessons')
@Index(['courseId', 'sortOrder'])
export class Lesson {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ unique: true })
  slug: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'text', nullable: true })
  content: string;

  @Column({
    type: 'enum',
    enum: LessonType,
    default: LessonType.VIDEO,
  })
  type: LessonType;

  @Column({
    type: 'enum',
    enum: LessonStatus,
    default: LessonStatus.DRAFT,
  })
  status: LessonStatus;

  @Column({ default: 0 })
  sortOrder: number;

  @Column({ default: 0 })
  duration: number; // in seconds

  @Column({ type: 'timestamptz', nullable: true })
  videoUrl: string;

  @Column({ type: 'timestamptz', nullable: true })
  videoProvider: string; // youtube, vimeo, custom

  @Column({ type: 'timestamptz', nullable: true })
  thumbnail: string;

  @Column({ default: false })
  isPreview: boolean;

  @Column({ default: false })
  isRequired: boolean;

  @Column({ type: 'json', nullable: true })
  resources: Array<{
    name: string;
    url: string;
    type: string;
    size?: number;
  }>;

  @Column({ type: 'json', nullable: true })
  quiz: {
    questions: Array<{
      id: string;
      question: string;
      type: 'multiple_choice' | 'true_false' | 'text';
      options?: string[];
      correctAnswer: string | string[];
      explanation?: string;
    }>;
    passingScore?: number;
  };

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Course, course => course.lessons, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column()
  courseId: string;

  @OneToMany(() => Progress, progress => progress.lesson)
  progress: Progress[];

  @OneToMany(() => CourseMedia, media => media.lesson)
  media: CourseMedia[];

  // Virtual properties
  get isPublished(): boolean {
    return this.status === LessonStatus.PUBLISHED;
  }

  get hasVideo(): boolean {
    return this.type === LessonType.VIDEO && !!this.videoUrl;
  }

  get hasQuiz(): boolean {
    return this.type === LessonType.QUIZ && !!this.quiz;
  }
}
