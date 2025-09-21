import { IsNotEmpty, IsString, IsNumber, IsArray, IsOptional, Min, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateOrderDto {
  @ApiProperty({
    description: 'ID del usuario que realiza la orden',
    example: 'uuid-string',
  })
  @IsNotEmpty()
  @IsString()
  userId: string;

  @ApiProperty({
    description: 'IDs de los cursos a comprar',
    example: ['course-uuid-1', 'course-uuid-2'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  courseIds: string[];

  @ApiProperty({
    description: 'Código de descuento (opcional)',
    example: 'DESCUENTO20',
    required: false,
  })
  @IsOptional()
  @IsString()
  discountCode?: string;

  @ApiProperty({
    description: 'Monto total de la orden (en centavos)',
    example: 9999,
  })
  @IsNumber()
  @Min(0)
  totalAmount: number;

  @ApiProperty({
    description: 'Moneda de la transacción',
    example: 'usd',
    default: 'usd',
  })
  @IsOptional()
  @IsString()
  currency?: string = 'usd';
}

export enum OrderStatusEnum {
  PENDING = 'pending',
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
}

export class UpdateOrderDto {
  @ApiProperty({
    description: 'Estado de la orden',
    example: 'completed',
    enum: OrderStatusEnum,
  })
  @IsOptional()
  @IsEnum(OrderStatusEnum)
  status?: OrderStatusEnum;

  @ApiProperty({
    description: 'ID de transacción de Stripe',
    example: 'pi_1234567890',
    required: false,
  })
  @IsOptional()
  @IsString()
  stripePaymentIntentId?: string;
}
