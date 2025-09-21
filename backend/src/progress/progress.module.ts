import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Progress } from './entities/progress.entity';
import { UserProgress } from './entities/user-progress.entity';
import { User } from '../users/entities/user.entity';
import { Course } from '../courses/entities/course.entity';
import { Lesson } from '../courses/entities/lesson.entity';
import { ProgressService } from './services/progress.service';
import { UserProgressService } from './services/user-progress.service';
import { ProgressController } from './controllers/progress.controller';
import { UserProgressController } from './controllers/user-progress.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Progress, UserProgress, User, Course, Lesson])],
  controllers: [ProgressController, UserProgressController],
  providers: [ProgressService, UserProgressService],
  exports: [ProgressService, UserProgressService, TypeOrmModule],
})
export class ProgressModule {}
