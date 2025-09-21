import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Comment } from '../entities/comment.entity';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Lesson } from '../../courses/entities/lesson.entity';
import { CreateCommentDto } from '../dto/create-comment.dto';
import { UpdateCommentDto } from '../dto/update-comment.dto';
import { CommentStatus } from '../entities/comment.entity';

@Injectable()
export class CommentsService {
  constructor(
    @InjectRepository(Comment)
    private readonly commentRepository: Repository<Comment>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>,
    @InjectRepository(Lesson)
    private readonly lessonRepository: Repository<Lesson>
  ) {}

  async create(createCommentDto: CreateCommentDto, userId: string): Promise<Comment> {
    // Verificar que el usuario existe
    const user = await this.userRepository.findOne({
      where: { id: userId },
    });
    if (!user) {
      throw new NotFoundException(`Usuario con ID ${userId} no encontrado`);
    }

    // Verificar que el curso existe
    const course = await this.courseRepository.findOne({
      where: { id: createCommentDto.courseId },
    });
    if (!course) {
      throw new NotFoundException(`Curso con ID ${createCommentDto.courseId} no encontrado`);
    }

    // Verificar que la lección existe si se especifica
    if (createCommentDto.lessonId) {
      const lesson = await this.lessonRepository.findOne({
        where: { id: createCommentDto.lessonId, course: { id: createCommentDto.courseId } },
      });
      if (!lesson) {
        throw new NotFoundException(
          `Lección con ID ${createCommentDto.lessonId} no encontrada en este curso`
        );
      }
    }

    // Verificar que el comentario padre existe si se especifica
    if (createCommentDto.parentId) {
      const parentComment = await this.commentRepository.findOne({
        where: { id: createCommentDto.parentId, course: { id: createCommentDto.courseId } },
      });
      if (!parentComment) {
        throw new NotFoundException(
          `Comentario padre con ID ${createCommentDto.parentId} no encontrado`
        );
      }
    }

    const comment = this.commentRepository.create({
      ...createCommentDto,
      userId,
      status: CommentStatus.APPROVED, // Auto-aprobar por ahora, se puede cambiar a moderación manual
    });

    return this.commentRepository.save(comment);
  }

  async findAll(options?: {
    status?: string;
    page?: number;
    limit?: number;
  }): Promise<{ comments: Comment[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.commentRepository
      .createQueryBuilder('comment')
      .leftJoinAndSelect('comment.user', 'user')
      .leftJoinAndSelect('comment.course', 'course')
      .leftJoinAndSelect('comment.lesson', 'lesson')
      .leftJoinAndSelect('comment.parent', 'parent')
      .leftJoinAndSelect('comment.replies', 'replies')
      .orderBy('comment.createdAt', 'DESC');

    // Aplicar filtros
    if (options?.status) {
      queryBuilder.andWhere('comment.status = :status', { status: options.status });
    }

    // Paginación
    const page = options?.page || 1;
    const limit = options?.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [comments, total] = await queryBuilder.getManyAndCount();

    return {
      comments,
      total,
      page,
      limit,
    };
  }

  async findByCourse(courseId: string, includeHidden = false): Promise<Comment[]> {
    const whereCondition: Record<string, unknown> = { course: { id: courseId } };

    if (!includeHidden) {
      whereCondition.status = 'approved';
    }

    return this.commentRepository.find({
      where: whereCondition,
      relations: ['user', 'lesson', 'replies', 'replies.user'],
      order: {
        isPinned: 'DESC',
        createdAt: 'DESC',
        replies: { createdAt: 'ASC' },
      },
    });
  }

  async findByLesson(lessonId: string, includeHidden = false): Promise<Comment[]> {
    const whereCondition: Record<string, unknown> = { lesson: { id: lessonId } };

    if (!includeHidden) {
      whereCondition.status = 'approved';
    }

    return this.commentRepository.find({
      where: whereCondition,
      relations: ['user', 'course', 'replies', 'replies.user'],
      order: {
        isPinned: 'DESC',
        createdAt: 'DESC',
        replies: { createdAt: 'ASC' },
      },
    });
  }

  async findOne(id: string): Promise<Comment> {
    const comment = await this.commentRepository.findOne({
      where: { id },
      relations: ['user', 'course', 'lesson', 'parent', 'replies', 'replies.user'],
    });

    if (!comment) {
      throw new NotFoundException(`Comentario con ID ${id} no encontrado`);
    }

    return comment;
  }

  async update(
    id: string,
    updateCommentDto: UpdateCommentDto,
    _userId: string,
    userRole?: string
  ): Promise<Comment> {
    const comment = await this.findOne(id);

    // Solo el autor o un admin/instructor puede editar
    if (comment.user.id !== _userId && !['admin', 'instructor'].includes(userRole)) {
      throw new ForbiddenException('No tienes permisos para editar este comentario');
    }

    Object.assign(comment, updateCommentDto);
    return this.commentRepository.save(comment);
  }

  async remove(id: string, _userId: string, userRole?: string): Promise<void> {
    const comment = await this.findOne(id);

    // Solo el autor o un admin puede eliminar
    if (comment.user.id !== _userId && userRole !== 'admin') {
      throw new ForbiddenException('No tienes permisos para eliminar este comentario');
    }

    await this.commentRepository.remove(comment);
  }

  async likeComment(id: string, _userId: string): Promise<Comment> {
    const comment = await this.findOne(id);

    // Aquí podrías implementar un sistema más complejo con una tabla de likes
    // Por ahora solo incrementamos el contador
    comment.likesCount += 1;

    return this.commentRepository.save(comment);
  }

  async pinComment(id: string, userId: string, userRole: string): Promise<Comment> {
    if (!['admin', 'instructor'].includes(userRole)) {
      throw new ForbiddenException('No tienes permisos para fijar comentarios');
    }

    const comment = await this.findOne(id);
    comment.isPinned = !comment.isPinned;

    return this.commentRepository.save(comment);
  }

  async moderateComment(
    id: string,
    status: string,
    _userId: string,
    userRole: string
  ): Promise<Comment> {
    if (!['admin', 'instructor'].includes(userRole)) {
      throw new ForbiddenException('No tienes permisos para moderar comentarios');
    }

    const comment = await this.findOne(id);
    comment.status = status as CommentStatus;

    return this.commentRepository.save(comment);
  }

  async getCommentStats(courseId?: string): Promise<{
    totalComments: number;
    approvedComments: number;
    pendingComments: number;
    averageCommentsPerLesson: number;
  }> {
    const query = this.commentRepository.createQueryBuilder('comment');

    if (courseId) {
      query.where('comment.course.id = :courseId', { courseId });
    }

    const result = await query
      .select([
        'COUNT(*) as totalComments',
        "COUNT(CASE WHEN comment.status = 'approved' THEN 1 END) as approvedComments",
        "COUNT(CASE WHEN comment.status = 'pending' THEN 1 END) as pendingComments",
      ])
      .getRawOne();

    // Calcular promedio por lección
    const lessonQuery = this.commentRepository
      .createQueryBuilder('comment')
      .leftJoin('comment.lesson', 'lesson');

    if (courseId) {
      lessonQuery.where('comment.course.id = :courseId', { courseId });
    }

    const lessonResult = await lessonQuery
      .select(['COUNT(DISTINCT lesson.id) as totalLessons'])
      .getRawOne();

    const totalLessons = parseInt(lessonResult.totalLessons) || 1;
    const averageCommentsPerLesson = parseInt(result.totalComments) / totalLessons;

    return {
      totalComments: parseInt(result.totalComments) || 0,
      approvedComments: parseInt(result.approvedComments) || 0,
      pendingComments: parseInt(result.pendingComments) || 0,
      averageCommentsPerLesson: Math.round(averageCommentsPerLesson * 100) / 100,
    };
  }

  async searchComments(options: {
    query: string;
    courseId?: string;
    lessonId?: string;
    page?: number;
    limit?: number;
  }): Promise<{ comments: Comment[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.commentRepository
      .createQueryBuilder('comment')
      .leftJoinAndSelect('comment.user', 'user')
      .leftJoinAndSelect('comment.course', 'course')
      .leftJoinAndSelect('comment.lesson', 'lesson')
      .where('comment.status = :status', { status: CommentStatus.APPROVED })
      .andWhere('(comment.content ILIKE :query)', { query: `%${options.query}%` })
      .orderBy('comment.createdAt', 'DESC');

    // Aplicar filtros adicionales
    if (options.courseId) {
      queryBuilder.andWhere('comment.courseId = :courseId', { courseId: options.courseId });
    }

    if (options.lessonId) {
      queryBuilder.andWhere('comment.lessonId = :lessonId', { lessonId: options.lessonId });
    }

    // Paginación
    const page = options.page || 1;
    const limit = options.limit || 10;
    const offset = (page - 1) * limit;

    queryBuilder.skip(offset).take(limit);

    const [comments, total] = await queryBuilder.getManyAndCount();

    return {
      comments,
      total,
      page,
      limit,
    };
  }
}
