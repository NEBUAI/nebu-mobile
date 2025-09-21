import { Injectable } from '@nestjs/common';

@Injectable()
export class DiscountsService {
  async validateDiscount(code: string, cartTotal: number) {
    // Mock implementation - replace with real database logic
    const mockDiscounts = [
      {
        id: '1',
        code: 'WELCOME10',
        type: 'percentage' as const,
        value: 10,
        description: '10% de descuento para nuevos usuarios',
        minAmount: 50,
        maxAmount: 100,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
        usageLimit: 100,
        usedCount: 25,
        isActive: true,
      },
      {
        id: '2',
        code: 'SAVE20',
        type: 'fixed' as const,
        value: 20,
        description: '$20 de descuento',
        minAmount: 100,
        maxAmount: 50,
        expiresAt: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000), // 15 days
        usageLimit: 50,
        usedCount: 10,
        isActive: true,
      },
    ];

    const discount = mockDiscounts.find(d => d.code === code && d.isActive);

    if (!discount) {
      return {
        valid: false,
        discount: null,
        discountAmount: 0,
      };
    }

    // Check if discount has expired
    if (discount.expiresAt && new Date() > discount.expiresAt) {
      return {
        valid: false,
        discount: null,
        discountAmount: 0,
      };
    }

    // Check minimum amount requirement
    if (discount.minAmount && cartTotal < discount.minAmount) {
      return {
        valid: false,
        discount: null,
        discountAmount: 0,
      };
    }

    // Check usage limit
    if (discount.usageLimit && discount.usedCount >= discount.usageLimit) {
      return {
        valid: false,
        discount: null,
        discountAmount: 0,
      };
    }

    // Calculate discount amount
    let discountAmount = 0;
    if (discount.type === 'percentage') {
      discountAmount = (cartTotal * discount.value) / 100;
    } else if (discount.type === 'fixed') {
      discountAmount = discount.value;
    }

    // Apply maximum discount limit
    if (discount.maxAmount && discountAmount > discount.maxAmount) {
      discountAmount = discount.maxAmount;
    }

    // Don't exceed the cart total
    if (discountAmount > cartTotal) {
      discountAmount = cartTotal;
    }

    return {
      valid: true,
      discount,
      discountAmount: Math.round(discountAmount * 100) / 100,
    };
  }
}
