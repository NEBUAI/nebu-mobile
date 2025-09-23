import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsModule } from '../notifications/notifications.module';
import { SchedulerService } from './services/scheduler.service';
import { CleanupService } from './services/cleanup.service';
import { ReportsService } from './services/reports.service';
import { Notification } from '../notifications/entities/notification.entity';
import { User } from '../users/entities/user.entity';
import { Course } from '../courses/entities/course.entity';
import { UserCourseEnrollment } from '../courses/entities/user-course-enrollment.entity';

@Module({
  imports: [
    ScheduleModule.forRoot(),
    NotificationsModule,
    TypeOrmModule.forFeature([
      Notification,
      User,
      Course,
      UserCourseEnrollment,
    ]),
  ],
  providers: [SchedulerService, CleanupService, ReportsService],
  exports: [SchedulerService, CleanupService, ReportsService],
})
export class SchedulerModule {}
