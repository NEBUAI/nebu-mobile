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
import { QuizQuestion } from './quiz-question.entity';
import { QuizAttempt } from './quiz-attempt.entity';

export enum QuizType {
  MULTIPLE_CHOICE = 'multiple_choice',
  TRUE_FALSE = 'true_false',
  FILL_BLANK = 'fill_blank',
  ESSAY = 'essay',
  MIXED = 'mixed',
}

export enum QuizStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  ARCHIVED = 'archived',
}

@Entity('quizzes')
@Index(['courseId', 'lessonId'])
export class Quiz {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  title: string;

  @Column({ unique: true })
  slug: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: QuizType,
    default: QuizType.MULTIPLE_CHOICE,
  })
  type: QuizType;

  @Column({
    type: 'enum',
    enum: QuizStatus,
    default: QuizStatus.DRAFT,
  })
  status: QuizStatus;

  @Column({ type: 'uuid' })
  courseId: string;

  @Column({ type: 'uuid', nullable: true })
  lessonId: string;

  @Column({ type: 'int', default: 0 })
  timeLimit: number; // in minutes, 0 = no limit

  @Column({ type: 'int', default: 0 })
  maxAttempts: number; // 0 = unlimited

  @Column({ type: 'int', default: 0 })
  passingScore: number; // percentage

  @Column({ type: 'boolean', default: true })
  shuffleQuestions: boolean;

  @Column({ type: 'boolean', default: true })
  shuffleAnswers: boolean;

  @Column({ type: 'boolean', default: false })
  showCorrectAnswers: boolean;

  @Column({ type: 'boolean', default: false })
  showFeedback: boolean;

  @Column({ type: 'boolean', default: false })
  allowReview: boolean;

  @Column({ type: 'int', default: 0 })
  totalQuestions: number;

  @Column({ type: 'int', default: 0 })
  totalPoints: number;

  @Column({ type: 'float', default: 0 })
  averageScore: number;

  @Column({ type: 'int', default: 0 })
  totalAttempts: number;

  @Column({ type: 'int', default: 0 })
  totalCompletions: number;

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

  @OneToMany(() => QuizQuestion, question => question.quiz, {
    cascade: true,
  })
  questions: QuizQuestion[];

  @OneToMany(() => QuizAttempt, attempt => attempt.quiz)
  attempts: QuizAttempt[];
}
