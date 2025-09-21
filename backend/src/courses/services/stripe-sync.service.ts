import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Course, CourseStatus } from '../entities/course.entity';
import { StripeService } from '../../payments/services/stripe.service';

@Injectable()
export class StripeSyncService {
  private readonly logger = new Logger(StripeSyncService.name);

  constructor(
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>,
    private readonly stripeService: StripeService,
  ) {}

  /**
   * Sincronizar un curso con Stripe creando producto y precio
   */
  async syncCourseWithStripe(courseId: string): Promise<{
    course: Course;
    stripeProduct: any;
    stripePrice: any;
  }> {
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
    });

    if (!course) {
      throw new BadRequestException('Curso no encontrado');
    }

    if (course.isStripeEnabled && course.stripeProductId) {
      this.logger.warn(`Course ${courseId} already has Stripe integration`);
      return {
        course,
        stripeProduct: await this.stripeService.getProduct(course.stripeProductId),
        stripePrice: course.stripePriceId 
          ? await this.stripeService.getPrice(course.stripePriceId)
          : null,
      };
    }

    try {
      // 1. Crear producto en Stripe
      const stripeProduct = await this.stripeService.createProduct({
        name: course.title,
        description: course.shortDescription || course.description,
        images: course.thumbnail ? [course.thumbnail] : [],
        metadata: {
          courseId: course.id,
          courseSlug: course.slug,
          level: course.level,
          category: course.categoryId,
          instructor: course.instructorId,
        },
        active: course.status === CourseStatus.PUBLISHED,
      });

      // 2. Crear precio en Stripe (solo si el curso es de pago)
      let stripePrice = null;
      if (course.price > 0) {
        stripePrice = await this.stripeService.createPrice(stripeProduct.id, {
          unitAmount: Math.round(course.currentPrice * 100), // Convertir a centavos
          currency: 'usd',
          nickname: `${course.title} - ${course.level}`,
          metadata: {
            courseId: course.id,
            courseSlug: course.slug,
            level: course.level,
          },
        });
      }

      // 3. Actualizar curso con IDs de Stripe
      course.stripeProductId = stripeProduct.id;
      course.stripePriceId = stripePrice?.id || null;
      course.isStripeEnabled = true;

      const updatedCourse = await this.courseRepository.save(course);

      this.logger.log(`Course ${courseId} synced with Stripe successfully`);

      return {
        course: updatedCourse,
        stripeProduct,
        stripePrice,
      };
    } catch (error) {
      this.logger.error(`Failed to sync course ${courseId} with Stripe: ${error.message}`);
      throw new BadRequestException(`Error syncing course with Stripe: ${error.message}`);
    }
  }

  /**
   * Actualizar producto de Stripe cuando se actualiza el curso
   */
  async updateStripeProduct(courseId: string): Promise<{
    course: Course;
    stripeProduct: any;
  }> {
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
    });

    if (!course) {
      throw new BadRequestException('Curso no encontrado');
    }

    if (!course.isStripeEnabled || !course.stripeProductId) {
      throw new BadRequestException('El curso no está sincronizado con Stripe');
    }

    try {
      // Actualizar producto en Stripe
      const stripeProduct = await this.stripeService.updateProduct(course.stripeProductId, {
        name: course.title,
        description: course.shortDescription || course.description,
        images: course.thumbnail ? [course.thumbnail] : [],
        metadata: {
          courseId: course.id,
          courseSlug: course.slug,
          level: course.level,
          category: course.categoryId,
          instructor: course.instructorId,
        },
        active: course.status === CourseStatus.PUBLISHED,
      });

      this.logger.log(`Stripe product updated for course ${courseId}`);

      return {
        course,
        stripeProduct,
      };
    } catch (error) {
      this.logger.error(`Failed to update Stripe product for course ${courseId}: ${error.message}`);
      throw new BadRequestException(`Error updating Stripe product: ${error.message}`);
    }
  }

  /**
   * Deshabilitar integración con Stripe
   */
  async disableStripeIntegration(courseId: string): Promise<Course> {
    const course = await this.courseRepository.findOne({
      where: { id: courseId },
    });

    if (!course) {
      throw new BadRequestException('Curso no encontrado');
    }

    if (!course.isStripeEnabled) {
      throw new BadRequestException('El curso no tiene integración con Stripe habilitada');
    }

    try {
      // Deshabilitar producto en Stripe (no eliminarlo para mantener historial)
      if (course.stripeProductId) {
        await this.stripeService.updateProduct(course.stripeProductId, {
          active: false,
        });
      }

      // Limpiar campos de Stripe en el curso
      course.stripeProductId = null;
      course.stripePriceId = null;
      course.isStripeEnabled = false;

      const updatedCourse = await this.courseRepository.save(course);

      this.logger.log(`Stripe integration disabled for course ${courseId}`);

      return updatedCourse;
    } catch (error) {
      this.logger.error(`Failed to disable Stripe integration for course ${courseId}: ${error.message}`);
      throw new BadRequestException(`Error disabling Stripe integration: ${error.message}`);
    }
  }

  /**
   * Obtener cursos con integración de Stripe
   */
  async getCoursesWithStripe(): Promise<Course[]> {
    return await this.courseRepository.find({
      where: { isStripeEnabled: true },
      relations: ['instructor', 'category'],
    });
  }

  /**
   * Sincronizar múltiples cursos con Stripe
   */
  async syncMultipleCourses(courseIds: string[]): Promise<{
    successful: Array<{ courseId: string; stripeProductId: string }>;
    failed: Array<{ courseId: string; error: string }>;
  }> {
    const results = {
      successful: [] as Array<{ courseId: string; stripeProductId: string }>,
      failed: [] as Array<{ courseId: string; error: string }>,
    };

    for (const courseId of courseIds) {
      try {
        const { course, stripeProduct } = await this.syncCourseWithStripe(courseId);
        results.successful.push({
          courseId: course.id,
          stripeProductId: stripeProduct.id,
        });
      } catch (error) {
        results.failed.push({
          courseId,
          error: error.message,
        });
      }
    }

    this.logger.log(`Bulk sync completed: ${results.successful.length} successful, ${results.failed.length} failed`);

    return results;
  }
}
