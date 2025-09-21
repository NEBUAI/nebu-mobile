import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserProgress, ProgressStatus } from '../entities/user-progress.entity';
import { CreateUserProgressDto } from '../dto/create-user-progress.dto';
import { UpdateUserProgressDto } from '../dto/update-user-progress.dto';

@Injectable()
export class UserProgressService {
  constructor(
    @InjectRepository(UserProgress)
    private userProgressRepository: Repository<UserProgress>
  ) {}

  async createOrUpdate(createUserProgressDto: CreateUserProgressDto): Promise<UserProgress> {
    const { userId, courseId, lessonId, ...progressData } = createUserProgressDto;

    // Buscar progreso existente
    let progress = await this.userProgressRepository.findOne({
      where: { userId, courseId },
    });

    if (progress) {
      // Actualizar progreso existente
      Object.assign(progress, progressData);
      if (lessonId) progress.lessonId = lessonId;
      progress.lastAccessed = new Date();
    } else {
      // Crear nuevo progreso
      progress = this.userProgressRepository.create({
        userId,
        courseId,
        lessonId,
        ...progressData,
        lastAccessed: new Date(),
        status: progressData.status || ProgressStatus.NOT_STARTED,
      });
    }

    return this.userProgressRepository.save(progress);
  }

  async findByUser(userId: string, courseId?: string): Promise<UserProgress[]> {
    const where: any = { userId };
    if (courseId) where.courseId = courseId;

    return this.userProgressRepository.find({
      where,
      relations: ['course', 'lesson'],
      order: { lastAccessed: 'DESC' },
    });
  }

  async findByUserAndCourse(userId: string, courseId: string): Promise<UserProgress | null> {
    return this.userProgressRepository.findOne({
      where: { userId, courseId },
      relations: ['course', 'lesson'],
    });
  }

  async findOne(id: string): Promise<UserProgress> {
    const progress = await this.userProgressRepository.findOne({
      where: { id },
      relations: ['course', 'lesson'],
    });

    if (!progress) {
      throw new NotFoundException('Progreso no encontrado');
    }

    return progress;
  }

  async update(
    id: string,
    updateUserProgressDto: UpdateUserProgressDto,
    userId: string
  ): Promise<UserProgress> {
    const progress = await this.findOne(id);

    // Verificar que el usuario es el propietario del progreso
    if (progress.userId !== userId) {
      throw new ForbiddenException('No autorizado para actualizar este progreso');
    }

    Object.assign(progress, updateUserProgressDto);
    progress.lastAccessed = new Date();

    return this.userProgressRepository.save(progress);
  }

  async remove(id: string, userId: string): Promise<void> {
    const progress = await this.findOne(id);

    // Verificar que el usuario es el propietario del progreso
    if (progress.userId !== userId) {
      throw new ForbiddenException('No autorizado para eliminar este progreso');
    }

    await this.userProgressRepository.remove(progress);
  }

  async trackProgress(trackData: {
    userId: string;
    courseId: string;
    lessonId?: string;
    completionPercentage: number;
    timeSpent: number;
    action: 'start' | 'progress' | 'complete';
  }): Promise<UserProgress> {
    const { userId, courseId, lessonId, completionPercentage, timeSpent, action } = trackData;

    let progress = await this.userProgressRepository.findOne({
      where: { userId, courseId },
    });

    if (!progress) {
      progress = this.userProgressRepository.create({
        userId,
        courseId,
        lessonId,
        completionPercentage: 0,
        timeSpent: 0,
        isEnrolled: true,
        status: ProgressStatus.NOT_STARTED,
      });
    }

    // Actualizar progreso basado en la acción
    switch (action) {
      case 'start':
        progress.status = ProgressStatus.IN_PROGRESS;
        progress.isEnrolled = true;
        break;
      case 'progress':
        progress.completionPercentage = Math.max(
          progress.completionPercentage,
          completionPercentage
        );
        progress.timeSpent += timeSpent;
        break;
      case 'complete':
        progress.status = ProgressStatus.COMPLETED;
        progress.completionPercentage = 100;
        progress.timeSpent += timeSpent;
        if (lessonId) {
          progress.completedLessons += 1;
        }
        break;
    }

    progress.lastAccessed = new Date();

    return this.userProgressRepository.save(progress);
  }

  async getCourseStats(courseId: string): Promise<{
    totalEnrolled: number;
    averageCompletion: number;
    completionRate: number;
    averageTimeSpent: number;
  }> {
    const stats = await this.userProgressRepository
      .createQueryBuilder('progress')
      .select([
        'COUNT(*) as totalEnrolled',
        'AVG(progress.completionPercentage) as averageCompletion',
        'AVG(progress.timeSpent) as averageTimeSpent',
        "COUNT(CASE WHEN progress.status = 'completed' THEN 1 END) as completedCount",
      ])
      .where('progress.courseId = :courseId', { courseId })
      .getRawOne();

    const totalEnrolled = parseInt(stats.totalEnrolled) || 0;
    const completedCount = parseInt(stats.completedCount) || 0;
    const completionRate = totalEnrolled > 0 ? (completedCount / totalEnrolled) * 100 : 0;

    return {
      totalEnrolled,
      averageCompletion: parseFloat(stats.averageCompletion) || 0,
      completionRate,
      averageTimeSpent: parseFloat(stats.averageTimeSpent) || 0,
    };
  }
}
