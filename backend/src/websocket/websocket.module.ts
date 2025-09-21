import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule } from '@nestjs/config';
import { NotificationsModule } from '../notifications/notifications.module';
import { AnalyticsModule } from '../analytics/analytics.module';
import { ProgressModule } from '../progress/progress.module';
import { NotificationsGateway } from './gateway/notifications.gateway';
import { ProgressGateway } from './gateway/progress.gateway';
import { AnalyticsGateway } from './gateway/analytics.gateway';
import { WebSocketService } from './services/websocket.service';
import { FeaturesConfig } from '../config/features.config';

@Module({
  imports: [
    ConfigModule,
    NotificationsModule,
    AnalyticsModule,
    ProgressModule,
    JwtModule.register({
      secret: process.env.JWT_SECRET || 'default-secret',
      signOptions: { expiresIn: '7d' },
    }),
  ],
  providers: [
    FeaturesConfig,
    NotificationsGateway, 
    ProgressGateway, 
    AnalyticsGateway, 
    WebSocketService
  ],
  exports: [WebSocketService, FeaturesConfig],
})
export class WebSocketModule {}
