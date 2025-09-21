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
import { QuizAttempt } from './quiz-attempt.entity';
import { QuizQuestion } from './quiz-question.entity';

@Entity('quiz_responses')
@Index(['attemptId', 'questionId'])
export class QuizResponse {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  attemptId: string;

  @Column({ type: 'uuid' })
  questionId: string;

  @Column({ type: 'text', nullable: true })
  answer: string; // for text-based answers

  @Column({ type: 'json', nullable: true })
  selectedAnswers: string[]; // for multiple choice answers

  @Column({ type: 'boolean', nullable: true })
  isCorrect: boolean;

  @Column({ type: 'int', default: 0 })
  points: number;

  @Column({ type: 'int', default: 0 })
  maxPoints: number;

  @Column({ type: 'text', nullable: true })
  feedback: string;

  @Column({ type: 'int', default: 0 })
  timeSpent: number; // in seconds

  @Column({ type: 'timestamp', nullable: true })
  answeredAt: Date;

  @Column({ type: 'json', nullable: true })
  metadata: any; // for additional response data

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => QuizAttempt, attempt => attempt.responses, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'attemptId' })
  attempt: QuizAttempt;

  @ManyToOne(() => QuizQuestion, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'questionId' })
  question: QuizQuestion;
}
