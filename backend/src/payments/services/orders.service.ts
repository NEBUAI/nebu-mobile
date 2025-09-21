import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus } from '../entities/order.entity';
import { CreateOrderDto, UpdateOrderDto } from '../dto/create-order.dto';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { Coupon } from '../entities/coupon.entity';

@Injectable()
export class OrdersService {
  private readonly logger = new Logger(OrdersService.name);

  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>,
    @InjectRepository(Coupon)
    private readonly couponRepository: Repository<Coupon>
  ) {}

  async create(createOrderDto: CreateOrderDto): Promise<Order> {
    const { userId, courseIds, discountCode, totalAmount, currency } = createOrderDto;

    // Verificar que el usuario existe
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException(`Usuario con ID ${userId} no encontrado`);
    }

    // Verificar que todos los cursos existen
    const courses = await this.courseRepository
      .createQueryBuilder('course')
      .where('course.id IN (:...courseIds)', { courseIds })
      .getMany();

    if (courses.length !== courseIds.length) {
      const foundIds = courses.map(c => c.id);
      const missingIds = courseIds.filter(id => !foundIds.includes(id));
      throw new NotFoundException(`Cursos no encontrados: ${missingIds.join(', ')}`);
    }

    // Verificar que el usuario no ya tenga acceso a estos cursos
    const userEnrollments = await this.userRepository
      .createQueryBuilder('user')
      .leftJoinAndSelect('user.enrolledCourses', 'enrolledCourse')
      .where('user.id = :userId', { userId })
      .getOne();

    if (userEnrollments?.enrolledCourses) {
      const enrolledCourseIds = userEnrollments.enrolledCourses.map(c => c.id);
      const alreadyEnrolled = courseIds.filter(id => enrolledCourseIds.includes(id));
      if (alreadyEnrolled.length > 0) {
        throw new BadRequestException(
          `El usuario ya está inscrito en los siguientes cursos: ${alreadyEnrolled.join(', ')}`
        );
      }
    }

    // Validar código de descuento si se proporciona
    let discountPercentage: number | undefined;
    if (discountCode) {
      const coupon = await this.couponRepository.findOne({
        where: {
          code: discountCode,
          isActive: true,
        },
      });

      if (!coupon) {
        throw new BadRequestException(`Código de descuento inválido: ${discountCode}`);
      }

      if (coupon.validUntil && coupon.validUntil < new Date()) {
        throw new BadRequestException(`Código de descuento expirado: ${discountCode}`);
      }

      if (coupon.usageLimit && coupon.usageCount >= coupon.usageLimit) {
        throw new BadRequestException(`Código de descuento agotado: ${discountCode}`);
      }

      discountPercentage = coupon.value;
    }

    // Crear la orden
    const order = this.orderRepository.create({
      userId,
      courses,
      totalAmount,
      currency: currency || 'usd',
      discountCode,
      discountPercentage,
      status: OrderStatus.PENDING,
    });

    const savedOrder = await this.orderRepository.save(order);

    this.logger.log(`Orden creada: ${savedOrder.id} para usuario ${userId}`);

    return savedOrder;
  }

  async findAll(
    status?: OrderStatus,
    userId?: string,
    page = 1,
    limit = 10
  ): Promise<{ orders: Order[]; total: number; page: number; limit: number }> {
    const queryBuilder = this.orderRepository
      .createQueryBuilder('order')
      .leftJoinAndSelect('order.user', 'user')
      .leftJoinAndSelect('order.courses', 'courses');

    if (status) {
      queryBuilder.andWhere('order.status = :status', { status });
    }

    if (userId) {
      queryBuilder.andWhere('order.userId = :userId', { userId });
    }

    const total = await queryBuilder.getCount();
    const orders = await queryBuilder
      .skip((page - 1) * limit)
      .take(limit)
      .orderBy('order.createdAt', 'DESC')
      .getMany();

    return { orders, total, page, limit };
  }

  async findOne(id: string): Promise<Order> {
    const order = await this.orderRepository.findOne({
      where: { id },
      relations: ['user', 'courses'],
    });

    if (!order) {
      throw new NotFoundException(`Orden con ID ${id} no encontrada`);
    }

    return order;
  }

  async findByUser(
    userId: string,
    page = 1,
    limit = 10
  ): Promise<{ orders: Order[]; total: number }> {
    const [orders, total] = await this.orderRepository.findAndCount({
      where: { userId },
      relations: ['courses'],
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });

    return { orders, total };
  }

  async update(id: string, updateOrderDto: UpdateOrderDto): Promise<Order> {
    const order = await this.findOne(id);

    if (updateOrderDto.status) {
      // Mapear enum string a OrderStatus enum
      const statusMap: Record<string, OrderStatus> = {
        pending: OrderStatus.PENDING,
        processing: OrderStatus.PROCESSING,
        completed: OrderStatus.COMPLETED,
        failed: OrderStatus.FAILED,
        cancelled: OrderStatus.CANCELLED,
      };

      order.status = statusMap[updateOrderDto.status] || OrderStatus.PENDING;

      if (updateOrderDto.status === 'completed') {
        order.completedAt = new Date();
        // Inscribir al usuario en los cursos
        await this.enrollUserInCourses(
          order.userId,
          order.courses.map(c => c.id)
        );
      }
    }

    if (updateOrderDto.stripePaymentIntentId) {
      order.stripePaymentIntentId = updateOrderDto.stripePaymentIntentId;
    }

    const updatedOrder = await this.orderRepository.save(order);

    this.logger.log(`Orden actualizada: ${id}, nuevo estado: ${updatedOrder.status}`);

    return updatedOrder;
  }

  async confirmPayment(stripePaymentIntentId: string): Promise<Order> {
    const order = await this.orderRepository.findOne({
      where: { stripePaymentIntentId },
      relations: ['user', 'courses'],
    });

    if (!order) {
      throw new NotFoundException(
        `Orden con Payment Intent ${stripePaymentIntentId} no encontrada`
      );
    }

    if (order.status === OrderStatus.COMPLETED) {
      this.logger.warn(`Orden ${order.id} ya está completada`);
      return order;
    }

    // Marcar como completada
    order.status = OrderStatus.COMPLETED;
    order.completedAt = new Date();

    // Inscribir al usuario en los cursos
    await this.enrollUserInCourses(
      order.userId,
      order.courses.map(c => c.id)
    );

    // Incrementar uso del cupón si aplica
    if (order.discountCode) {
      await this.incrementCouponUsage(order.discountCode);
    }

    const completedOrder = await this.orderRepository.save(order);

    this.logger.log(`Pago confirmado para orden: ${order.id}`);

    return completedOrder;
  }

  async cancel(id: string): Promise<Order> {
    const order = await this.findOne(id);

    if (order.status === OrderStatus.COMPLETED) {
      throw new BadRequestException('No se puede cancelar una orden completada');
    }

    order.status = OrderStatus.CANCELLED;

    const cancelledOrder = await this.orderRepository.save(order);

    this.logger.log(`Orden cancelada: ${id}`);

    return cancelledOrder;
  }

  async remove(id: string): Promise<void> {
    const order = await this.findOne(id);

    if (order.status === OrderStatus.COMPLETED) {
      throw new BadRequestException('No se puede eliminar una orden completada');
    }

    await this.orderRepository.remove(order);

    this.logger.log(`Orden eliminada: ${id}`);
  }

  private async enrollUserInCourses(userId: string, courseIds: string[]): Promise<void> {
    const user = await this.userRepository.findOne({
      where: { id: userId },
      relations: ['enrolledCourses'],
    });

    if (!user) {
      throw new NotFoundException(`Usuario con ID ${userId} no encontrado`);
    }

    const courses = await this.courseRepository
      .createQueryBuilder('course')
      .where('course.id IN (:...courseIds)', { courseIds })
      .getMany();

    // Agregar cursos que no estén ya inscritos
    const currentCourseIds = user.enrolledCourses?.map(c => c.id) || [];
    const newCourses = courses.filter(course => !currentCourseIds.includes(course.id));

    if (newCourses.length > 0) {
      user.enrolledCourses = [...(user.enrolledCourses || []), ...newCourses];
      await this.userRepository.save(user);

      this.logger.log(
        `Usuario ${userId} inscrito en cursos: ${newCourses.map(c => c.id).join(', ')}`
      );
    }
  }

  private async incrementCouponUsage(couponCode: string): Promise<void> {
    await this.couponRepository
      .createQueryBuilder()
      .update(Coupon)
      .set({ usageCount: () => 'usageCount + 1' })
      .where('code = :code', { code: couponCode })
      .execute();
  }
}
