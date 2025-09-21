import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Subscription } from './subscription.entity';

@Entity('subscription_plans')
export class SubscriptionPlan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string;

  @Column({ unique: true })
  slug: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  monthlyPrice: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  yearlyPrice: number;

  @Column({ default: 'usd' })
  currency: string;

  @Column()
  stripeMonthlyPriceId: string;

  @Column({ type: 'timestamptz', nullable: true })
  stripeYearlyPriceId: string;

  @Column({ type: 'int', nullable: true })
  trialDays: number;

  @Column({ type: 'int', nullable: true })
  maxCourses: number; // null = unlimited

  @Column({ default: true })
  hasVideoAccess: boolean;

  @Column({ default: true })
  hasDownloadAccess: boolean;

  @Column({ default: false })
  hasCertificates: boolean;

  @Column({ default: false })
  hasPrioritySupport: boolean;

  @Column({ default: false })
  hasOfflineAccess: boolean;

  @Column({ type: 'json', nullable: true })
  features: string[]; // Lista de características adicionales

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: 0 })
  sortOrder: number;

  @Column({ type: 'json', nullable: true })
  metadata: any;

  @OneToMany(() => Subscription, subscription => subscription.plan)
  subscriptions: Subscription[];

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Computed properties
  get yearlyDiscount(): number {
    if (!this.yearlyPrice) return 0;
    const monthlyTotal = this.monthlyPrice * 12;
    const savings = monthlyTotal - this.yearlyPrice;
    return Math.round((savings / monthlyTotal) * 100);
  }

  get isUnlimited(): boolean {
    return this.maxCourses === null;
  }

  get displayPrice(): string {
    return `$${this.monthlyPrice}/month`;
  }

  get displayYearlyPrice(): string {
    if (!this.yearlyPrice) return '';
    return `$${this.yearlyPrice}/year`;
  }
}
