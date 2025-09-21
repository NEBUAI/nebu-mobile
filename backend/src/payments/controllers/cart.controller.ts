import { Controller, Post, Get, Delete, Patch, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { CartService } from '../services/cart.service';
import { AddToCartDto, CartDto } from '../dto/cart.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Cart')
@Controller('cart')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class CartController {
  constructor(private readonly cartService: CartService) {}

  @Get()
  @ApiOperation({ summary: 'Obtener carrito del usuario' })
  @ApiResponse({
    status: 200,
    description: 'Carrito obtenido exitosamente',
    type: CartDto,
  })
  async getCart(@Req() req): Promise<CartDto> {
    return this.cartService.getCart(req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Agregar curso al carrito' })
  @ApiResponse({
    status: 201,
    description: 'Curso agregado al carrito exitosamente',
    type: CartDto,
  })
  @ApiResponse({
    status: 400,
    description: 'El curso ya está en el carrito',
  })
  @ApiResponse({
    status: 404,
    description: 'Curso no encontrado',
  })
  async addToCart(@Req() req, @Body() addToCartDto: AddToCartDto): Promise<CartDto> {
    return this.cartService.addToCart(req.user.id, addToCartDto);
  }

  @Delete(':courseId')
  @ApiOperation({ summary: 'Remover curso del carrito' })
  @ApiParam({
    name: 'courseId',
    description: 'ID del curso a remover',
    type: 'string',
  })
  @ApiResponse({
    status: 200,
    description: 'Curso removido del carrito exitosamente',
    type: CartDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Item no encontrado en el carrito',
  })
  async removeFromCart(@Req() req, @Param('courseId') courseId: string): Promise<CartDto> {
    return this.cartService.removeFromCart(req.user.id, courseId);
  }

  @Patch(':courseId/quantity')
  @ApiOperation({ summary: 'Actualizar cantidad de un item en el carrito' })
  @ApiParam({
    name: 'courseId',
    description: 'ID del curso',
    type: 'string',
  })
  @ApiResponse({
    status: 200,
    description: 'Cantidad actualizada exitosamente',
    type: CartDto,
  })
  @ApiResponse({
    status: 404,
    description: 'Item no encontrado en el carrito',
  })
  async updateQuantity(
    @Req() req,
    @Param('courseId') courseId: string,
    @Body('quantity') quantity: number
  ): Promise<CartDto> {
    return this.cartService.updateCartItemQuantity(req.user.id, courseId, quantity);
  }

  @Delete()
  @ApiOperation({ summary: 'Limpiar carrito' })
  @ApiResponse({
    status: 200,
    description: 'Carrito limpiado exitosamente',
    type: CartDto,
  })
  async clearCart(@Req() req): Promise<CartDto> {
    return this.cartService.clearCart(req.user.id);
  }
}
