import {
  Controller,
  Post,
  Get,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
  RawBody,
  Headers,
  ParseUUIDPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { StripeService } from '../services/stripe.service';
import { AccessService } from '../services/access.service';
import { CreatePurchaseDto } from '../dto/create-purchase.dto';
import { CreateSubscriptionDto } from '../dto/create-subscription.dto';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  constructor(
    private readonly stripeService: StripeService,
    private readonly accessService: AccessService
  ) {}

  // ===== COURSE PURCHASES =====

  @Post('purchase/create-intent')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear intención de compra para un curso' })
  @ApiBody({ type: CreatePurchaseDto })
  @ApiResponse({
    status: 201,
    description: 'Intención de compra creada exitosamente',
    schema: {
      type: 'object',
      properties: {
        purchase: { type: 'object' },
        clientSecret: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Ya tienes acceso a este curso o datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async createPurchaseIntent(
    @Body() createPurchaseDto: CreatePurchaseDto,
    @CurrentUser() user: any
  ) {
    return this.stripeService.createPurchaseIntent(
      user.id,
      createPurchaseDto.courseId,
      createPurchaseDto.couponCode
    );
  }

  @Post('purchase/confirm/:paymentIntentId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Confirmar compra después del pago' })
  @ApiParam({
    name: 'paymentIntentId',
    description: 'ID del Payment Intent de Stripe',
  })
  @ApiResponse({
    status: 200,
    description: 'Compra confirmada exitosamente',
  })
  @ApiResponse({ status: 400, description: 'Payment Intent no encontrado o inválido' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async confirmPurchase(@Param('paymentIntentId') paymentIntentId: string) {
    return this.stripeService.confirmPurchase(paymentIntentId);
  }

  // ===== SUBSCRIPTIONS =====

  @Post('subscription/create')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear nueva suscripción' })
  @ApiBody({ type: CreateSubscriptionDto })
  @ApiResponse({
    status: 201,
    description: 'Suscripción creada exitosamente',
    schema: {
      type: 'object',
      properties: {
        subscription: { type: 'object' },
        clientSecret: { type: 'string' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async createSubscription(
    @Body() createSubscriptionDto: CreateSubscriptionDto,
    @CurrentUser() user: any
  ) {
    return this.stripeService.createSubscription(
      user.id,
      createSubscriptionDto.priceId,
      createSubscriptionDto.paymentMethodId,
      createSubscriptionDto.couponCode
    );
  }

  @Post('subscription/:subscriptionId/cancel')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Cancelar suscripción' })
  @ApiParam({
    name: 'subscriptionId',
    description: 'ID de la suscripción',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        immediately: {
          type: 'boolean',
          description: 'Cancelar inmediatamente o al final del período',
          default: false,
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Suscripción cancelada exitosamente',
  })
  @ApiResponse({ status: 400, description: 'Suscripción no encontrada' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async cancelSubscription(
    @Param('subscriptionId', ParseUUIDPipe) subscriptionId: string,
    @Body('immediately') immediately = false
  ) {
    return this.stripeService.cancelSubscription(subscriptionId, immediately);
  }

  // ===== ACCESS MANAGEMENT =====

  @Get('access/course/:courseId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Verificar acceso a un curso específico' })
  @ApiParam({
    name: 'courseId',
    description: 'ID del curso',
  })
  @ApiResponse({
    status: 200,
    description: 'Información de acceso al curso',
    schema: {
      type: 'object',
      properties: {
        hasAccess: { type: 'boolean' },
        accessType: { type: 'string', enum: ['subscription', 'purchase', 'none'] },
        subscription: { type: 'object', nullable: true },
        purchase: { type: 'object', nullable: true },
        expiresAt: { type: 'string', format: 'date-time', nullable: true },
        daysRemaining: { type: 'number', nullable: true },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async checkCourseAccess(
    @Param('courseId', ParseUUIDPipe) courseId: string,
    @CurrentUser() user: any
  ) {
    return this.accessService.checkCourseAccess(user.id, courseId);
  }

  @Get('access/summary')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener resumen de acceso del usuario' })
  @ApiResponse({
    status: 200,
    description: 'Resumen de acceso del usuario',
    schema: {
      type: 'object',
      properties: {
        hasActiveSubscription: { type: 'boolean' },
        subscription: { type: 'object', nullable: true },
        totalPurchases: { type: 'number' },
        accessibleCourses: { type: 'array', items: { type: 'string' } },
        subscriptionDaysRemaining: { type: 'number', nullable: true },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async getAccessSummary(@CurrentUser() user: any) {
    return this.accessService.getUserAccessSummary(user.id);
  }

  // ===== STRIPE WEBHOOKS =====

  @Post('webhooks/stripe')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Webhook de Stripe para eventos de pago' })
  @ApiResponse({ status: 200, description: 'Webhook procesado exitosamente' })
  @ApiResponse({ status: 400, description: 'Firma inválida' })
  async handleStripeWebhook(
    @RawBody() body: Buffer,
    @Headers('stripe-signature') signature: string
  ) {
    await this.stripeService.handleWebhook(signature, body);
    return { received: true };
  }

  // ===== ADMIN ENDPOINTS =====

  @Get('stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener estadísticas de pagos (solo admin)' })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de pagos',
    schema: {
      type: 'object',
      properties: {
        totalActiveSubscriptions: { type: 'number' },
        totalPurchases: { type: 'number' },
        totalRevenue: { type: 'number' },
        subscriptionRevenue: { type: 'number' },
        purchaseRevenue: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  async getPaymentStats() {
    return this.accessService.getAccessStats();
  }
}
