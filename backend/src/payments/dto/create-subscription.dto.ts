import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateSubscriptionDto {
  @ApiProperty({
    description: 'ID del precio de Stripe para la suscripción',
    example: 'price_1234567890',
  })
  @IsString()
  @IsNotEmpty()
  priceId: string;

  @ApiPropertyOptional({
    description: 'ID del método de pago de Stripe',
    example: 'pm_1234567890',
  })
  @IsString()
  @IsOptional()
  paymentMethodId?: string;

  @ApiPropertyOptional({
    description: 'Código de cupón de descuento',
    example: 'ANNUAL20',
  })
  @IsString()
  @IsOptional()
  couponCode?: string;
}
