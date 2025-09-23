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
  namespace: '/progress',
})
export class ProgressGateway {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(ProgressGateway.name);

  constructor(private jwtService: JwtService) {}

  @SubscribeMessage('track_progress')
  handleProgressUpdate(
    @MessageBody() data: any,
    @ConnectedSocket() client: Socket,
  ) {
    this.logger.log('Progress tracking - disabled (no progress module)');
    // Progress tracking disabled
  }

  @SubscribeMessage('get_progress')
  handleGetProgress(
    @MessageBody() data: any,
    @ConnectedSocket() client: Socket,
  ) {
    this.logger.log('Get progress - disabled (no progress module)');
    // Progress tracking disabled
    client.emit('progress_data', { progress: [] });
  }
}