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
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Lesson } from '../../courses/entities/lesson.entity';

export enum CommentStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  HIDDEN = 'hidden',
}

@Entity('comments')
@Index(['courseId', 'createdAt'])
@Index(['lessonId', 'createdAt'])
export class Comment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'text' })
  content: string;

  @Column({
    type: 'enum',
    enum: CommentStatus,
    default: CommentStatus.APPROVED,
  })
  status: CommentStatus;

  @Column({ default: 0 })
  likesCount: number;

  @Column({ default: 0 })
  repliesCount: number;

  @Column({ default: false })
  isPinned: boolean;

  @Column({ type: 'timestamptz', nullable: true })
  parentId: string;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations
  @ManyToOne(() => User, user => user.comments)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  userId: string;

  @ManyToOne(() => Course, { nullable: true })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column({ type: 'timestamptz', nullable: true })
  courseId: string;

  @ManyToOne(() => Lesson, { nullable: true })
  @JoinColumn({ name: 'lessonId' })
  lesson: Lesson;

  @Column({ type: 'timestamptz', nullable: true })
  lessonId: string;

  @ManyToOne(() => Comment, comment => comment.replies)
  @JoinColumn({ name: 'parentId' })
  parent: Comment;

  @OneToMany(() => Comment, comment => comment.parent)
  replies: Comment[];

  // Virtual properties
  get isApproved(): boolean {
    return this.status === CommentStatus.APPROVED;
  }

  get isReply(): boolean {
    return this.parentId !== null;
  }
}
