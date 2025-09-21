import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  Unique,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';

export enum PurchaseStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
  PARTIALLY_REFUNDED = 'partially_refunded',
}

export enum PaymentMethod {
  STRIPE = 'stripe',
  PAYPAL = 'paypal',
  BANK_TRANSFER = 'bank_transfer',
  FREE = 'free',
}

@Entity('purchases')
@Unique(['userId', 'courseId'])
@Index(['userId', 'status'])
@Index(['courseId', 'status'])
@Index(['stripePaymentIntentId'], { unique: true })
export class Purchase {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  courseId: string;

  @ManyToOne(() => Course, course => course.purchases, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column({
    type: 'enum',
    enum: PurchaseStatus,
    default: PurchaseStatus.PENDING,
  })
  status: PurchaseStatus;

  @Column({
    type: 'enum',
    enum: PaymentMethod,
    default: PaymentMethod.STRIPE,
  })
  paymentMethod: PaymentMethod;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  originalPrice: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  discountAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  finalPrice: number;

  @Column({ default: 'usd' })
  currency: string;

  @Column({ type: 'timestamptz', nullable: true })
  stripePaymentIntentId: string;

  @Column({ type: 'timestamptz', nullable: true })
  stripeCustomerId: string;

  @Column({ type: 'timestamptz', nullable: true })
  discountCode: string;

  @Column({ type: 'timestamp', nullable: true })
  completedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  refundedAt: Date;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  refundAmount: number;

  @Column({ type: 'text', nullable: true })
  refundReason: string;

  @Column({ type: 'json', nullable: true })
  metadata: any;

  @Column({ type: 'json', nullable: true })
  receipt: any; // Información del recibo/factura

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Computed properties
  get isCompleted(): boolean {
    return this.status === PurchaseStatus.COMPLETED;
  }

  get hasAccess(): boolean {
    return this.isCompleted && this.status !== PurchaseStatus.REFUNDED;
  }

  get discountPercentage(): number {
    if (!this.discountAmount || this.originalPrice === 0) return 0;
    return Math.round((this.discountAmount / this.originalPrice) * 100);
  }

  get totalSavings(): number {
    return this.discountAmount || 0;
  }
}
