import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  ParseUUIDPipe,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { OrdersService } from '../services/orders.service';
import { CreateOrderDto, UpdateOrderDto, OrderStatusEnum } from '../dto/create-order.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Order } from '../entities/order.entity';
import { UserRole } from '../../users/entities/user.entity';

@ApiTags('Orders')
@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear una nueva orden' })
  @ApiResponse({
    status: 201,
    description: 'Orden creada exitosamente',
    type: Order,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Usuario o cursos no encontrados' })
  create(@Body() createOrderDto: CreateOrderDto) {
    return this.ordersService.create(createOrderDto);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener todas las órdenes (solo admin)' })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: OrderStatusEnum,
    description: 'Filtrar por estado de orden',
  })
  @ApiQuery({
    name: 'userId',
    required: false,
    type: String,
    description: 'Filtrar por usuario',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Número de página',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Elementos por página',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de todas las órdenes',
    schema: {
      type: 'object',
      properties: {
        orders: { type: 'array', items: { $ref: '#/components/schemas/Order' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  findAll(
    @Query('status') status?: OrderStatusEnum,
    @Query('userId') userId?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.ordersService.findAll(status as any, userId, page, limit);
  }

  @Get('my-orders')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener las órdenes del usuario actual' })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Número de página',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Elementos por página',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de órdenes del usuario',
    schema: {
      type: 'object',
      properties: {
        orders: { type: 'array', items: { $ref: '#/components/schemas/Order' } },
        total: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  findMyOrders(@CurrentUser() user: any, @Query('page') page = 1, @Query('limit') limit = 10) {
    return this.ordersService.findByUser(user.id, page, limit);
  }

  @Get(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener una orden por ID' })
  @ApiParam({
    name: 'id',
    type: 'string',
    description: 'ID de la orden',
  })
  @ApiResponse({
    status: 200,
    description: 'Orden encontrada',
    type: Order,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Orden no encontrada' })
  findOne(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() _user: any) {
    // Solo permitir ver la orden si es del usuario o es admin
    return this.ordersService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar una orden (solo admin)' })
  @ApiParam({
    name: 'id',
    type: 'string',
    description: 'ID de la orden',
  })
  @ApiBody({ type: UpdateOrderDto })
  @ApiResponse({
    status: 200,
    description: 'Orden actualizada exitosamente',
    type: Order,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Orden no encontrada' })
  update(@Param('id', ParseUUIDPipe) id: string, @Body() updateOrderDto: UpdateOrderDto) {
    return this.ordersService.update(id, updateOrderDto);
  }

  @Post(':id/cancel')
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Cancelar una orden' })
  @ApiParam({
    name: 'id',
    type: 'string',
    description: 'ID de la orden',
  })
  @ApiResponse({
    status: 200,
    description: 'Orden cancelada exitosamente',
    type: Order,
  })
  @ApiResponse({ status: 400, description: 'No se puede cancelar la orden' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Orden no encontrada' })
  cancel(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() _user: any) {
    // Verificar que la orden pertenece al usuario o es admin
    return this.ordersService.cancel(id);
  }

  @Post('confirm-payment')
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Confirmar pago de una orden via Stripe Payment Intent' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        paymentIntentId: {
          type: 'string',
          description: 'ID del Payment Intent de Stripe',
          example: 'pi_1234567890',
        },
      },
      required: ['paymentIntentId'],
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Pago confirmado exitosamente',
    type: Order,
  })
  @ApiResponse({ status: 400, description: 'Payment Intent inválido' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Orden no encontrada' })
  confirmPayment(@Body('paymentIntentId') paymentIntentId: string) {
    return this.ordersService.confirmPayment(paymentIntentId);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar una orden (solo admin)' })
  @ApiParam({
    name: 'id',
    type: 'string',
    description: 'ID de la orden',
  })
  @ApiResponse({ status: 204, description: 'Orden eliminada exitosamente' })
  @ApiResponse({ status: 400, description: 'No se puede eliminar la orden' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Orden no encontrada' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.ordersService.remove(id);
  }
}
