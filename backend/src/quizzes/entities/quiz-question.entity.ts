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
import { Quiz } from './quiz.entity';
import { QuizAnswer } from './quiz-answer.entity';

export enum QuestionType {
  MULTIPLE_CHOICE = 'multiple_choice',
  TRUE_FALSE = 'true_false',
  FILL_BLANK = 'fill_blank',
  ESSAY = 'essay',
  MATCHING = 'matching',
  ORDERING = 'ordering',
}

@Entity('quiz_questions')
@Index(['quizId', 'sortOrder'])
export class QuizQuestion {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  quizId: string;

  @Column({ type: 'text' })
  question: string;

  @Column({ type: 'text', nullable: true })
  explanation: string;

  @Column({
    type: 'enum',
    enum: QuestionType,
    default: QuestionType.MULTIPLE_CHOICE,
  })
  type: QuestionType;

  @Column({ type: 'int', default: 1 })
  points: number;

  @Column({ type: 'int', default: 0 })
  sortOrder: number;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'text', nullable: true })
  mediaUrl: string;

  @Column({ type: 'text', nullable: true })
  mediaType: string; // image, video, audio

  @Column({ type: 'json', nullable: true })
  metadata: any; // for additional question-specific data

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => Quiz, quiz => quiz.questions, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'quizId' })
  quiz: Quiz;

  @OneToMany(() => QuizAnswer, answer => answer.question, {
    cascade: true,
  })
  answers: QuizAnswer[];
}
