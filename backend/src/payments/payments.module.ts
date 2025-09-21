import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';

// Entities
import { Subscription } from './entities/subscription.entity';
import { Purchase } from './entities/purchase.entity';
import { SubscriptionPlan } from './entities/subscription-plan.entity';
import { Coupon } from './entities/coupon.entity';
import { CartItem } from './entities/cart-item.entity';
import { Order } from './entities/order.entity';
import { User } from '../users/entities/user.entity';
import { Course } from '../courses/entities/course.entity';

// Services
import { StripeService } from './services/stripe.service';
import { AccessService } from './services/access.service';
import { CartService } from './services/cart.service';
import { OrdersService } from './services/orders.service';

// Controllers
import { PaymentsController } from './controllers/payments.controller';
import { CartController } from './controllers/cart.controller';
import { OrdersController } from './controllers/orders.controller';
import { ProductsController } from './controllers/products.controller';

// Config
import { FeaturesConfig } from '../config/features.config';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Subscription,
      Purchase,
      SubscriptionPlan,
      Coupon,
      CartItem,
      Order,
      User,
      Course,
    ]),
    ConfigModule,
  ],
  controllers: [PaymentsController, CartController, OrdersController, ProductsController],
  providers: [StripeService, AccessService, CartService, OrdersService, FeaturesConfig],
  exports: [StripeService, AccessService, CartService, OrdersService, FeaturesConfig, TypeOrmModule],
})
export class PaymentsModule {}
