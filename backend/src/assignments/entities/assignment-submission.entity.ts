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
import { Assignment } from './assignment.entity';

export enum SubmissionStatus {
  DRAFT = 'draft',
  SUBMITTED = 'submitted',
  GRADED = 'graded',
  RETURNED = 'returned',
  LATE = 'late',
}

@Entity('assignment_submissions')
@Index(['userId', 'assignmentId'])
@Index(['assignmentId', 'status'])
export class AssignmentSubmission {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @Column({ type: 'uuid' })
  assignmentId: string;

  @Column({ type: 'text' })
  content: string;

  @Column({
    type: 'enum',
    enum: SubmissionStatus,
    default: SubmissionStatus.DRAFT,
  })
  status: SubmissionStatus;

  @Column({ type: 'int', default: 0 })
  score: number;

  @Column({ type: 'int', default: 0 })
  maxScore: number;

  @Column({ type: 'float', default: 0 })
  percentage: number;

  @Column({ type: 'text', nullable: true })
  feedback: string;

  @Column({ type: 'json', nullable: true })
  attachments: any[]; // file attachments

  @Column({ type: 'json', nullable: true })
  rubric: any; // rubric scores

  @Column({ type: 'boolean', default: false })
  isLate: boolean;

  @Column({ type: 'int', default: 0 })
  latePenalty: number; // percentage

  @Column({ type: 'timestamp', nullable: true })
  submittedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  gradedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  returnedAt: Date;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ type: 'json', nullable: true })
  metadata: any; // additional submission data

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Assignment, assignment => assignment.submissions, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'assignmentId' })
  assignment: Assignment;
}
