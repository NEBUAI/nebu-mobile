import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Progress } from '../entities/progress.entity';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Lesson } from '../../courses/entities/lesson.entity';
import { CreateProgressDto } from '../dto/create-progress.dto';
import { UpdateProgressDto } from '../dto/update-progress.dto';

@Injectable()
export class ProgressService {
  constructor(
    @InjectRepository(Progress)
    private readonly progressRepository: Repository<Progress>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>,
    @InjectRepository(Lesson)
    private readonly lessonRepository: Repository<Lesson>
  ) {}

  async create(createProgressDto: CreateProgressDto): Promise<Progress> {
    // Verificar que el usuario existe
    const user = await this.userRepository.findOne({
      where: { id: createProgressDto.userId },
    });
    if (!user) {
      throw new NotFoundException(`Usuario con ID ${createProgressDto.userId} no encontrado`);
    }

    // Verificar que el curso existe
    const course = await this.courseRepository.findOne({
      where: { id: createProgressDto.courseId },
    });
    if (!course) {
      throw new NotFoundException(`Curso con ID ${createProgressDto.courseId} no encontrado`);
    }

    // Verificar que la lección existe si se especifica
    if (createProgressDto.lessonId) {
      const lesson = await this.lessonRepository.findOne({
        where: { id: createProgressDto.lessonId, courseId: createProgressDto.courseId },
      });
      if (!lesson) {
        throw new NotFoundException(
          `Lección con ID ${createProgressDto.lessonId} no encontrada en este curso`
        );
      }
    }

    // Verificar que no existe ya un progreso para esta combinación
    const existingProgress = await this.progressRepository.findOne({
      where: {
        userId: createProgressDto.userId,
        courseId: createProgressDto.courseId,
        lessonId: createProgressDto.lessonId || null,
      },
    });

    if (existingProgress) {
      throw new BadRequestException('Ya existe un registro de progreso para esta combinación');
    }

    const progress = this.progressRepository.create({
      ...createProgressDto,
      startedAt: new Date(),
    });

    return this.progressRepository.save(progress);
  }

  async findAll(options?: {
    status?: string;
    courseId?: string;
    userId?: string;
    page?: number;
    limit?: number;
  }): Promise<{ progress: Progress[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.progressRepository
      .createQueryBuilder('progress')
      .leftJoinAndSelect('progress.user', 'user')
      .leftJoinAndSelect('progress.course', 'course')
      .leftJoinAndSelect('progress.lesson', 'lesson')
      .orderBy('progress.updatedAt', 'DESC');

    // Aplicar filtros
    if (options?.status) {
      queryBuilder.andWhere('progress.status = :status', { status: options.status });
    }

    if (options?.courseId) {
      queryBuilder.andWhere('progress.courseId = :courseId', { courseId: options.courseId });
    }

    if (options?.userId) {
      queryBuilder.andWhere('progress.userId = :userId', { userId: options.userId });
    }

    // Paginación
    const page = options?.page || 1;
    const limit = options?.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [progress, total] = await queryBuilder.getManyAndCount();

    return {
      progress,
      total,
      page,
      limit,
    };
  }

  async findByUser(userId: string): Promise<Progress[]> {
    return this.progressRepository.find({
      where: { userId },
      relations: ['course', 'lesson'],
      order: { updatedAt: 'DESC' },
    });
  }

  async findByCourse(courseId: string): Promise<Progress[]> {
    return this.progressRepository.find({
      where: { courseId },
      relations: ['user', 'lesson'],
      order: { updatedAt: 'DESC' },
    });
  }

  async findUserCourseProgress(userId: string, courseId: string): Promise<Progress[]> {
    return this.progressRepository.find({
      where: { userId, courseId },
      relations: ['lesson'],
      order: { lesson: { sortOrder: 'ASC' } },
    });
  }

  async findOne(id: string): Promise<Progress> {
    const progress = await this.progressRepository.findOne({
      where: { id },
      relations: ['user', 'course', 'lesson'],
    });

    if (!progress) {
      throw new NotFoundException(`Progreso con ID ${id} no encontrado`);
    }

    return progress;
  }

  async update(id: string, updateProgressDto: UpdateProgressDto): Promise<Progress> {
    const progress = await this.findOne(id);

    // Actualizar fecha de finalización si se marca como completado
    if (updateProgressDto.status === 'completed' && progress.status !== 'completed') {
      progress.completedAt = new Date();
    }

    Object.assign(progress, updateProgressDto);
    return this.progressRepository.save(progress);
  }

  async updateOrCreate(
    userId: string,
    courseId: string,
    lessonId: string | null,
    updateData: Partial<UpdateProgressDto>
  ): Promise<Progress> {
    let progress = await this.progressRepository.findOne({
      where: { userId, courseId, lessonId: lessonId || null },
    });

    if (progress) {
      // Actualizar progreso existente
      Object.assign(progress, updateData);

      // Actualizar fecha de finalización si se marca como completado
      if (updateData.status === 'completed' && progress.status !== 'completed') {
        progress.completedAt = new Date();
      }
    } else {
      // Crear nuevo progreso
      progress = this.progressRepository.create({
        userId,
        courseId,
        lessonId,
        ...updateData,
        startedAt: new Date(),
        completedAt: updateData.status === 'completed' ? new Date() : null,
      });
    }

    return this.progressRepository.save(progress);
  }

  async remove(id: string): Promise<void> {
    const progress = await this.findOne(id);
    await this.progressRepository.remove(progress);
  }

  async getUserCourseStats(
    userId: string,
    courseId: string
  ): Promise<{
    totalLessons: number;
    completedLessons: number;
    completionPercentage: number;
    totalTimeSpent: number;
    averageScore: number;
  }> {
    const result = await this.progressRepository
      .createQueryBuilder('progress')
      .leftJoin('progress.lesson', 'lesson')
      .select([
        'COUNT(DISTINCT lesson.id) as totalLessons',
        "COUNT(CASE WHEN progress.status = 'completed' THEN 1 END) as completedLessons",
        'SUM(progress.timeSpent) as totalTimeSpent',
        'AVG(progress.score) as averageScore',
      ])
      .where('progress.userId = :userId AND progress.courseId = :courseId', { userId, courseId })
      .getRawOne();

    const totalLessons = parseInt(result.totalLessons) || 0;
    const completedLessons = parseInt(result.completedLessons) || 0;
    const completionPercentage = totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

    return {
      totalLessons,
      completedLessons,
      completionPercentage: Math.round(completionPercentage * 100) / 100,
      totalTimeSpent: parseFloat(result.totalTimeSpent) || 0,
      averageScore: parseFloat(result.averageScore) || 0,
    };
  }

  async getCourseProgressOverview(courseId: string): Promise<{
    totalStudents: number;
    activeStudents: number;
    completedStudents: number;
    averageCompletionRate: number;
    averageTimeSpent: number;
  }> {
    const result = await this.progressRepository
      .createQueryBuilder('progress')
      .select([
        'COUNT(DISTINCT progress.userId) as totalStudents',
        "COUNT(DISTINCT CASE WHEN progress.status IN ('in_progress', 'completed') THEN progress.userId END) as activeStudents",
        "COUNT(DISTINCT CASE WHEN progress.status = 'completed' THEN progress.userId END) as completedStudents",
        'AVG(progress.completionPercentage) as averageCompletionRate',
        'AVG(progress.timeSpent) as averageTimeSpent',
      ])
      .where('progress.courseId = :courseId', { courseId })
      .getRawOne();

    return {
      totalStudents: parseInt(result.totalStudents) || 0,
      activeStudents: parseInt(result.activeStudents) || 0,
      completedStudents: parseInt(result.completedStudents) || 0,
      averageCompletionRate: parseFloat(result.averageCompletionRate) || 0,
      averageTimeSpent: parseFloat(result.averageTimeSpent) || 0,
    };
  }

  async getUserProgressSummary(userId: string): Promise<{
    totalCourses: number;
    activeCourses: number;
    completedCourses: number;
    totalTimeSpent: number;
    averageScore: number;
  }> {
    const result = await this.progressRepository
      .createQueryBuilder('progress')
      .select([
        'COUNT(DISTINCT progress.courseId) as totalCourses',
        "COUNT(DISTINCT CASE WHEN progress.status IN ('in_progress', 'completed') THEN progress.courseId END) as activeCourses",
        "COUNT(DISTINCT CASE WHEN progress.status = 'completed' THEN progress.courseId END) as completedCourses",
        'SUM(progress.timeSpent) as totalTimeSpent',
        'AVG(progress.score) as averageScore',
      ])
      .where('progress.userId = :userId', { userId })
      .getRawOne();

    return {
      totalCourses: parseInt(result.totalCourses) || 0,
      activeCourses: parseInt(result.activeCourses) || 0,
      completedCourses: parseInt(result.completedCourses) || 0,
      totalTimeSpent: parseFloat(result.totalTimeSpent) || 0,
      averageScore: parseFloat(result.averageScore) || 0,
    };
  }
}
