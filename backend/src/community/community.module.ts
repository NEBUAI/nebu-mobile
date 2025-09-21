import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Comment } from './entities/comment.entity';
import { Review } from './entities/review.entity';
import { User } from '../users/entities/user.entity';
import { Course } from '../courses/entities/course.entity';
import { Lesson } from '../courses/entities/lesson.entity';
import { CommentsService } from './services/comments.service';
import { ReviewsService } from './services/reviews.service';
import { CommentsController } from './controllers/comments.controller';
import { ReviewsController } from './controllers/reviews.controller';

@Module({
  imports: [TypeOrmModule.forFeature([Comment, Review, User, Course, Lesson])],
  controllers: [CommentsController, ReviewsController],
  providers: [CommentsService, ReviewsService],
  exports: [CommentsService, ReviewsService, TypeOrmModule],
})
export class CommunityModule {}
