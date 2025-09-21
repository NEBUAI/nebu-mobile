import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindManyOptions, Like } from 'typeorm';

import { Course, CourseStatus } from '../entities/course.entity';
import { User } from '../../users/entities/user.entity';
import { CreateCourseDto } from '../dto/create-course.dto';
import { UpdateCourseDto } from '../dto/update-course.dto';

@Injectable()
export class CoursesService {
  constructor(
    @InjectRepository(Course)
    private courseRepository: Repository<Course>
  ) {}

  async create(createCourseDto: CreateCourseDto, instructor: User): Promise<Course> {
    const course = this.courseRepository.create({
      ...createCourseDto,
      instructorId: instructor.id,
      slug: this.generateSlug(createCourseDto.title),
    });

    return this.courseRepository.save(course);
  }

  async findAll(
    options: {
      page?: number;
      limit?: number;
      search?: string;
      category?: string;
      level?: string;
      status?: CourseStatus;
      featured?: boolean;
      published?: boolean;
    } = {}
  ): Promise<{ courses: Course[]; total: number; pages: number }> {
    const {
      page = 1,
      limit = 12,
      search,
      category,
      level,
      status,
      featured,
      published = true,
    } = options;

    const queryOptions: FindManyOptions<Course> = {
      skip: (page - 1) * limit,
      take: limit,
      order: { createdAt: 'DESC' },
      where: {},
    };

    // Build where conditions
    const whereConditions: Record<string, unknown> = {};

    if (published !== undefined) {
      whereConditions.isPublished = published;
    }

    if (status) {
      whereConditions.status = status;
    }

    if (featured !== undefined) {
      whereConditions.isFeatured = featured;
    }

    if (level) {
      whereConditions.level = level;
    }

    if (category) {
      whereConditions.categoryId = category;
    }

    if (search) {
      whereConditions.title = Like(`%${search}%`);
    }

    queryOptions.where = whereConditions;

    const [courses, total] = await this.courseRepository.findAndCount(queryOptions);

    return {
      courses,
      total,
      pages: Math.ceil(total / limit),
    };
  }

  async findPublished(
    options: {
      page?: number;
      limit?: number;
      search?: string;
      category?: string;
      level?: string;
      featured?: boolean;
    } = {}
  ): Promise<{ courses: Course[]; total: number; pages: number }> {
    return this.findAll({ ...options, published: true, status: CourseStatus.PUBLISHED });
  }

  async findFeatured(limit = 6): Promise<Course[]> {
    return this.courseRepository.find({
      where: {
        isFeatured: true,
        isPublished: true,
        status: CourseStatus.PUBLISHED,
      },
      relations: ['instructor', 'category'],
      order: { studentsCount: 'DESC' },
      take: limit,
    });
  }

  async findTopRated(limit = 6): Promise<Course[]> {
    return this.courseRepository.find({
      where: {
        isPublished: true,
        status: CourseStatus.PUBLISHED,
      },
      relations: ['instructor', 'category'],
      order: { averageRating: 'DESC', reviewsCount: 'DESC' },
      take: limit,
    });
  }

  async findBySlug(slug: string): Promise<Course> {
    const course = await this.courseRepository.findOne({
      where: { slug },
      relations: ['instructor', 'category', 'lessons', 'reviews'],
    });

    if (!course) {
      throw new NotFoundException('Curso no encontrado');
    }

    // Only return published courses to non-owners
    if (!course.isPublished || course.status !== CourseStatus.PUBLISHED) {
      throw new NotFoundException('Curso no encontrado');
    }

    return course;
  }

  async findOne(id: string, user?: User): Promise<Course> {
    const course = await this.courseRepository
      .createQueryBuilder('course')
      .leftJoinAndSelect('course.instructor', 'instructor')
      .leftJoinAndSelect('course.category', 'category')
      .leftJoinAndSelect('course.lessons', 'lessons')
      .leftJoinAndSelect('course.students', 'students')
      .leftJoinAndSelect('course.reviews', 'reviews')
      .where('course.id = :id', { id })
      .getOne();

    if (!course) {
      throw new NotFoundException('Curso no encontrado');
    }

    // Check permissions for unpublished courses
    if (!course.isPublished || course.status !== CourseStatus.PUBLISHED) {
      if (!user || (course.instructorId !== user.id && !user.isAdmin)) {
        throw new NotFoundException('Curso no encontrado');
      }
    }

    return course;
  }

  async update(id: string, updateCourseDto: UpdateCourseDto, user: User): Promise<Course> {
    const course = await this.findOne(id, user);

    // Check permissions
    if (course.instructorId !== user.id && !user.isAdmin) {
      throw new ForbiddenException('No tienes permisos para editar este curso');
    }

    // Update slug if title changed
    if (updateCourseDto.title && updateCourseDto.title !== course.title) {
      course.slug = this.generateSlug(updateCourseDto.title);
    }

    Object.assign(course, updateCourseDto);
    return this.courseRepository.save(course);
  }

  async remove(id: string, user: User): Promise<void> {
    const course = await this.findOne(id, user);

    // Check permissions
    if (course.instructorId !== user.id && !user.isAdmin) {
      throw new ForbiddenException('No tienes permisos para eliminar este curso');
    }

    // Soft delete - change status instead of actually deleting
    course.status = CourseStatus.ARCHIVED;
    await this.courseRepository.save(course);
  }

  async publish(id: string, user: User): Promise<Course> {
    const course = await this.findOne(id, user);

    // Check permissions
    if (course.instructorId !== user.id && !user.isAdmin) {
      throw new ForbiddenException('No tienes permisos para publicar este curso');
    }

    course.isPublished = true;
    course.status = CourseStatus.PUBLISHED;
    course.publishedAt = new Date();

    return this.courseRepository.save(course);
  }

  async unpublish(id: string, user: User): Promise<Course> {
    const course = await this.findOne(id, user);

    // Check permissions
    if (course.instructorId !== user.id && !user.isAdmin) {
      throw new ForbiddenException('No tienes permisos para despublicar este curso');
    }

    course.isPublished = false;
    course.status = CourseStatus.DRAFT;

    return this.courseRepository.save(course);
  }

  async enrollUser(courseId: string, user: User): Promise<Course> {
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
      relations: ['students'],
    });

    if (!course) {
      throw new NotFoundException('Curso no encontrado');
    }

    if (!course.isPublished) {
      throw new ForbiddenException('No puedes inscribirte en un curso no publicado');
    }

    // Check if user is already enrolled
    const isEnrolled = course.students?.some(student => student.id === user.id);
    if (isEnrolled) {
      throw new ForbiddenException('Ya estás inscrito en este curso');
    }

    // Add user to course
    if (!course.students) {
      course.students = [];
    }
    course.students.push(user);
    course.studentsCount = course.students.length;

    return this.courseRepository.save(course);
  }

  async unenrollUser(courseId: string, user: User): Promise<Course> {
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
      relations: ['students'],
    });

    if (!course) {
      throw new NotFoundException('Curso no encontrado');
    }

    // Remove user from course
    if (course.students) {
      course.students = course.students.filter(student => student.id !== user.id);
      course.studentsCount = course.students.length;
    }

    return this.courseRepository.save(course);
  }

  async isUserEnrolled(courseId: string, userId: string): Promise<boolean> {
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
      relations: ['students'],
    });

    if (!course) {
      return false;
    }

    return course.students?.some(student => student.id === userId) || false;
  }

  async getInstructorCourses(instructorId: string): Promise<Course[]> {
    return this.courseRepository.find({
      where: { instructorId },
      relations: ['category', 'lessons'],
      order: { createdAt: 'DESC' },
    });
  }

  async updateStats(courseId: string): Promise<void> {
    // This would be called when reviews, enrollments, etc. change
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
      relations: ['students', 'reviews', 'lessons'],
    });

    if (course) {
      course.studentsCount = course.students?.length || 0;
      course.reviewsCount = course.reviews?.length || 0;
      course.lessonsCount = course.lessons?.length || 0;

      // Calculate average rating
      if (course.reviews && course.reviews.length > 0) {
        const totalRating = course.reviews.reduce((sum, review) => sum + review.rating, 0);
        course.averageRating = totalRating / course.reviews.length;
      }

      await this.courseRepository.save(course);
    }
  }

  async findTopCourses(limit: number = 6): Promise<Course[]> {
    // Use simple query without relations to avoid missing column errors
    const query = `
      SELECT id, title, slug, description, status, "isPublished", "studentsCount", "averageRating", "publishedAt", "createdAt", "updatedAt"
      FROM courses 
      WHERE status = 'PUBLISHED' AND "isPublished" = true
      ORDER BY "studentsCount" DESC, "averageRating" DESC, "publishedAt" DESC
      LIMIT $1
    `;
    
    const rawResults = await this.courseRepository.query(query, [limit]);
    
    // Convert to Course entities
    return rawResults.map(row => {
      const course = new Course();
      course.id = row.id;
      course.title = row.title;
      course.slug = row.slug;
      course.description = row.description;
      course.status = row.status;
      course.isPublished = row.isPublished;
      course.studentsCount = row.studentsCount || 0;
      course.averageRating = parseFloat(row.averageRating) || 0;
      course.publishedAt = row.publishedAt;
      course.createdAt = row.createdAt;
      course.updatedAt = row.updatedAt;
      return course;
    });
  }

  async checkUserAccess(
    courseId: string,
    userId: string
  ): Promise<{
    hasAccess: boolean;
    reason?: string;
    expiresAt?: string;
  }> {
    // First, get the course
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
      relations: ['instructor', 'category'],
    });

    if (!course) {
      throw new NotFoundException('Curso no encontrado');
    }

    // Check if the user is the instructor
    if (course.instructor?.id === userId) {
      return {
        hasAccess: true,
        reason: 'Instructor del curso',
      };
    }

    // Check if user has purchased the course
    // Note: You might need to inject PurchaseRepository here
    // For now, returning basic access check
    const hasAccess = course.price === 0; // Free courses

    return {
      hasAccess,
      reason: hasAccess ? 'Curso gratuito' : 'Requiere compra',
    };
  }

  private generateSlug(title: string): string {
    return title
      .toLowerCase()
      .replace(/[^a-z0-9\s-]/g, '') // Remove special characters
      .replace(/\s+/g, '-') // Replace spaces with hyphens
      .replace(/-+/g, '-') // Replace multiple hyphens with single hyphen
      .trim()
      .substring(0, 100); // Limit length
  }
}
