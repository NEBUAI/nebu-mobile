import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Lesson } from '../entities/lesson.entity';
import { Course } from '../entities/course.entity';
import { CreateLessonDto } from '../dto/create-lesson.dto';
import { UpdateLessonDto } from '../dto/update-lesson.dto';
import { LessonStatus } from '../entities/lesson.entity';

@Injectable()
export class LessonsService {
  constructor(
    @InjectRepository(Lesson)
    private readonly lessonRepository: Repository<Lesson>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>
  ) {}

  async create(createLessonDto: CreateLessonDto, userId?: string): Promise<Lesson> {
    // Verificar que el curso existe
    const course = await this.courseRepository.findOne({
      where: { id: createLessonDto.courseId },
      relations: ['instructor'],
    });

    if (!course) {
      throw new NotFoundException(`Curso con ID ${createLessonDto.courseId} no encontrado`);
    }

    // Verificar permisos (solo el instructor del curso o admin puede crear lecciones)
    if (userId && course.instructor.id !== userId) {
      // Aquí deberías verificar si el usuario es admin
      // Por ahora permitimos la creación
    }

    // Generar slug automáticamente
    const slug = this.generateSlug(createLessonDto.title);

    // Verificar que el slug no existe en el mismo curso
    const existingLesson = await this.lessonRepository.findOne({
      where: { slug, course: { id: createLessonDto.courseId } },
    });
    if (existingLesson) {
      throw new BadRequestException(
        `Ya existe una lección con el título "${createLessonDto.title}" en este curso`
      );
    }

    // Asignar orden automáticamente si no se especifica
    if (!createLessonDto.sortOrder) {
      const lastLesson = await this.lessonRepository.findOne({
        where: { course: { id: createLessonDto.courseId } },
        order: { sortOrder: 'DESC' },
      });
      createLessonDto.sortOrder = lastLesson ? lastLesson.sortOrder + 1 : 1;
    }

    const lesson = this.lessonRepository.create({
      ...createLessonDto,
      slug,
    });

    return this.lessonRepository.save(lesson);
  }

  async findAll(options?: {
    search?: string;
    type?: string;
    status?: string;
    page?: number;
    limit?: number;
  }): Promise<{ lessons: Lesson[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.lessonRepository
      .createQueryBuilder('lesson')
      .leftJoinAndSelect('lesson.course', 'course')
      .leftJoinAndSelect('course.instructor', 'instructor')
      .orderBy('lesson.courseId', 'ASC')
      .addOrderBy('lesson.sortOrder', 'ASC');

    // Aplicar filtros
    if (options?.search) {
      queryBuilder.andWhere('(lesson.title ILIKE :search OR lesson.description ILIKE :search)', {
        search: `%${options.search}%`,
      });
    }

    if (options?.type) {
      queryBuilder.andWhere('lesson.type = :type', { type: options.type });
    }

    if (options?.status) {
      queryBuilder.andWhere('lesson.status = :status', { status: options.status });
    }

    // Paginación
    const page = options?.page || 1;
    const limit = options?.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [lessons, total] = await queryBuilder.getManyAndCount();

    return {
      lessons,
      total,
      page,
      limit,
    };
  }

  async findByCourse(courseId: string, includeUnpublished = false): Promise<Lesson[]> {
    const whereCondition: Record<string, unknown> = { course: { id: courseId } };

    if (!includeUnpublished) {
      whereCondition.status = LessonStatus.PUBLISHED;
    }

    return this.lessonRepository.find({
      where: whereCondition,
      relations: ['course'],
      order: { sortOrder: 'ASC' },
    });
  }

  async findOne(id: string): Promise<Lesson> {
    const lesson = await this.lessonRepository.findOne({
      where: { id },
      relations: ['course', 'course.instructor'],
    });

    if (!lesson) {
      throw new NotFoundException(`Lección con ID ${id} no encontrada`);
    }

    return lesson;
  }

  async findBySlug(courseId: string, slug: string): Promise<Lesson> {
    const lesson = await this.lessonRepository.findOne({
      where: { slug, course: { id: courseId } },
      relations: ['course', 'course.instructor'],
    });

    if (!lesson) {
      throw new NotFoundException(`Lección con slug "${slug}" no encontrada en este curso`);
    }

    return lesson;
  }

  async update(id: string, updateLessonDto: UpdateLessonDto, userId?: string): Promise<Lesson> {
    const lesson = await this.findOne(id);

    // Verificar permisos
    if (userId && lesson.course.instructor.id !== userId) {
      // Aquí deberías verificar si el usuario es admin
      throw new ForbiddenException('No tienes permisos para editar esta lección');
    }

    // Actualizar slug si cambió el título
    if (updateLessonDto.title && updateLessonDto.title !== lesson.title) {
      const newSlug = this.generateSlug(updateLessonDto.title);
      const existingLesson = await this.lessonRepository.findOne({
        where: { slug: newSlug, course: { id: lesson.course.id } },
      });
      if (existingLesson && existingLesson.id !== id) {
        throw new BadRequestException(
          `Ya existe una lección con el título "${updateLessonDto.title}" en este curso`
        );
      }
      lesson.slug = newSlug;
    }

    Object.assign(lesson, updateLessonDto);
    return this.lessonRepository.save(lesson);
  }

  async remove(id: string, userId?: string): Promise<void> {
    const lesson = await this.findOne(id);

    // Verificar permisos
    if (userId && lesson.course.instructor.id !== userId) {
      // Aquí deberías verificar si el usuario es admin
      throw new ForbiddenException('No tienes permisos para eliminar esta lección');
    }

    await this.lessonRepository.remove(lesson);
  }

  async reorderLessons(courseId: string, lessonIds: string[]): Promise<Lesson[]> {
    const lessons = await this.lessonRepository.find({
      where: { course: { id: courseId } },
      order: { sortOrder: 'ASC' },
    });

    if (lessons.length !== lessonIds.length) {
      throw new BadRequestException('La lista de IDs no coincide con las lecciones del curso');
    }

    // Verificar que todos los IDs pertenecen al curso
    const lessonIdsInCourse = lessons.map(l => l.id).sort();
    const providedIds = [...lessonIds].sort();

    if (JSON.stringify(lessonIdsInCourse) !== JSON.stringify(providedIds)) {
      throw new BadRequestException('Algunos IDs no pertenecen a este curso');
    }

    // Actualizar el orden
    const updates = lessonIds.map((id, index) => ({
      id,
      sortOrder: index + 1,
    }));

    await Promise.all(
      updates.map(update =>
        this.lessonRepository.update(update.id, { sortOrder: update.sortOrder })
      )
    );

    // Retornar las lecciones actualizadas
    return this.findByCourse(courseId, true);
  }

  async duplicateLesson(id: string, userId?: string): Promise<Lesson> {
    const originalLesson = await this.findOne(id);

    // Verificar permisos
    if (userId && originalLesson.course.instructor.id !== userId) {
      throw new ForbiddenException('No tienes permisos para duplicar esta lección');
    }

    // Crear una copia
    const duplicatedLesson = this.lessonRepository.create({
      ...originalLesson,
      id: undefined, // Remover ID para crear uno nuevo
      title: `${originalLesson.title} (Copia)`,
      slug: this.generateSlug(`${originalLesson.title} (Copia)`),
      status: LessonStatus.DRAFT,
      sortOrder: originalLesson.sortOrder + 1,
    });

    // Actualizar el orden de las lecciones posteriores
    await this.lessonRepository
      .createQueryBuilder()
      .update(Lesson)
      .set({ sortOrder: () => 'sortOrder + 1' })
      .where('course.id = :courseId AND sortOrder > :sortOrder', {
        courseId: originalLesson.course.id,
        sortOrder: originalLesson.sortOrder,
      })
      .execute();

    return this.lessonRepository.save(duplicatedLesson);
  }

  async getLessonStats(id: string): Promise<{
    completionRate: number;
    averageWatchTime: number;
    studentsCount: number;
  }> {
    // Esta consulta requiere que tengas la entidad Progress configurada
    const result = await this.lessonRepository
      .createQueryBuilder('lesson')
      .leftJoin('lesson.progress', 'progress')
      .select([
        'COUNT(DISTINCT progress.userId) as studentsCount',
        "AVG(CASE WHEN progress.status = 'completed' THEN 1 ELSE 0 END) * 100 as completionRate",
        'AVG(progress.watchTime) as averageWatchTime',
      ])
      .where('lesson.id = :id', { id })
      .getRawOne();

    return {
      studentsCount: parseInt(result.studentsCount) || 0,
      completionRate: parseFloat(result.completionRate) || 0,
      averageWatchTime: parseFloat(result.averageWatchTime) || 0,
    };
  }

  async searchLessons(options: {
    query: string;
    type?: string;
    level?: string;
    page?: number;
    limit?: number;
  }): Promise<{ lessons: Lesson[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.lessonRepository
      .createQueryBuilder('lesson')
      .leftJoinAndSelect('lesson.course', 'course')
      .leftJoinAndSelect('course.instructor', 'instructor')
      .where('lesson.status = :status', { status: LessonStatus.PUBLISHED })
      .andWhere('course.status = :courseStatus', { courseStatus: 'published' })
      .andWhere(
        '(lesson.title ILIKE :query OR lesson.description ILIKE :query OR course.title ILIKE :query)',
        { query: `%${options.query}%` }
      )
      .orderBy('lesson.updatedAt', 'DESC');

    // Aplicar filtros adicionales
    if (options.type) {
      queryBuilder.andWhere('lesson.type = :type', { type: options.type });
    }

    if (options.level) {
      queryBuilder.andWhere('course.level = :level', { level: options.level });
    }

    // Paginación
    const page = options.page || 1;
    const limit = options.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [lessons, total] = await queryBuilder.getManyAndCount();

    return {
      lessons,
      total,
      page,
      limit,
    };
  }

  private generateSlug(title: string): string {
    return title
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '') // Remover acentos
      .replace(/[^a-z0-9\s-]/g, '') // Remover caracteres especiales
      .replace(/\s+/g, '-') // Reemplazar espacios con guiones
      .replace(/-+/g, '-') // Remover guiones duplicados
      .trim();
  }
}
