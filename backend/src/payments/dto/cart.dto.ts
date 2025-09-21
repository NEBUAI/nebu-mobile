import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsPositive, IsNumber } from 'class-validator';

export class AddToCartDto {
  @ApiProperty({ description: 'ID del curso a agregar al carrito' })
  @IsString()
  courseId: string;
}

export class UpdateCartItemDto {
  @ApiProperty({ description: 'Nueva cantidad del item' })
  @IsNumber()
  @IsPositive()
  quantity: number;
}

export class CartItemDto {
  @ApiProperty()
  id: number;

  @ApiProperty()
  courseId: string;

  @ApiProperty()
  courseName: string;

  @ApiProperty()
  price: number;

  @ApiProperty()
  quantity: number;

  @ApiProperty()
  subtotal: number;
}

export class CartDto {
  @ApiProperty({ type: [CartItemDto] })
  items: CartItemDto[];

  @ApiProperty()
  total: number;

  @ApiProperty()
  itemCount: number;
}
