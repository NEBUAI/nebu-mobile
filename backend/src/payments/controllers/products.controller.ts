import {
  Controller,
  Post,
  Get,
  Put,
  Delete,
  Body,
  Param,
  UseGuards,
  HttpCode,
  HttpStatus,
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
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../users/entities/user.entity';
import { StripeService } from '../services/stripe.service';

@ApiTags('Products')
@Controller('products')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class ProductsController {
  constructor(private readonly stripeService: StripeService) {}

  // ===== PRODUCT MANAGEMENT =====

  @Post()
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Crear producto en Stripe' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        name: { type: 'string', description: 'Nombre del producto' },
        description: { type: 'string', description: 'Descripción del producto' },
        images: { 
          type: 'array', 
          items: { type: 'string' },
          description: 'URLs de imágenes del producto'
        },
        metadata: { 
          type: 'object',
          description: 'Metadatos adicionales'
        },
        active: { type: 'boolean', default: true },
      },
      required: ['name'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Producto creado exitosamente',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        name: { type: 'string' },
        description: { type: 'string' },
        active: { type: 'boolean' },
        created: { type: 'number' },
        images: { type: 'array', items: { type: 'string' } },
        metadata: { type: 'object' },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  async createProduct(@Body() createProductDto: {
    name: string;
    description?: string;
    images?: string[];
    metadata?: Record<string, any>;
    active?: boolean;
  }) {
    return await this.stripeService.createProduct(createProductDto);
  }

  @Get()
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Listar productos de Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Lista de productos obtenida exitosamente',
    schema: {
      type: 'object',
      properties: {
        data: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'string' },
              name: { type: 'string' },
              description: { type: 'string' },
              active: { type: 'boolean' },
              created: { type: 'number' },
              images: { type: 'array', items: { type: 'string' } },
              metadata: { type: 'object' },
            },
          },
        },
        hasMore: { type: 'boolean' },
      },
    },
  })
  async listProducts() {
    return await this.stripeService.listProducts();
  }

  @Get(':id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Obtener producto por ID' })
  @ApiParam({ name: 'id', description: 'ID del producto en Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Producto obtenido exitosamente',
  })
  @ApiResponse({ status: 404, description: 'Producto no encontrado' })
  async getProduct(@Param('id') id: string) {
    return await this.stripeService.getProduct(id);
  }

  @Put(':id')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar producto' })
  @ApiParam({ name: 'id', description: 'ID del producto en Stripe' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        name: { type: 'string' },
        description: { type: 'string' },
        images: { type: 'array', items: { type: 'string' } },
        metadata: { type: 'object' },
        active: { type: 'boolean' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Producto actualizado exitosamente',
  })
  @ApiResponse({ status: 404, description: 'Producto no encontrado' })
  async updateProduct(
    @Param('id') id: string,
    @Body() updateProductDto: {
      name?: string;
      description?: string;
      images?: string[];
      metadata?: Record<string, any>;
      active?: boolean;
    }
  ) {
    return await this.stripeService.updateProduct(id, updateProductDto);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Eliminar producto' })
  @ApiParam({ name: 'id', description: 'ID del producto en Stripe' })
  @ApiResponse({
    status: 204,
    description: 'Producto eliminado exitosamente',
  })
  @ApiResponse({ status: 404, description: 'Producto no encontrado' })
  async deleteProduct(@Param('id') id: string) {
    await this.stripeService.deleteProduct(id);
  }

  // ===== PRICE MANAGEMENT =====

  @Post(':productId/prices')
  @Roles(UserRole.ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Crear precio para un producto' })
  @ApiParam({ name: 'productId', description: 'ID del producto en Stripe' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        unitAmount: { 
          type: 'number', 
          description: 'Precio en centavos (ej: 1000 = $10.00)' 
        },
        currency: { 
          type: 'string', 
          default: 'usd',
          description: 'Moneda del precio'
        },
        recurring: {
          type: 'object',
          properties: {
            interval: { 
              type: 'string', 
              enum: ['day', 'week', 'month', 'year'],
              description: 'Intervalo de facturación'
            },
            intervalCount: { 
              type: 'number', 
              default: 1,
              description: 'Cantidad de intervalos'
            },
          },
        },
        nickname: { type: 'string', description: 'Nombre del precio' },
        metadata: { type: 'object' },
        active: { type: 'boolean', default: true },
      },
      required: ['unitAmount'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Precio creado exitosamente',
    schema: {
      type: 'object',
      properties: {
        id: { type: 'string' },
        product: { type: 'string' },
        unitAmount: { type: 'number' },
        currency: { type: 'string' },
        recurring: { type: 'object' },
        nickname: { type: 'string' },
        active: { type: 'boolean' },
        created: { type: 'number' },
      },
    },
  })
  async createPrice(
    @Param('productId') productId: string,
    @Body() createPriceDto: {
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
  ) {
    return await this.stripeService.createPrice(productId, createPriceDto);
  }

  @Get(':productId/prices')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Listar precios de un producto' })
  @ApiParam({ name: 'productId', description: 'ID del producto en Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Lista de precios obtenida exitosamente',
  })
  async listPrices(@Param('productId') productId: string) {
    return await this.stripeService.listPrices(productId);
  }

  @Get('prices/:priceId')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Obtener precio por ID' })
  @ApiParam({ name: 'priceId', description: 'ID del precio en Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Precio obtenido exitosamente',
  })
  @ApiResponse({ status: 404, description: 'Precio no encontrado' })
  async getPrice(@Param('priceId') priceId: string) {
    return await this.stripeService.getPrice(priceId);
  }

  @Put('prices/:priceId')
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Actualizar precio' })
  @ApiParam({ name: 'priceId', description: 'ID del precio en Stripe' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        nickname: { type: 'string' },
        metadata: { type: 'object' },
        active: { type: 'boolean' },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Precio actualizado exitosamente',
  })
  @ApiResponse({ status: 404, description: 'Precio no encontrado' })
  async updatePrice(
    @Param('priceId') priceId: string,
    @Body() updatePriceDto: {
      nickname?: string;
      metadata?: Record<string, any>;
      active?: boolean;
    }
  ) {
    return await this.stripeService.updatePrice(priceId, updatePriceDto);
  }
}
