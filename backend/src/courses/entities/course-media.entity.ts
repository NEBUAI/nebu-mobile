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
import { Course } from './course.entity';
import { Lesson } from './lesson.entity';

export enum MediaType {
  VIDEO = 'video',
  IMAGE = 'image',
  DOCUMENT = 'document',
  AUDIO = 'audio',
  THUMBNAIL = 'thumbnail',
}

export enum ProcessingStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Entity('course_media')
@Index(['courseId'])
@Index(['lessonId'])
@Index(['mediaType'])
@Index(['isProcessed'])
export class CourseMedia {
  @PrimaryGeneratedColumn('uuid')
  id: string;

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
    enum: MediaType,
  })
  mediaType: MediaType;

  @Column()
  fileName: string;

  @Column()
  originalName: string;

  @Column()
  filePath: string;

  @Column({ type: 'timestamptz', nullable: true })
  cdnUrl: string;

  @Column({ type: 'bigint', nullable: true })
  fileSize: number;

  @Column({ type: 'timestamptz', nullable: true })
  mimeType: string;

  @Column({ type: 'timestamptz', nullable: true })
  duration: number; // para videos, en segundos

  @Column({ type: 'timestamptz', nullable: true })
  thumbnailUrl: string;

  @Column({ default: false })
  isProcessed: boolean;

  @Column({
    type: 'enum',
    enum: ProcessingStatus,
    default: ProcessingStatus.PENDING,
  })
  processingStatus: ProcessingStatus;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Virtual properties
  get isVideo(): boolean {
    return this.mediaType === MediaType.VIDEO;
  }

  get isImage(): boolean {
    return this.mediaType === MediaType.IMAGE;
  }

  get isDocument(): boolean {
    return this.mediaType === MediaType.DOCUMENT;
  }

  get isAudio(): boolean {
    return this.mediaType === MediaType.AUDIO;
  }

  get isThumbnail(): boolean {
    return this.mediaType === MediaType.THUMBNAIL;
  }

  get fileSizeFormatted(): string {
    if (!this.fileSize) return '0 B';

    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(this.fileSize) / Math.log(1024));
    return `${(this.fileSize / Math.pow(1024, i)).toFixed(2)} ${sizes[i]}`;
  }

  get durationFormatted(): string {
    if (!this.duration) return '00:00';

    const minutes = Math.floor(this.duration / 60);
    const seconds = this.duration % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  get isReady(): boolean {
    return this.isProcessed && this.processingStatus === ProcessingStatus.COMPLETED;
  }
}
