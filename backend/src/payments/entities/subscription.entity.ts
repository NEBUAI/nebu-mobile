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

export enum SubscriptionStatus {
  ACTIVE = 'active',
  CANCELED = 'canceled',
  PAST_DUE = 'past_due',
  UNPAID = 'unpaid',
  INCOMPLETE = 'incomplete',
  INCOMPLETE_EXPIRED = 'incomplete_expired',
  TRIALING = 'trialing',
}

export enum SubscriptionPlan {
  BASIC = 'basic',
  PREMIUM = 'premium',
  ENTERPRISE = 'enterprise',
}

@Entity('subscriptions')
@Index(['userId', 'status'])
@Index(['stripeSubscriptionId'], { unique: true })
export class Subscription {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({
    type: 'enum',
    enum: SubscriptionPlan,
    default: SubscriptionPlan.BASIC,
  })
  plan: SubscriptionPlan;

  @Column({
    type: 'enum',
    enum: SubscriptionStatus,
    default: SubscriptionStatus.INCOMPLETE,
  })
  status: SubscriptionStatus;

  @Column({ unique: true })
  stripeSubscriptionId: string;

  @Column()
  stripeCustomerId: string;

  @Column()
  stripePriceId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  amount: number;

  @Column({ default: 'usd' })
  currency: string;

  @Column({ default: 'month' }) // month, year
  interval: string;

  @Column({ type: 'timestamp', nullable: true })
  trialStart: Date;

  @Column({ type: 'timestamp', nullable: true })
  trialEnd: Date;

  @Column({ type: 'timestamp' })
  currentPeriodStart: Date;

  @Column({ type: 'timestamp' })
  currentPeriodEnd: Date;

  @Column({ type: 'timestamp', nullable: true })
  canceledAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  cancelAtPeriodEnd: Date;

  @Column({ type: 'json', nullable: true })
  metadata: any;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Computed properties
  get isActive(): boolean {
    return this.status === SubscriptionStatus.ACTIVE || this.status === SubscriptionStatus.TRIALING;
  }

  get isTrialing(): boolean {
    return this.status === SubscriptionStatus.TRIALING;
  }

  get hasAccess(): boolean {
    if (!this.isActive) return false;

    const now = new Date();
    return now <= this.currentPeriodEnd;
  }

  get daysUntilRenewal(): number {
    const now = new Date();
    const timeDiff = this.currentPeriodEnd.getTime() - now.getTime();
    return Math.ceil(timeDiff / (1000 * 3600 * 24));
  }
}
