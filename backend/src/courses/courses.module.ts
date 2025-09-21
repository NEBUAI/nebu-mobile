import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { Course } from './entities/course.entity';
import { Category } from './entities/category.entity';
import { Lesson } from './entities/lesson.entity';
import { UserCourseEnrollment } from './entities/user-course-enrollment.entity';
import { CourseMedia } from './entities/course-media.entity';
import { CoursesService } from './services/courses.service';
import { CategoriesService } from './services/categories.service';
import { LessonsService } from './services/lessons.service';
import { CourseMediaService } from './services/course-media.service';
import { StripeSyncService } from './services/stripe-sync.service';
import { CoursesController } from './controllers/courses.controller';
import { CategoriesController } from './controllers/categories.controller';
import { LessonsController } from './controllers/lessons.controller';
import { CourseMediaController } from './controllers/course-media.controller';
import { CloudinaryModule } from '../cloudinary/cloudinary.module';
import { PaymentsModule } from '../payments/payments.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Course, Category, Lesson, UserCourseEnrollment, CourseMedia]),
    CloudinaryModule,
    PaymentsModule,
  ],
  providers: [CoursesService, CategoriesService, LessonsService, CourseMediaService, StripeSyncService],
  controllers: [CoursesController, CategoriesController, LessonsController, CourseMediaController],
  exports: [CoursesService, CategoriesService, LessonsService, CourseMediaService],
})
export class CoursesModule {}
