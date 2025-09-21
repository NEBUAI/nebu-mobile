import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
// Using string references to avoid circular dependencies

export enum StudentStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
  GRADUATED = 'graduated',
  DROPPED = 'dropped',
}

export enum StudentType {
  REGULAR = 'regular',
  PREMIUM = 'premium',
  SCHOLARSHIP = 'scholarship',
  CORPORATE = 'corporate',
}

@Entity('students')
export class Student {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  studentId: string; // Custom student ID like "STU-2024-001"

  @Column({
    type: 'enum',
    enum: StudentStatus,
    default: StudentStatus.ACTIVE,
  })
  status: StudentStatus;

  @Column({
    type: 'enum',
    enum: StudentType,
    default: StudentType.REGULAR,
  })
  type: StudentType;

  @Column({ type: 'date', nullable: true })
  enrollmentDate: Date;

  @Column({ type: 'date', nullable: true })
  graduationDate: Date;

  @Column({ type: 'date', nullable: true })
  lastActiveDate: Date;

  @Column({ default: 0 })
  totalCoursesEnrolled: number;

  @Column({ default: 0 })
  totalCoursesCompleted: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  averageGrade: number;

  @Column({ default: 0 })
  totalStudyHours: number;

  @Column({ default: 0 })
  totalCertificates: number;

  @Column({ type: 'json', nullable: true })
  academicRecord: Record<string, any>;

  @Column({ type: 'json', nullable: true })
  learningPreferences: Record<string, any>;

  @Column({ type: 'json', nullable: true })
  achievements: Record<string, any>;

  @Column({ type: 'json', nullable: true })
  metadata: Record<string, any>;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;

  // Relations using string references to avoid circular dependencies
  @ManyToOne('Person', 'students')
  @JoinColumn({ name: 'personId' })
  person: any;

  @Column()
  personId: string;

  // Relations to track student activities (via User entity)
  @OneToMany('Progress', 'user')
  progress: any[];

  @OneToMany('Review', 'user')
  reviews: any[];

  @OneToMany('Comment', 'user')
  comments: any[];

  // Virtual properties
  get isActive(): boolean {
    return this.status === StudentStatus.ACTIVE;
  }

  get isGraduated(): boolean {
    return this.status === StudentStatus.GRADUATED;
  }

  get completionRate(): number {
    if (this.totalCoursesEnrolled === 0) return 0;
    return (this.totalCoursesCompleted / this.totalCoursesEnrolled) * 100;
  }

  get studyDuration(): number {
    if (!this.enrollmentDate) return 0;
    const endDate = this.graduationDate || new Date();
    const diffTime = Math.abs(endDate.getTime() - this.enrollmentDate.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24)); // days
  }
}
