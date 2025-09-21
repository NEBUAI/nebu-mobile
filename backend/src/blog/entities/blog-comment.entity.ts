import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Tree,
  TreeParent,
  TreeChildren,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { BlogPost } from './blog-post.entity';

export enum CommentStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  SPAM = 'spam',
  REJECTED = 'rejected',
}

@Entity('blog_comments')
@Tree('nested-set')
@Index(['postId', 'status'])
@Index(['userId', 'status'])
export class BlogComment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'text' })
  content: string;

  @Column({
    type: 'enum',
    enum: CommentStatus,
    default: CommentStatus.PENDING,
  })
  status: CommentStatus;

  @Column({ default: 0 })
  likeCount: number;

  @Column({ default: 0 })
  dislikeCount: number;

  // For guest comments (if user not logged in)
  @Column({ type: 'timestamptz', nullable: true })
  guestName: string;

  @Column({ type: 'timestamptz', nullable: true })
  guestEmail: string;

  @Column({ type: 'timestamptz', nullable: true })
  guestWebsite: string;

  // Spam detection fields
  @Column({ type: 'timestamptz', nullable: true })
  ipAddress: string;

  @Column({ type: 'timestamptz', nullable: true })
  userAgent: string;

  @Column({ default: false })
  isSpam: boolean;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 0 })
  spamScore: number; // 0.00 to 1.00

  // RELATIONSHIPS
  @Column({ type: 'uuid' })
  postId: string;

  @ManyToOne(() => BlogPost, (post) => post.comments, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'postId' })
  post: BlogPost;

  @Column({ type: 'uuid', nullable: true })
  userId: string;

  @ManyToOne(() => User, { eager: true, nullable: true })
  @JoinColumn({ name: 'userId' })
  user: User;

  // Tree structure for nested comments
  @TreeParent()
  parent: BlogComment;

  @TreeChildren()
  children: BlogComment[];

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Virtual fields
  get authorName(): string {
    return this.user ? `${this.user.firstName} ${this.user.lastName}` : this.guestName || 'Anonymous';
  }

  get authorEmail(): string {
    return this.user?.email || this.guestEmail || '';
  }

  get isGuest(): boolean {
    return !this.userId;
  }

  get isApproved(): boolean {
    return this.status === CommentStatus.APPROVED;
  }

  get netVotes(): number {
    return this.likeCount - this.dislikeCount;
  }
}
