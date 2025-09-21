import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review, ReviewStatus } from '../entities/review.entity';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { CreateReviewDto } from '../dto/create-review.dto';
import { UpdateReviewDto } from '../dto/update-review.dto';

@Injectable()
export class ReviewsService {
  constructor(
    @InjectRepository(Review)
    private readonly reviewRepository: Repository<Review>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>
  ) {}

  async create(createReviewDto: CreateReviewDto, userId: string): Promise<Review> {
    // Verificar que el usuario existe
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });
    if (!user) {
      throw new NotFoundException(`Usuario con ID ${userId} no encontrado`);
    }

    // Verificar que el curso existe
    const course = await this.courseRepository.findOne({
      where: { id: createReviewDto.courseId },
    });
    if (!course) {
      throw new NotFoundException(`Curso con ID ${createReviewDto.courseId} no encontrado`);
    }

    // Verificar que el usuario no ya ha dejado una reseña para este curso
    const existingReview = await this.reviewRepository.findOne({
      where: {
        user: { id: userId },
        course: { id: createReviewDto.courseId },
      },
    });
    if (existingReview) {
      throw new BadRequestException('Ya has dejado una reseña para este curso');
    }

    // Verificar si el usuario ha comprado el curso (esto requiere implementar sistema de enrollments)
    // Por ahora asumimos que todos pueden dejar reseñas

    const review = this.reviewRepository.create({
      rating: createReviewDto.rating,
      comment: createReviewDto.comment,
      status: createReviewDto.status || ReviewStatus.APPROVED, // Auto-aprobar por ahora
      isVerifiedPurchase: true, // Esto se debería verificar con el sistema de pagos
      user: { id: userId } as any,
      course: { id: createReviewDto.courseId } as any,
    });

    const savedReview = await this.reviewRepository.save(review);

    // Actualizar el rating promedio del curso
    await this.updateCourseAverageRating(createReviewDto.courseId);

    return savedReview;
  }

  async findAll(options?: {
    status?: string;
    rating?: number;
    page?: number;
    limit?: number;
  }): Promise<{ reviews: Review[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.reviewRepository
      .createQueryBuilder('review')
      .leftJoinAndSelect('review.user', 'user')
      .leftJoinAndSelect('review.course', 'course')
      .orderBy('review.createdAt', 'DESC');

    // Aplicar filtros
    if (options?.status) {
      queryBuilder.andWhere('review.status = :status', { status: options.status });
    }

    if (options?.rating) {
      queryBuilder.andWhere('review.rating = :rating', { rating: options.rating });
    }

    // Paginación
    const page = options?.page || 1;
    const limit = options?.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [reviews, total] = await queryBuilder.getManyAndCount();

    return {
      reviews,
      total,
      page,
      limit,
    };
  }

  async findByCourse(courseId: string, includeHidden = false): Promise<Review[]> {
    const whereCondition: Record<string, unknown> = { course: { id: courseId } };

    if (!includeHidden) {
      whereCondition.status = ReviewStatus.APPROVED;
    }

    return this.reviewRepository.find({
      where: whereCondition,
      relations: ['user'],
      order: { createdAt: 'DESC' },
    });
  }

  async findByUser(userId: string): Promise<Review[]> {
    return this.reviewRepository.find({
      where: { user: { id: userId } },
      relations: ['course'],
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Review> {
    const review = await this.reviewRepository.findOne({
      where: { id },
      relations: ['user', 'course'],
    });

    if (!review) {
      throw new NotFoundException(`Reseña con ID ${id} no encontrada`);
    }

    return review;
  }

  async update(
    id: string,
    updateReviewDto: UpdateReviewDto,
    userId: string,
    userRole?: string
  ): Promise<Review> {
    const review = await this.findOne(id);

    // Solo el autor o un admin puede editar
    if (review.user.id !== userId && userRole !== 'admin') {
      throw new ForbiddenException('No tienes permisos para editar esta reseña');
    }

    const oldRating = review.rating;
    Object.assign(review, updateReviewDto);

    const savedReview = await this.reviewRepository.save(review);

    // Actualizar el rating promedio si cambió la calificación
    if (updateReviewDto.rating && updateReviewDto.rating !== oldRating) {
      await this.updateCourseAverageRating(review.course.id);
    }

    return savedReview;
  }

  async remove(id: string, userId: string, userRole?: string): Promise<void> {
    const review = await this.findOne(id);

    // Solo el autor o un admin pueden eliminar
    if (review.user.id !== userId && userRole !== 'admin') {
      throw new ForbiddenException('No tienes permisos para eliminar esta reseña');
    }

    await this.reviewRepository.remove(review);

    // Actualizar el rating promedio del curso
    await this.updateCourseAverageRating(review.course.id);
  }

  async moderateReview(
    id: string,
    status: string,
    userId: string,
    userRole: string
  ): Promise<Review> {
    if (!['admin', 'instructor'].includes(userRole)) {
      throw new ForbiddenException('No tienes permisos para moderar reseñas');
    }

    const review = await this.findOne(id);
    review.status = status as ReviewStatus;

    const savedReview = await this.reviewRepository.save(review);

    // Actualizar el rating promedio del curso
    await this.updateCourseAverageRating(review.course.id);

    return savedReview;
  }

  async getCourseReviewStats(courseId: string): Promise<{
    totalReviews: number;
    averageRating: number;
    ratingDistribution: { [key: number]: number };
    verifiedPurchases: number;
  }> {
    const reviews = await this.reviewRepository.find({
      where: { course: { id: courseId }, status: ReviewStatus.APPROVED },
    });

    const totalReviews = reviews.length;
    const averageRating =
      totalReviews > 0 ? reviews.reduce((sum, review) => sum + review.rating, 0) / totalReviews : 0;

    // Distribución de ratings
    const ratingDistribution = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
    reviews.forEach(review => {
      ratingDistribution[review.rating]++;
    });

    const verifiedPurchases = reviews.filter(review => review.isVerifiedPurchase).length;

    return {
      totalReviews,
      averageRating: Math.round(averageRating * 100) / 100,
      ratingDistribution,
      verifiedPurchases,
    };
  }

  async getReviewStats(): Promise<{
    totalReviews: number;
    approvedReviews: number;
    pendingReviews: number;
    averageRating: number;
  }> {
    const result = await this.reviewRepository
      .createQueryBuilder('review')
      .select([
        'COUNT(*) as totalReviews',
        "COUNT(CASE WHEN review.status = 'approved' THEN 1 END) as approvedReviews",
        "COUNT(CASE WHEN review.status = 'pending' THEN 1 END) as pendingReviews",
        "AVG(CASE WHEN review.status = 'approved' THEN review.rating END) as averageRating",
      ])
      .getRawOne();

    return {
      totalReviews: parseInt(result.totalReviews) || 0,
      approvedReviews: parseInt(result.approvedReviews) || 0,
      pendingReviews: parseInt(result.pendingReviews) || 0,
      averageRating: parseFloat(result.averageRating) || 0,
    };
  }

  private async updateCourseAverageRating(courseId: string): Promise<void> {
    const result = await this.reviewRepository
      .createQueryBuilder('review')
      .select('AVG(review.rating)', 'averageRating')
      .leftJoin('review.course', 'course')
      .where('course.id = :courseId AND review.status = :status', {
        courseId,
        status: ReviewStatus.APPROVED,
      })
      .getRawOne();

    const averageRating = parseFloat(result.averageRating) || 0;

    // Aquí actualizarías el campo averageRating en la entidad Course
    // Esto requiere inyectar el CourseRepository o usar un evento
    await this.courseRepository.update(courseId, {
      averageRating: Math.round(averageRating * 100) / 100,
    });
  }

  async searchReviews(options: {
    query: string;
    courseId?: string;
    rating?: number;
    page?: number;
    limit?: number;
  }): Promise<{ reviews: Review[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.reviewRepository
      .createQueryBuilder('review')
      .leftJoinAndSelect('review.user', 'user')
      .leftJoinAndSelect('review.course', 'course')
      .where('review.status = :status', { status: ReviewStatus.APPROVED })
      .andWhere('(review.comment ILIKE :query OR course.title ILIKE :query)', {
        query: `%${options.query}%`,
      })
      .orderBy('review.createdAt', 'DESC');

    // Aplicar filtros adicionales
    if (options.courseId) {
      queryBuilder.andWhere('review.courseId = :courseId', { courseId: options.courseId });
    }

    if (options.rating) {
      queryBuilder.andWhere('review.rating = :rating', { rating: options.rating });
    }

    // Paginación
    const page = options.page || 1;
    const limit = options.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [reviews, total] = await queryBuilder.getManyAndCount();

    return {
      reviews,
      total,
      page,
      limit,
    };
  }
}
