import { Controller, Post, Body } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { DiscountsService } from '../services/discounts.service';

@ApiTags('discounts')
@Controller('discounts')
export class DiscountsController {
  constructor(private readonly discountsService: DiscountsService) {}

  @Post('validate')
  @ApiOperation({ summary: 'Validar código de descuento' })
  @ApiResponse({
    status: 200,
    description: 'Código de descuento validado exitosamente',
    schema: {
      type: 'object',
      properties: {
        valid: { type: 'boolean' },
        discount: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            code: { type: 'string' },
            type: { type: 'string', enum: ['percentage', 'fixed'] },
            value: { type: 'number' },
            description: { type: 'string' },
            minAmount: { type: 'number' },
            maxAmount: { type: 'number' },
            expiresAt: { type: 'string', format: 'date-time' },
            usageLimit: { type: 'number' },
            usedCount: { type: 'number' },
            isActive: { type: 'boolean' },
          },
        },
        discountAmount: { type: 'number' },
      },
    },
  })
  async validateDiscount(@Body() body: { code: string; cartTotal: number }) {
    return this.discountsService.validateDiscount(body.code, body.cartTotal);
  }
}
