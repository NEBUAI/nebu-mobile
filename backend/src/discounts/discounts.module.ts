import { Module } from '@nestjs/common';
import { DiscountsController } from './controllers/discounts.controller';
import { DiscountsService } from './services/discounts.service';

@Module({
  controllers: [DiscountsController],
  providers: [DiscountsService],
  exports: [DiscountsService],
})
export class DiscountsModule {}
