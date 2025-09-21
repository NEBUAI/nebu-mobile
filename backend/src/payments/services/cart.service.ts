import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CartItem } from '../entities/cart-item.entity';
import { Course } from '../../courses/entities/course.entity';
import { AddToCartDto, CartDto, CartItemDto } from '../dto/cart.dto';

@Injectable()
export class CartService {
  constructor(
    @InjectRepository(CartItem)
    private readonly cartItemRepository: Repository<CartItem>,
    @InjectRepository(Course)
    private readonly courseRepository: Repository<Course>
  ) {}

  async getCart(userId: string): Promise<CartDto> {
    const cartItems = await this.cartItemRepository.find({
      where: { userId },
      relations: ['course'],
    });

    const items: CartItemDto[] = cartItems.map(item => ({
      id: item.id,
      courseId: item.courseId,
      courseName: item.course.title,
      price: Number(item.price),
      quantity: item.quantity,
      subtotal: Number(item.price) * item.quantity,
    }));

    const total = items.reduce((sum, item) => sum + item.subtotal, 0);
    const itemCount = items.reduce((sum, item) => sum + item.quantity, 0);

    return {
      items,
      total,
      itemCount,
    };
  }

  async addToCart(userId: string, addToCartDto: AddToCartDto): Promise<CartDto> {
    const { courseId } = addToCartDto;

    // Verificar que el curso existe
    const course = await this.courseRepository.findOne({ where: { id: courseId } });
    if (!course) {
      throw new NotFoundException('Curso no encontrado');
    }

    // Verificar si el item ya está en el carrito
    const existingItem = await this.cartItemRepository.findOne({
      where: { userId, courseId },
    });

    if (existingItem) {
      throw new BadRequestException('El curso ya está en el carrito');
    }

    // Crear nuevo item en el carrito
    const cartItem = this.cartItemRepository.create({
      userId,
      courseId,
      price: course.price || 0,
      quantity: 1,
    });

    await this.cartItemRepository.save(cartItem);

    return this.getCart(userId);
  }

  async removeFromCart(userId: string, courseId: string): Promise<CartDto> {
    const cartItem = await this.cartItemRepository.findOne({
      where: { userId, courseId },
    });

    if (!cartItem) {
      throw new NotFoundException('Item no encontrado en el carrito');
    }

    await this.cartItemRepository.remove(cartItem);
    return this.getCart(userId);
  }

  async clearCart(userId: string): Promise<CartDto> {
    await this.cartItemRepository.delete({ userId });
    return this.getCart(userId);
  }

  async updateCartItemQuantity(
    userId: string,
    courseId: string,
    quantity: number
  ): Promise<CartDto> {
    const cartItem = await this.cartItemRepository.findOne({
      where: { userId, courseId },
    });

    if (!cartItem) {
      throw new NotFoundException('Item no encontrado en el carrito');
    }

    cartItem.quantity = quantity;
    await this.cartItemRepository.save(cartItem);

    return this.getCart(userId);
  }
}
