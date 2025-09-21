import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsModule } from '../notifications/notifications.module';
import { SchedulerService } from './services/scheduler.service';
import { CleanupService } from './services/cleanup.service';
import { ReportsService } from './services/reports.service';
import { AnalyticsEvent } from '../analytics/entities/analytics-event.entity';
import { UserActivity } from '../analytics/entities/user-activity.entity';
import { Notification } from '../notifications/entities/notification.entity';
import { User } from '../users/entities/user.entity';
import { Course } from '../courses/entities/course.entity';
import { UserCourseEnrollment } from '../courses/entities/user-course-enrollment.entity';
import { Progress } from '../progress/entities/progress.entity';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    NotificationsModule,
    TypeOrmModule.forFeature([
      AnalyticsEvent,
      UserActivity,
      Notification,
      User,
      Course,
      UserCourseEnrollment,
      Progress,
    ]),
  ],
  providers: [SchedulerService, CleanupService, ReportsService],
  exports: [SchedulerService, CleanupService, ReportsService],
})
export class SchedulerModule {}
