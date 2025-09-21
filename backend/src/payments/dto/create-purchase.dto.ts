import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreatePurchaseDto {
  @ApiProperty({
    description: 'ID del curso a comprar',
    example: 'uuid-course-id',
  })
  @IsString()
  @IsNotEmpty()
  courseId: string;

  @ApiPropertyOptional({
    description: 'Código de cupón de descuento',
    example: 'SAVE20',
  })
  @IsString()
  @IsOptional()
  couponCode?: string;
}
