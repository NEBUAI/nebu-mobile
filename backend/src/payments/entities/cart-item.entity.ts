import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';

@Entity('cart_items')
export class CartItem {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: string;

  @Column()
  courseId: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number;

  @Column({ default: 1 })
  quantity: number;

  @Column({ type: 'timestamptz', nullable: true })
  courseName: string;

  @Column({ type: 'timestamptz', nullable: true })
  courseSlug: string;

  @Column({ type: 'timestamptz', nullable: true })
  productId: string;

  @Column({ type: 'timestamptz', nullable: true })
  thumbnailUrl: string;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  @ManyToOne(() => User, user => user.cartItems)
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Course, course => course.cartItems)
  @JoinColumn({ name: 'courseId' })
  course: Course;
}
