import { WebSocketGateway, WebSocketServer, SubscribeMessage, MessageBody, ConnectedSocket } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { getCorsOrigins } from '../../config/cors.config';

@WebSocketGateway({
  cors: {
    origin: getCorsOrigins(),
    credentials: true,
  },
  namespace: '/analytics',
})
export class AnalyticsGateway {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(AnalyticsGateway.name);

  constructor(private jwtService: JwtService) {}

  @SubscribeMessage('track_event')
  handleTrackEvent(
    @MessageBody() data: any,
    @ConnectedSocket() client: Socket,
  ) {
    this.logger.log('Analytics tracking - disabled (no analytics module)');
    // Analytics tracking disabled
  }

  @SubscribeMessage('get_analytics')
  handleGetAnalytics(
    @MessageBody() data: any,
    @ConnectedSocket() client: Socket,
  ) {
    this.logger.log('Get analytics - disabled (no analytics module)');
    // Analytics tracking disabled
    client.emit('analytics_data', { events: [] });
  }
}