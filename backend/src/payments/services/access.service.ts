import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Subscription, SubscriptionStatus } from '../entities/subscription.entity';
import { Purchase, PurchaseStatus } from '../entities/purchase.entity';
import { User } from '../../users/entities/user.entity';
import { Course, CourseStatus } from '../../courses/entities/course.entity';

export interface CourseAccess {
  hasAccess: boolean;
  accessType: 'subscription' | 'purchase' | 'none';
  subscription?: Subscription;
  purchase?: Purchase;
  expiresAt?: Date;
  daysRemaining?: number;
}

export interface UserAccessSummary {
  hasActiveSubscription: boolean;
  subscription?: Subscription;
  totalPurchases: number;
  accessibleCourses: string[];
  subscriptionDaysRemaining?: number;
}

@Injectable()
export class AccessService {
  private readonly logger = new Logger(AccessService.name);

  constructor(
    @InjectRepository(Subscription)
    private readonly subscriptionRepository: Repository<Subscription>,
    @InjectRepository(Purchase)
    private readonly purchaseRepository: Repository<Purchase>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>
  ) {}

  /**
   * Regla 1: Si el usuario tiene una Subscription activa, no necesita pagar individualmente.
   * Regla 2: Si no tiene suscripción, puede comprar cursos sueltos.
   * Regla 3: Una compra individual sigue siendo válida aunque el usuario cancele su suscripción.
   */
  async checkCourseAccess(userId: string, courseId: string): Promise<CourseAccess> {
    this.logger.debug(`Checking course access for user ${userId}, course ${courseId}`);

    // Verificar suscripción activa (Regla 1)
    const activeSubscription = await this.getActiveSubscription(userId);
    if (activeSubscription) {
      this.logger.debug(`User has active subscription: ${activeSubscription.id}`);
      return {
        hasAccess: true,
        accessType: 'subscription',
        subscription: activeSubscription,
        expiresAt: activeSubscription.currentPeriodEnd,
        daysRemaining: activeSubscription.daysUntilRenewal,
      };
    }

    // Verificar compra individual (Regla 3)
    const purchase = await this.getCoursePurchase(userId, courseId);
    if (purchase && purchase.hasAccess) {
      this.logger.debug(`User has individual purchase: ${purchase.id}`);
      return {
        hasAccess: true,
        accessType: 'purchase',
        purchase,
        // Las compras individuales no expiran
      };
    }

    this.logger.debug(`User has no access to course`);
    return {
      hasAccess: false,
      accessType: 'none',
    };
  }

  async getActiveSubscription(userId: string): Promise<Subscription | null> {
    const subscription = await this.subscriptionRepository.findOne({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      order: { currentPeriodEnd: 'DESC' },
    });

    // Verificar que realmente esté vigente
    if (subscription && subscription.hasAccess) {
      return subscription;
    }

    return null;
  }

  async getCourseAccess(userId: string, courseIds: string[]): Promise<Map<string, CourseAccess>> {
    const accessMap = new Map<string, CourseAccess>();

    // Verificar suscripción una sola vez
    const activeSubscription = await this.getActiveSubscription(userId);

    for (const courseId of courseIds) {
      if (activeSubscription) {
        // Si tiene suscripción activa, tiene acceso a todo
        accessMap.set(courseId, {
          hasAccess: true,
          accessType: 'subscription',
          subscription: activeSubscription,
          expiresAt: activeSubscription.currentPeriodEnd,
          daysRemaining: activeSubscription.daysUntilRenewal,
        });
      } else {
        // Verificar compra individual
        const purchase = await this.getCoursePurchase(userId, courseId);
        accessMap.set(courseId, {
          hasAccess: purchase?.hasAccess || false,
          accessType: purchase?.hasAccess ? 'purchase' : 'none',
          purchase: purchase || undefined,
        });
      }
    }

    return accessMap;
  }

  async getUserAccessSummary(userId: string): Promise<UserAccessSummary> {
    const activeSubscription = await this.getActiveSubscription(userId);

    // Obtener todas las compras completadas
    const purchases = await this.purchaseRepository.find({
      where: {
        userId,
        status: PurchaseStatus.COMPLETED,
      },
      relations: ['course'],
    });

    const accessibleCourses: string[] = [];

    if (activeSubscription) {
      // Si tiene suscripción, tiene acceso a todos los cursos publicados
      const allCourses = await this.courseRepository.find({
        where: { status: CourseStatus.PUBLISHED },
        select: ['id'],
      });
      accessibleCourses.push(...allCourses.map(course => course.id));
    } else {
      // Solo cursos comprados individualmente
      accessibleCourses.push(...purchases.filter(p => p.hasAccess).map(p => p.courseId));
    }

    return {
      hasActiveSubscription: !!activeSubscription,
      subscription: activeSubscription || undefined,
      totalPurchases: purchases.length,
      accessibleCourses: Array.from(new Set(accessibleCourses)), // Eliminar duplicados
      subscriptionDaysRemaining: activeSubscription?.daysUntilRenewal,
    };
  }

  private async getCoursePurchase(userId: string, courseId: string): Promise<Purchase | null> {
    return this.purchaseRepository.findOne({
      where: {
        userId,
        courseId,
        status: PurchaseStatus.COMPLETED,
      },
    });
  }

  async canAccessCourse(userId: string, courseId: string): Promise<boolean> {
    const access = await this.checkCourseAccess(userId, courseId);
    return access.hasAccess;
  }

  async requiresCourseAccess(userId: string, courseId: string): Promise<void> {
    const hasAccess = await this.canAccessCourse(userId, courseId);
    if (!hasAccess) {
      throw new Error(
        'Access denied: You need an active subscription or individual purchase to access this course'
      );
    }
  }

  async getAccessStats(): Promise<{
    totalActiveSubscriptions: number;
    totalPurchases: number;
    totalRevenue: number;
    subscriptionRevenue: number;
    purchaseRevenue: number;
  }> {
    // Suscripciones activas
    const activeSubscriptions = await this.subscriptionRepository.count({
      where: { status: SubscriptionStatus.ACTIVE },
    });

    // Compras completadas
    const completedPurchases = await this.purchaseRepository.find({
      where: { status: PurchaseStatus.COMPLETED },
    });

    // Suscripciones para calcular revenue
    const subscriptions = await this.subscriptionRepository.find({
      where: { status: SubscriptionStatus.ACTIVE },
    });

    const subscriptionRevenue = subscriptions.reduce((total, sub) => total + Number(sub.amount), 0);
    const purchaseRevenue = completedPurchases.reduce(
      (total, purchase) => total + Number(purchase.finalPrice),
      0
    );

    return {
      totalActiveSubscriptions: activeSubscriptions,
      totalPurchases: completedPurchases.length,
      totalRevenue: subscriptionRevenue + purchaseRevenue,
      subscriptionRevenue,
      purchaseRevenue,
    };
  }
}
