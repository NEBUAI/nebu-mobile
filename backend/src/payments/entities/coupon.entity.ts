import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  Index,
} from 'typeorm';
import { Purchase } from './purchase.entity';

export enum CouponType {
  PERCENTAGE = 'percentage',
  FIXED_AMOUNT = 'fixed_amount',
}

export enum CouponApplicability {
  ALL_COURSES = 'all_courses',
  SPECIFIC_COURSES = 'specific_courses',
  SUBSCRIPTIONS = 'subscriptions',
}

@Entity('coupons')
@Index(['code'], { unique: true })
export class Coupon {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  code: string;

  @Column()
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: CouponType,
    default: CouponType.PERCENTAGE,
  })
  type: CouponType;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  value: number; // Percentage (0-100) or fixed amount

  @Column({
    type: 'enum',
    enum: CouponApplicability,
    default: CouponApplicability.ALL_COURSES,
  })
  applicability: CouponApplicability;

  @Column({ type: 'json', nullable: true })
  applicableCourseIds: string[]; // IDs de cursos específicos

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  minimumAmount: number;

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  maximumDiscount: number;

  @Column({ type: 'int', nullable: true })
  usageLimit: number; // null = unlimited

  @Column({ type: 'int', default: 0 })
  usageCount: number;

  @Column({ type: 'int', nullable: true })
  usageLimitPerUser: number; // null = unlimited per user

  @Column({ type: 'timestamp', nullable: true })
  validFrom: Date;

  @Column({ type: 'timestamp', nullable: true })
  validUntil: Date;

  @Column({ default: true })
  isActive: boolean;

  @Column({ default: false })
  isFirstTimeOnly: boolean; // Solo para usuarios que nunca han comprado

  @Column({ type: 'json', nullable: true })
  metadata: any;

  @OneToMany(() => Purchase, purchase => purchase.discountCode)
  purchases: Purchase[];

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Computed properties
  get isValid(): boolean {
    if (!this.isActive) return false;

    const now = new Date();

    if (this.validFrom && now < this.validFrom) return false;
    if (this.validUntil && now > this.validUntil) return false;

    if (this.usageLimit && this.usageCount >= this.usageLimit) return false;

    return true;
  }

  get remainingUses(): number | null {
    if (!this.usageLimit) return null;
    return Math.max(0, this.usageLimit - this.usageCount);
  }

  get discountDisplay(): string {
    if (this.type === CouponType.PERCENTAGE) {
      return `${this.value}% OFF`;
    }
    return `$${this.value} OFF`;
  }

  calculateDiscount(amount: number): number {
    if (!this.isValid) return 0;

    if (this.minimumAmount && amount < this.minimumAmount) return 0;

    let discount = 0;

    if (this.type === CouponType.PERCENTAGE) {
      discount = (amount * this.value) / 100;
    } else {
      discount = this.value;
    }

    if (this.maximumDiscount && discount > this.maximumDiscount) {
      discount = this.maximumDiscount;
    }

    return Math.min(discount, amount);
  }
}
