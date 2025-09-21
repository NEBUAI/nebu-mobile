import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuizzesController } from './controllers/quizzes.controller';
import { QuizzesService } from './services/quizzes.service';
import { Quiz } from './entities/quiz.entity';
import { QuizQuestion } from './entities/quiz-question.entity';
import { QuizAnswer } from './entities/quiz-answer.entity';
import { QuizAttempt } from './entities/quiz-attempt.entity';
import { QuizResponse } from './entities/quiz-response.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Quiz, QuizQuestion, QuizAnswer, QuizAttempt, QuizResponse])],
  controllers: [QuizzesController],
  providers: [QuizzesService],
  exports: [QuizzesService],
})
export class QuizzesModule {}
