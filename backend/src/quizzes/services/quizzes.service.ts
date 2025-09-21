import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Quiz } from '../entities/quiz.entity';
import { QuizQuestion } from '../entities/quiz-question.entity';
import { QuizAttempt, AttemptStatus } from '../entities/quiz-attempt.entity';
import { CreateQuizDto } from '../dto/create-quiz.dto';
import { UpdateQuizDto } from '../dto/update-quiz.dto';
import { SubmitQuizDto } from '../dto/submit-quiz.dto';

@Injectable()
export class QuizzesService {
  constructor(
    @InjectRepository(Quiz)
    private quizRepository: Repository<Quiz>,
    @InjectRepository(QuizQuestion)
    private questionRepository: Repository<QuizQuestion>,
    @InjectRepository(QuizAttempt)
    private attemptRepository: Repository<QuizAttempt>
  ) {}

  async create(createQuizDto: CreateQuizDto): Promise<Quiz> {
    const quiz = this.quizRepository.create(createQuizDto);
    return this.quizRepository.save(quiz);
  }

  async findAll(params?: {
    courseId?: string;
    lessonId?: string;
    status?: string;
    page?: number;
    limit?: number;
  }): Promise<{ data: Quiz[]; total: number; page: number; limit: number }> {
    const { courseId, lessonId, status, page = 1, limit = 10 } = params || {};

    const query = this.quizRepository
      .createQueryBuilder('quiz')
      .leftJoinAndSelect('quiz.course', 'course')
      .leftJoinAndSelect('quiz.lesson', 'lesson')
      .leftJoinAndSelect('quiz.questions', 'questions')
      .leftJoinAndSelect('questions.answers', 'answers');

    if (courseId) {
      query.andWhere('quiz.courseId = :courseId', { courseId });
    }

    if (lessonId) {
      query.andWhere('quiz.lessonId = :lessonId', { lessonId });
    }

    if (status) {
      query.andWhere('quiz.status = :status', { status });
    }

    const [data, total] = await query
      .skip((page - 1) * limit)
      .take(limit)
      .getManyAndCount();

    return { data, total, page, limit };
  }

  async findOne(id: string): Promise<Quiz> {
    const quiz = await this.quizRepository.findOne({
      where: { id },
      relations: ['course', 'lesson', 'questions', 'questions.answers'],
    });

    if (!quiz) {
      throw new NotFoundException('Quiz not found');
    }

    return quiz;
  }

  async findBySlug(slug: string): Promise<Quiz> {
    const quiz = await this.quizRepository.findOne({
      where: { slug },
      relations: ['course', 'lesson', 'questions', 'questions.answers'],
    });

    if (!quiz) {
      throw new NotFoundException('Quiz not found');
    }

    return quiz;
  }

  async update(id: string, updateQuizDto: UpdateQuizDto): Promise<Quiz> {
    const quiz = await this.findOne(id);
    Object.assign(quiz, updateQuizDto);
    return this.quizRepository.save(quiz);
  }

  async remove(id: string): Promise<void> {
    const quiz = await this.findOne(id);
    await this.quizRepository.remove(quiz);
  }

  async startAttempt(userId: string, quizId: string): Promise<QuizAttempt> {
    const quiz = await this.findOne(quizId);

    // Check if user has reached max attempts
    if (quiz.maxAttempts > 0) {
      const attemptCount = await this.attemptRepository.count({
        where: { userId, quizId },
      });

      if (attemptCount >= quiz.maxAttempts) {
        throw new BadRequestException('Maximum attempts reached');
      }
    }

    const attempt = this.attemptRepository.create({
      userId,
      quizId,
      totalPoints: quiz.totalPoints,
      startedAt: new Date(),
    });

    return this.attemptRepository.save(attempt);
  }

  async submitQuiz(userId: string, submitQuizDto: SubmitQuizDto): Promise<QuizAttempt> {
    const { quizId, responses, timeSpent, notes } = submitQuizDto;

    const quiz = await this.findOne(quizId);
    const attempt = await this.attemptRepository.findOne({
      where: { userId, quizId, status: AttemptStatus.IN_PROGRESS },
      relations: ['responses'],
    });

    if (!attempt) {
      throw new NotFoundException('Active attempt not found');
    }

    // Calculate score
    let totalScore = 0;
    const questionIds = Object.keys(responses);
    const questions = await this.questionRepository.find({
      where: { id: In(questionIds) },
      relations: ['answers'],
    });

    for (const question of questions) {
      const userAnswer = responses[question.id];
      const isCorrect = this.checkAnswer(question, userAnswer);
      const points = isCorrect ? question.points : 0;
      totalScore += points;

      // Save response
      const response = this.attemptRepository.manager.create('QuizResponse', {
        attemptId: attempt.id,
        questionId: question.id,
        answer: typeof userAnswer === 'string' ? userAnswer : null,
        selectedAnswers: Array.isArray(userAnswer) ? userAnswer : null,
        isCorrect,
        points,
        maxPoints: question.points,
        answeredAt: new Date(),
      });

      await this.attemptRepository.manager.save(response);
    }

    // Update attempt
    const percentage = (totalScore / quiz.totalPoints) * 100;
    const isPassed = percentage >= quiz.passingScore;

    attempt.score = totalScore;
    attempt.percentage = percentage;
    attempt.isPassed = isPassed;
    attempt.status = AttemptStatus.COMPLETED;
    attempt.completedAt = new Date();
    attempt.submittedAt = new Date();
    attempt.timeSpent = timeSpent || 0;
    attempt.notes = notes || null;
    attempt.answers = responses;

    const savedAttempt = await this.attemptRepository.save(attempt);

    // Update quiz statistics
    await this.updateQuizStats(quizId);

    return savedAttempt;
  }

  async getUserAttempts(userId: string, quizId?: string): Promise<QuizAttempt[]> {
    const where: Record<string, unknown> = { userId };
    if (quizId) {
      where.quizId = quizId;
    }

    return this.attemptRepository.find({
      where,
      relations: ['quiz', 'responses', 'responses.question'],
      order: { createdAt: 'DESC' },
    });
  }

  async getQuizStats(quizId: string): Promise<any> {
    await this.findOne(quizId);
    const attempts = await this.attemptRepository.find({
      where: { quizId, status: AttemptStatus.COMPLETED },
    });

    const totalAttempts = attempts.length;
    const passedAttempts = attempts.filter(a => a.isPassed).length;
    const averageScore =
      totalAttempts > 0 ? attempts.reduce((sum, a) => sum + a.percentage, 0) / totalAttempts : 0;

    return {
      totalAttempts,
      passedAttempts,
      averageScore,
      passRate: totalAttempts > 0 ? (passedAttempts / totalAttempts) * 100 : 0,
    };
  }

  private checkAnswer(question: QuizQuestion, userAnswer: any): boolean {
    switch (question.type) {
      case 'multiple_choice': {
        const correctAnswers = question.answers.filter(a => a.isCorrect).map(a => a.id);
        return (
          Array.isArray(userAnswer) &&
          userAnswer.length === correctAnswers.length &&
          userAnswer.every(id => correctAnswers.includes(id))
        );
      }

      case 'true_false': {
        const correctAnswer = question.answers.find(a => a.isCorrect);
        return correctAnswer && userAnswer === correctAnswer.id;
      }

      case 'fill_blank': {
        const correctText = question.answers.find(a => a.isCorrect)?.text;
        return correctText && userAnswer?.toLowerCase().trim() === correctText.toLowerCase().trim();
      }

      default:
        return false;
    }
  }

  private async updateQuizStats(quizId: string): Promise<void> {
    const attempts = await this.attemptRepository.find({
      where: { quizId, status: AttemptStatus.COMPLETED },
    });

    const totalAttempts = attempts.length;
    const totalCompletions = attempts.filter(a => a.isPassed).length;
    const averageScore =
      totalAttempts > 0 ? attempts.reduce((sum, a) => sum + a.percentage, 0) / totalAttempts : 0;

    await this.quizRepository.update(quizId, {
      totalAttempts,
      totalCompletions,
      averageScore,
    });
  }
}
