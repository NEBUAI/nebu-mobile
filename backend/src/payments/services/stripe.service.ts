import { Injectable, Logger, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import Stripe from 'stripe';
import { Subscription, SubscriptionStatus } from '../entities/subscription.entity';
import { Purchase, PurchaseStatus, PaymentMethod } from '../entities/purchase.entity';
import { Coupon } from '../entities/coupon.entity';
import { User } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';

@Injectable()
export class StripeService {
  private readonly logger = new Logger(StripeService.name);
  private readonly stripe: Stripe;

  constructor(
    private configService: ConfigService,
    @InjectRepository(Subscription)
    private readonly subscriptionRepository: Repository<Subscription>,
    @InjectRepository(Purchase)
    private readonly purchaseRepository: Repository<Purchase>,
    @InjectRepository(Coupon)
    private readonly couponRepository: Repository<Coupon>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>
  ) {
    this.stripe = new Stripe(this.configService.get<string>('STRIPE_SECRET_KEY'), {
      apiVersion: '2024-06-20',
    });
  }

  // ===== CUSTOMER MANAGEMENT =====

  async createOrGetCustomer(userId: string): Promise<string> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new BadRequestException('Usuario no encontrado');
    }

    // Si ya tiene customer ID, devolverlo
    if (user.stripeCustomerId) {
      try {
        await this.stripe.customers.retrieve(user.stripeCustomerId);
        return user.stripeCustomerId;
      } catch {
        this.logger.warn(`Stripe customer ${user.stripeCustomerId} not found, creating new one`);
      }
    }

    // Crear nuevo customer
    const customer = await this.stripe.customers.create({
      email: user.email,
      name: `${user.firstName} ${user.lastName}`.trim(),
      metadata: {
        userId: user.id,
        username: user.username || '',
      },
    });

    // Guardar customer ID
    await this.userRepository.update(userId, {
      stripeCustomerId: customer.id,
    });

    return customer.id;
  }

  // ===== SUBSCRIPTION MANAGEMENT =====

  async createSubscription(
    userId: string,
    priceId: string,
    paymentMethodId?: string,
    couponCode?: string
  ): Promise<{ subscription: Subscription; clientSecret?: string }> {
    const customerId = await this.createOrGetCustomer(userId);

    const subscriptionData: Stripe.SubscriptionCreateParams = {
      customer: customerId,
      items: [{ price: priceId }],
      payment_behavior: 'default_incomplete',
      payment_settings: { save_default_payment_method: 'on_subscription' },
      expand: ['latest_invoice.payment_intent'],
      metadata: { userId },
    };

    // Aplicar cupón si se proporciona
    if (couponCode) {
      const coupon = await this.validateCoupon(couponCode, userId);
      if (coupon && coupon.applicability === 'subscriptions') {
        subscriptionData.coupon = couponCode;
      }
    }

    // Agregar payment method si se proporciona
    if (paymentMethodId) {
      subscriptionData.default_payment_method = paymentMethodId;
    }

    const stripeSubscription = await this.stripe.subscriptions.create(subscriptionData);

    // Crear registro en base de datos
    const subscription = await this.createSubscriptionRecord(userId, stripeSubscription);

    const latestInvoice = stripeSubscription.latest_invoice as Stripe.Invoice;
    const paymentIntent = latestInvoice?.payment_intent;
    const clientSecret =
      typeof paymentIntent === 'string' ? undefined : paymentIntent?.client_secret;

    return {
      subscription,
      clientSecret: clientSecret || undefined,
    };
  }

  async cancelSubscription(subscriptionId: string, immediately = false): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { id: subscriptionId },
    });

    if (!subscription) {
      throw new BadRequestException('Suscripción no encontrada');
    }

    if (immediately) {
      await this.stripe.subscriptions.cancel(subscription.stripeSubscriptionId);
      subscription.status = SubscriptionStatus.CANCELED;
      subscription.canceledAt = new Date();
    } else {
      await this.stripe.subscriptions.update(subscription.stripeSubscriptionId, {
        cancel_at_period_end: true,
      });
      subscription.cancelAtPeriodEnd = subscription.currentPeriodEnd;
    }

    return this.subscriptionRepository.save(subscription);
  }

  // ===== PURCHASE MANAGEMENT =====

  async createPurchaseIntent(
    userId: string,
    courseId: string,
    couponCode?: string
  ): Promise<{ purchase: Purchase; clientSecret: string }> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    const course = await this.courseRepository.findOne({ where: { id: courseId } });

    if (!user || !course) {
      throw new BadRequestException('Usuario o curso no encontrado');
    }

    // Verificar si ya tiene acceso
    const existingPurchase = await this.purchaseRepository.findOne({
      where: { userId, courseId, status: PurchaseStatus.COMPLETED },
    });

    if (existingPurchase) {
      throw new BadRequestException('Ya tienes acceso a este curso');
    }

    let finalPrice = course.price;
    let discountAmount = 0;
    let appliedCoupon: Coupon | null = null;

    // Aplicar cupón si se proporciona
    if (couponCode) {
      appliedCoupon = await this.validateCoupon(couponCode, userId);
      if (appliedCoupon && appliedCoupon.applicability !== 'subscriptions') {
        discountAmount = appliedCoupon.calculateDiscount(course.price);
        finalPrice = course.price - discountAmount;
      }
    }

    const customerId = await this.createOrGetCustomer(userId);

    // Crear Payment Intent en Stripe
    const paymentIntent = await this.stripe.paymentIntents.create({
      amount: Math.round(finalPrice * 100), // Stripe usa centavos
      currency: 'usd',
      customer: customerId,
      metadata: {
        userId,
        courseId,
        couponCode: couponCode || '',
      },
    });

    // Crear registro de compra
    const purchase = this.purchaseRepository.create({
      userId,
      courseId,
      status: PurchaseStatus.PENDING,
      paymentMethod: PaymentMethod.STRIPE,
      originalPrice: course.price,
      discountAmount,
      finalPrice,
      currency: 'usd',
      stripePaymentIntentId: paymentIntent.id,
      stripeCustomerId: customerId,
      discountCode: couponCode || null,
      metadata: {
        courseName: course.title,
        couponApplied: !!appliedCoupon,
      },
    });

    const savedPurchase = await this.purchaseRepository.save(purchase);

    return {
      purchase: savedPurchase,
      clientSecret: paymentIntent.client_secret!,
    };
  }

  async confirmPurchase(paymentIntentId: string): Promise<Purchase> {
    const purchase = await this.purchaseRepository.findOne({
      where: { stripePaymentIntentId: paymentIntentId },
      relations: ['course'],
    });

    if (!purchase) {
      throw new BadRequestException('Compra no encontrada');
    }

    const paymentIntent = await this.stripe.paymentIntents.retrieve(paymentIntentId);

    if (paymentIntent.status === 'succeeded') {
      purchase.status = PurchaseStatus.COMPLETED;
      purchase.completedAt = new Date();

      // Incrementar contador de uso del cupón si se usó
      if (purchase.discountCode) {
        await this.couponRepository.increment({ code: purchase.discountCode }, 'usageCount', 1);
      }

      await this.purchaseRepository.save(purchase);
    }

    return purchase;
  }

  // ===== COUPON MANAGEMENT =====

  private async validateCoupon(code: string, userId: string): Promise<Coupon | null> {
    const coupon = await this.couponRepository.findOne({ where: { code } });

    if (!coupon || !coupon.isValid) {
      return null;
    }

    // Verificar límite por usuario
    if (coupon.usageLimitPerUser) {
      const userUsageCount = await this.purchaseRepository.count({
        where: { userId, discountCode: code, status: PurchaseStatus.COMPLETED },
      });

      if (userUsageCount >= coupon.usageLimitPerUser) {
        return null;
      }
    }

    // Verificar si es solo para primera compra
    if (coupon.isFirstTimeOnly) {
      const hasAnyPurchase = await this.purchaseRepository.findOne({
        where: { userId, status: PurchaseStatus.COMPLETED },
      });

      if (hasAnyPurchase) {
        return null;
      }
    }

    return coupon;
  }

  // ===== WEBHOOK HANDLING =====

  async handleWebhook(signature: string, body: Buffer): Promise<void> {
    let event: Stripe.Event;

    try {
      event = this.stripe.webhooks.constructEvent(
        body,
        signature,
        this.configService.get<string>('STRIPE_WEBHOOK_SECRET')!
      );
    } catch (error) {
      this.logger.error(`Webhook signature verification failed: ${error.message}`);
      throw new BadRequestException('Invalid signature');
    }

    this.logger.log(`Processing webhook event: ${event.type}`);

    switch (event.type) {
      case 'invoice.payment_succeeded':
        await this.handleInvoicePaymentSucceeded(event.data.object as Stripe.Invoice);
        break;

      case 'invoice.payment_failed':
        await this.handleInvoicePaymentFailed(event.data.object as Stripe.Invoice);
        break;

      case 'customer.subscription.updated':
        await this.handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
        break;

      case 'customer.subscription.deleted':
        await this.handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
        break;

      case 'payment_intent.succeeded':
        await this.handlePaymentIntentSucceeded(event.data.object as Stripe.PaymentIntent);
        break;

      default:
        this.logger.log(`Unhandled webhook event type: ${event.type}`);
    }
  }

  private async handleInvoicePaymentSucceeded(invoice: Stripe.Invoice): Promise<void> {
    if (invoice.subscription) {
      const subscription = await this.subscriptionRepository.findOne({
        where: { stripeSubscriptionId: invoice.subscription as string },
      });

      if (subscription) {
        subscription.status = SubscriptionStatus.ACTIVE;
        await this.subscriptionRepository.save(subscription);
      }
    }
  }

  private async handleInvoicePaymentFailed(invoice: Stripe.Invoice): Promise<void> {
    if (invoice.subscription) {
      const subscription = await this.subscriptionRepository.findOne({
        where: { stripeSubscriptionId: invoice.subscription as string },
      });

      if (subscription) {
        subscription.status = SubscriptionStatus.PAST_DUE;
        await this.subscriptionRepository.save(subscription);
      }
    }
  }

  private async handleSubscriptionUpdated(stripeSubscription: Stripe.Subscription): Promise<void> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { stripeSubscriptionId: stripeSubscription.id },
    });

    if (subscription) {
      await this.updateSubscriptionFromStripe(subscription, stripeSubscription);
    }
  }

  private async handleSubscriptionDeleted(stripeSubscription: Stripe.Subscription): Promise<void> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { stripeSubscriptionId: stripeSubscription.id },
    });

    if (subscription) {
      subscription.status = SubscriptionStatus.CANCELED;
      subscription.canceledAt = new Date();
      await this.subscriptionRepository.save(subscription);
    }
  }

  private async handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent): Promise<void> {
    // Intentar confirmar compra primero
    try {
      await this.confirmPurchase(paymentIntent.id);
    } catch {
      // Si no es una compra, podría ser una orden
      this.logger.warn(
        `Purchase not found for payment intent ${paymentIntent.id}, checking for order`
      );
    }

    // Intentar confirmar orden (esto requerirá inyectar OrdersService)
    // Por ahora solo loggeamos que se completó el pago
    this.logger.log(`Payment intent succeeded: ${paymentIntent.id}`);
  }

  // ===== HELPER METHODS =====

  private async createSubscriptionRecord(
    userId: string,
    stripeSubscription: Stripe.Subscription
  ): Promise<Subscription> {
    const subscription = this.subscriptionRepository.create({
      userId,
      stripeSubscriptionId: stripeSubscription.id,
      stripeCustomerId: stripeSubscription.customer as string,
      stripePriceId: stripeSubscription.items.data[0].price.id,
      status: this.mapStripeSubscriptionStatus(stripeSubscription.status),
      amount: stripeSubscription.items.data[0].price.unit_amount! / 100,
      currency: stripeSubscription.items.data[0].price.currency,
      interval: stripeSubscription.items.data[0].price.recurring?.interval || 'month',
      currentPeriodStart: new Date(stripeSubscription.current_period_start * 1000),
      currentPeriodEnd: new Date(stripeSubscription.current_period_end * 1000),
      trialStart: stripeSubscription.trial_start
        ? new Date(stripeSubscription.trial_start * 1000)
        : null,
      trialEnd: stripeSubscription.trial_end ? new Date(stripeSubscription.trial_end * 1000) : null,
    });

    return this.subscriptionRepository.save(subscription);
  }

  private async updateSubscriptionFromStripe(
    subscription: Subscription,
    stripeSubscription: Stripe.Subscription
  ): Promise<void> {
    subscription.status = this.mapStripeSubscriptionStatus(stripeSubscription.status);
    subscription.currentPeriodStart = new Date(stripeSubscription.current_period_start * 1000);
    subscription.currentPeriodEnd = new Date(stripeSubscription.current_period_end * 1000);

    if (stripeSubscription.canceled_at) {
      subscription.canceledAt = new Date(stripeSubscription.canceled_at * 1000);
    }

    await this.subscriptionRepository.save(subscription);
  }

  private mapStripeSubscriptionStatus(
    stripeStatus: Stripe.Subscription.Status
  ): SubscriptionStatus {
    const statusMap: Record<Stripe.Subscription.Status, SubscriptionStatus> = {
      active: SubscriptionStatus.ACTIVE,
      canceled: SubscriptionStatus.CANCELED,
      past_due: SubscriptionStatus.PAST_DUE,
      unpaid: SubscriptionStatus.UNPAID,
      incomplete: SubscriptionStatus.INCOMPLETE,
      incomplete_expired: SubscriptionStatus.INCOMPLETE_EXPIRED,
      trialing: SubscriptionStatus.TRIALING,
      paused: SubscriptionStatus.CANCELED, // Mapear paused a CANCELED por simplicidad
    };

    return statusMap[stripeStatus] || SubscriptionStatus.INCOMPLETE;
  }

  // ===== PRODUCT MANAGEMENT =====

  async createProduct(productData: {
    name: string;
    description?: string;
    images?: string[];
    metadata?: Record<string, any>;
    active?: boolean;
  }): Promise<Stripe.Product> {
    try {
      const product = await this.stripe.products.create({
        name: productData.name,
        description: productData.description,
        images: productData.images,
        metadata: productData.metadata,
        active: productData.active ?? true,
      });

      this.logger.log(`Product created: ${product.id}`);
      return product;
    } catch (error) {
      this.logger.error(`Failed to create product: ${error.message}`);
      throw new BadRequestException(`Error creating product: ${error.message}`);
    }
  }

  async listProducts(limit = 100, startingAfter?: string): Promise<{
    data: Stripe.Product[];
    hasMore: boolean;
  }> {
    try {
      const products = await this.stripe.products.list({
        limit,
        starting_after: startingAfter,
        active: true,
      });

      return {
        data: products.data,
        hasMore: products.has_more,
      };
    } catch (error) {
      this.logger.error(`Failed to list products: ${error.message}`);
      throw new BadRequestException(`Error listing products: ${error.message}`);
    }
  }

  async getProduct(productId: string): Promise<Stripe.Product> {
    try {
      const product = await this.stripe.products.retrieve(productId);
      return product as Stripe.Product;
    } catch (error) {
      this.logger.error(`Failed to get product ${productId}: ${error.message}`);
      throw new BadRequestException(`Product not found: ${productId}`);
    }
  }

  async updateProduct(
    productId: string,
    updateData: {
      name?: string;
      description?: string;
      images?: string[];
      metadata?: Record<string, any>;
      active?: boolean;
    }
  ): Promise<Stripe.Product> {
    try {
      const product = await this.stripe.products.update(productId, updateData);
      this.logger.log(`Product updated: ${productId}`);
      return product;
    } catch (error) {
      this.logger.error(`Failed to update product ${productId}: ${error.message}`);
      throw new BadRequestException(`Error updating product: ${error.message}`);
    }
  }

  async deleteProduct(productId: string): Promise<void> {
    try {
      await this.stripe.products.del(productId);
      this.logger.log(`Product deleted: ${productId}`);
    } catch (error) {
      this.logger.error(`Failed to delete product ${productId}: ${error.message}`);
      throw new BadRequestException(`Error deleting product: ${error.message}`);
    }
  }

  // ===== PRICE MANAGEMENT =====

  async createPrice(
    productId: string,
    priceData: {
      unitAmount: number;
      currency?: string;
      recurring?: {
        interval: 'day' | 'week' | 'month' | 'year';
        intervalCount?: number;
      };
      nickname?: string;
      metadata?: Record<string, any>;
      active?: boolean;
    }
  ): Promise<Stripe.Price> {
    try {
      const price = await this.stripe.prices.create({
        product: productId,
        unit_amount: priceData.unitAmount,
        currency: priceData.currency || 'usd',
        recurring: priceData.recurring,
        nickname: priceData.nickname,
        metadata: priceData.metadata,
        active: priceData.active ?? true,
      });

      this.logger.log(`Price created: ${price.id} for product: ${productId}`);
      return price;
    } catch (error) {
      this.logger.error(`Failed to create price for product ${productId}: ${error.message}`);
      throw new BadRequestException(`Error creating price: ${error.message}`);
    }
  }

  async listPrices(productId: string, limit = 100): Promise<Stripe.Price[]> {
    try {
      const prices = await this.stripe.prices.list({
        product: productId,
        limit,
        active: true,
      });

      return prices.data;
    } catch (error) {
      this.logger.error(`Failed to list prices for product ${productId}: ${error.message}`);
      throw new BadRequestException(`Error listing prices: ${error.message}`);
    }
  }

  async getPrice(priceId: string): Promise<Stripe.Price> {
    try {
      const price = await this.stripe.prices.retrieve(priceId);
      return price;
    } catch (error) {
      this.logger.error(`Failed to get price ${priceId}: ${error.message}`);
      throw new BadRequestException(`Price not found: ${priceId}`);
    }
  }

  async updatePrice(
    priceId: string,
    updateData: {
      nickname?: string;
      metadata?: Record<string, any>;
      active?: boolean;
    }
  ): Promise<Stripe.Price> {
    try {
      const price = await this.stripe.prices.update(priceId, updateData);
      this.logger.log(`Price updated: ${priceId}`);
      return price;
    } catch (error) {
      this.logger.error(`Failed to update price ${priceId}: ${error.message}`);
      throw new BadRequestException(`Error updating price: ${error.message}`);
    }
  }
}
