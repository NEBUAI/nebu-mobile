import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { AnalyticsController } from './controllers/analytics.controller';
import { AcademyController } from './controllers/academy.controller';
import { StatsController } from './controllers/stats.controller';
import { AnalyticsService } from './services/analytics.service';
import { AcademyService } from './services/academy.service';
import { ReportsService } from './services/reports.service';
import { StatsService } from './services/stats.service';
import { AnalyticsEvent } from './entities/analytics-event.entity';
import { UserActivity } from './entities/user-activity.entity';
import { User } from '../users/entities/user.entity';
import { Course } from '../courses/entities/course.entity';
import { Review } from '../community/entities/review.entity';
import { Certificate } from '../certificates/entities/certificate.entity';
import { FeaturesConfig } from '../config/features.config';

@Module({
  imports: [
    ConfigModule,
    TypeOrmModule.forFeature([AnalyticsEvent, UserActivity, User, Course, Review, Certificate]),
  ],
  controllers: [AnalyticsController, AcademyController, StatsController],
  providers: [AnalyticsService, AcademyService, ReportsService, StatsService, FeaturesConfig],
  exports: [AnalyticsService, AcademyService, ReportsService, StatsService, FeaturesConfig],
})
export class AnalyticsModule {}
