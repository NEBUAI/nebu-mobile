import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, Index } from 'typeorm';

export enum EventType {
  USER_LOGIN = 'user_login',
  USER_LOGOUT = 'user_logout',
  USER_REGISTER = 'user_register',
  COURSE_VIEW = 'course_view',
  COURSE_ENROLL = 'course_enroll',
  COURSE_COMPLETE = 'course_complete',
  LESSON_START = 'lesson_start',
  LESSON_COMPLETE = 'lesson_complete',
  VIDEO_PLAY = 'video_play',
  VIDEO_PAUSE = 'video_pause',
  VIDEO_COMPLETE = 'video_complete',
  QUIZ_START = 'quiz_start',
  QUIZ_COMPLETE = 'quiz_complete',
  CERTIFICATE_GENERATE = 'certificate_generate',
  PAYMENT_SUCCESS = 'payment_success',
  PAYMENT_FAILED = 'payment_failed',
  SUBSCRIPTION_CREATE = 'subscription_create',
  SUBSCRIPTION_CANCEL = 'subscription_cancel',
  COMMENT_CREATE = 'comment_create',
  REVIEW_CREATE = 'review_create',
  SEARCH = 'search',
  PAGE_VIEW = 'page_view',
}

@Entity('analytics_events')
@Index(['userId', 'eventType'])
@Index(['eventType', 'createdAt'])
@Index(['createdAt'])
export class AnalyticsEvent {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid', nullable: true })
  userId: string;

  @Column({
    type: 'enum',
    enum: EventType,
  })
  eventType: EventType;

  @Column({ type: 'varchar', length: 255, nullable: true })
  sessionId: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  page: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  referrer: string;

  @Column({ type: 'varchar', length: 45, nullable: true })
  ipAddress: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  userAgent: string;

  @Column({ type: 'text', nullable: true })
  properties: string; // JSON string for event properties

  @Column({ type: 'decimal', precision: 10, scale: 2, nullable: true })
  value: number;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;
}
