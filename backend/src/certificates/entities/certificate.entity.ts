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
import { Course } from '../../courses/entities/course.entity';

export enum CertificateStatus {
  PENDING = 'pending',
  GENERATED = 'generated',
  ISSUED = 'issued',
  REVOKED = 'revoked',
}

@Entity('certificates')
@Index(['userId', 'courseId'])
@Index(['status'])
@Index(['issuedAt'])
export class Certificate {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'uuid' })
  courseId: string;

  @ManyToOne(() => Course, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'courseId' })
  course: Course;

  @Column({ type: 'varchar', length: 255, unique: true })
  certificateNumber: string;

  @Column({
    type: 'enum',
    enum: CertificateStatus,
    default: CertificateStatus.PENDING,
  })
  status: CertificateStatus;

  @Column({ type: 'decimal', precision: 5, scale: 2, nullable: true })
  finalScore: number;

  @Column({ type: 'int', nullable: true })
  completionPercentage: number;

  @Column({ type: 'timestamp', nullable: true })
  completedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  issuedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  expiresAt: Date;

  @Column({ type: 'varchar', length: 500, nullable: true })
  filePath: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  downloadUrl: string;

  @Column({ type: 'text', nullable: true })
  metadata: string; // JSON string for additional data

  @Column({ type: 'text', nullable: true })
  revocationReason: string;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;
}
