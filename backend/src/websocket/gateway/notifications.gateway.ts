import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { getCorsOrigins } from '../../config/cors.config';

@WebSocketGateway({
  cors: {
    origin: getCorsOrigins(),
    credentials: true,
  },
  namespace: '/notifications',
})
export class NotificationsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(NotificationsGateway.name);
  private connectedUsers = new Map<string, string>(); // userId -> socketId

  constructor(
    private jwtService: JwtService,
    private notificationsService: NotificationsService
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token =
        client.handshake.auth.token ||
        client.handshake.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        client.disconnect();
        return;
      }

      const payload = this.jwtService.verify(token);
      const userId = payload.sub;

      if (!userId) {
        client.disconnect();
        return;
      }

      // Store user connection
      this.connectedUsers.set(userId, client.id);
      client.data.userId = userId;

      // Join user to their personal room
      client.join(`user:${userId}`);

      this.logger.log(`User ${userId} connected to notifications`);

      // Send unread notifications count
      const stats = await this.notificationsService.getStats(userId);
      client.emit('unread_count', { count: stats.unread });
    } catch (error) {
      this.logger.error('Connection error:', error);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const userId = client.data.userId;

    if (userId) {
      this.connectedUsers.delete(userId);
      this.logger.log(`User ${userId} disconnected from notifications`);
    }
  }

  @SubscribeMessage('mark_as_read')
  async handleMarkAsRead(
    @MessageBody() data: { notificationId: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;
      const notification = await this.notificationsService.markAsRead(data.notificationId, userId);

      // Update unread count
      const stats = await this.notificationsService.getStats(userId);
      client.emit('unread_count', { count: stats.unread });

      return { success: true, notification };
    } catch (error) {
      this.logger.error('Error marking notification as read:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('mark_all_read')
  async handleMarkAllAsRead(@ConnectedSocket() client: Socket) {
    try {
      const userId = client.data.userId;
      await this.notificationsService.markAllAsRead(userId);

      // Update unread count
      const stats = await this.notificationsService.getStats(userId);
      client.emit('unread_count', { count: stats.unread });

      return { success: true };
    } catch (error) {
      this.logger.error('Error marking all notifications as read:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('get_notifications')
  async handleGetNotifications(
    @MessageBody() data: { limit?: number; offset?: number },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;
      const notifications = await this.notificationsService.findByUser(
        userId,
        data.limit || 20,
        data.offset || 0
      );

      return { success: true, notifications };
    } catch (error) {
      this.logger.error('Error getting notifications:', error);
      return { success: false, error: error.message };
    }
  }

  // Method to send notification to specific user
  async sendNotificationToUser(userId: string, notification: any) {
    const socketId = this.connectedUsers.get(userId);

    if (socketId) {
      this.server.to(socketId).emit('new_notification', notification);

      // Update unread count
      const stats = await this.notificationsService.getStats(userId);
      this.server.to(socketId).emit('unread_count', { count: stats.unread });
    }
  }

  // Method to send notification to multiple users
  async sendNotificationToUsers(userIds: string[], notification: any) {
    for (const userId of userIds) {
      await this.sendNotificationToUser(userId, notification);
    }
  }

  // Method to broadcast to all connected users
  async broadcastNotification(notification: any) {
    this.server.emit('broadcast_notification', notification);
  }
}
