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
import { Course } from '../../courses/entities/course.entity';
import { Lesson } from '../../courses/entities/lesson.entity';
import { AssignmentSubmission } from './assignment-submission.entity';

export enum AssignmentType {
  ESSAY = 'essay',
  PROJECT = 'project',
  PRESENTATION = 'presentation',
  CODE = 'code',
  MEDIA = 'media',
  MIXED = 'mixed',
}

export enum AssignmentStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

@Entity('assignments')
@Index(['courseId', 'lessonId'])
export class Assignment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ unique: true })
  slug: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'text', nullable: true })
  instructions: string;

  @Column({
    type: 'enum',
    enum: AssignmentType,
    default: AssignmentType.ESSAY,
  })
  type: AssignmentType;

  @Column({
    type: 'enum',
    enum: AssignmentStatus,
    default: AssignmentStatus.DRAFT,
  })
  status: AssignmentStatus;

  @Column({ type: 'uuid' })
  courseId: string;

  @Column({ type: 'uuid', nullable: true })
  lessonId: string;

  @Column({ type: 'int', default: 0 })
  points: number;

  @Column({ type: 'timestamp', nullable: true })
  dueDate: Date;

  @Column({ type: 'boolean', default: false })
  allowLateSubmission: boolean;

  @Column({ type: 'int', default: 0 })
  latePenalty: number; // percentage

  @Column({ type: 'int', default: 0 })
  maxSubmissions: number; // 0 = unlimited

  @Column({ type: 'boolean', default: true })
  allowResubmission: boolean;

  @Column({ type: 'text', nullable: true })
  rubric: string;

  @Column({ type: 'json', nullable: true })
  attachments: any[]; // file attachments

  @Column({ type: 'json', nullable: true })
  resources: any[]; // external resources

  @Column({ type: 'int', default: 0 })
  totalSubmissions: number;

  @Column({ type: 'float', default: 0 })
  averageScore: number;

  @Column({ type: 'int', default: 0 })
  totalGraded: number;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @ManyToOne(() => Lesson, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @OneToMany(() => AssignmentSubmission, submission => submission.assignment)
  submissions: AssignmentSubmission[];
}
