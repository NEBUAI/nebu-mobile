import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  ManyToMany,
  JoinTable,
  CreateDateColumn,
  UpdateDateColumn,
  JoinColumn,
} from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';

export enum OrderStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

@Entity('orders')
export class Order {
  @ApiProperty({
    description: 'ID único de la orden',
    example: 'uuid-string',
  })
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ApiProperty({
    description: 'Usuario que realizó la orden',
    type: () => User,
  })
  @ManyToOne(() => User, user => user.orders, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column('uuid')
  userId: string;

  @ApiProperty({
    description: 'Cursos incluidos en la orden',
    type: [Course],
  })
  @ManyToMany(() => Course)
  @JoinTable({
    name: 'order_courses',
    joinColumn: { name: 'orderId', referencedColumnName: 'id' },
    inverseJoinColumn: { name: 'courseId', referencedColumnName: 'id' },
  })
  courses: Course[];

  @ApiProperty({
    description: 'Estado de la orden',
    enum: OrderStatus,
    example: OrderStatus.PENDING,
  })
  @Column({
    type: 'enum',
    enum: OrderStatus,
    default: OrderStatus.PENDING,
  })
  status: OrderStatus;

  @ApiProperty({
    description: 'Monto total de la orden en centavos',
    example: 9999,
  })
  @Column('int')
  totalAmount: number;

  @ApiProperty({
    description: 'Moneda de la transacción',
    example: 'usd',
  })
  @Column({ default: 'usd' })
  currency: string;

  @ApiProperty({
    description: 'Código de descuento aplicado',
    example: 'DESCUENTO20',
    required: false,
  })
  @Column({ type: 'timestamptz', nullable: true })
  discountCode?: string;

  @ApiProperty({
    description: 'Porcentaje de descuento aplicado',
    example: 20,
    required: false,
  })
  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  discountPercentage?: number;

  @ApiProperty({
    description: 'ID del Payment Intent de Stripe',
    example: 'pi_1234567890',
    required: false,
  })
  @Column({ type: 'timestamptz', nullable: true })
  stripePaymentIntentId?: string;

  @ApiProperty({
    description: 'Fecha de creación de la orden',
    example: '2025-01-01T00:00:00.000Z',
  })
  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @ApiProperty({
    description: 'Fecha de última actualización',
    example: '2025-01-01T00:00:00.000Z',
  })
  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  @ApiProperty({
    description: 'Fecha de completado de la orden',
    example: '2025-01-01T00:00:00.000Z',
    required: false,
  })
  @Column({ type: 'timestamptz', nullable: true })
  completedAt?: Date;
}
