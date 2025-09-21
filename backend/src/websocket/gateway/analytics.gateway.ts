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
import { AnalyticsService } from '../../analytics/services/analytics.service';
import { getCorsOrigins } from '../../config/cors.config';

@WebSocketGateway({
  cors: {
    origin: getCorsOrigins(),
    credentials: true,
  },
  namespace: '/analytics',
})
export class AnalyticsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(AnalyticsGateway.name);
  private connectedUsers = new Map<string, string>(); // userId -> socketId
  private adminConnections = new Set<string>(); // socketIds of admin users

  constructor(
    private jwtService: JwtService,
    private analyticsService: AnalyticsService
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
      const userRole = payload.role;

      if (!userId) {
        client.disconnect();
        return;
      }

      // Store user connection
      this.connectedUsers.set(userId, client.id);
      client.data.userId = userId;
      client.data.userRole = userRole;

      // Join user to their personal room
      client.join(`user:${userId}`);

      // If admin, join admin room
      if (userRole === 'admin' || userRole === 'instructor') {
        client.join('admin');
        this.adminConnections.add(client.id);
      }

      this.logger.log(`User ${userId} (${userRole}) connected to analytics`);

      // Send initial analytics data if admin
      if (userRole === 'admin' || userRole === 'instructor') {
        const activeUsers = await this.analyticsService.getActiveUsers();
        client.emit('active_users_update', activeUsers);

        const realTimeEvents = await this.analyticsService.getRealTimeEvents(20);
        client.emit('realtime_events_update', realTimeEvents);
      }
    } catch (error) {
      this.logger.error('Connection error:', error);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const userId = client.data.userId;
    const userRole = client.data.userRole;

    if (userId) {
      this.connectedUsers.delete(userId);
      this.adminConnections.delete(client.id);
      this.logger.log(`User ${userId} (${userRole}) disconnected from analytics`);
    }
  }

  @SubscribeMessage('track_event')
  async handleTrackEvent(
    @MessageBody() data: { eventType: string; properties?: any; value?: number },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;

      // Track the event
      await this.analyticsService.trackEvent(
        userId,
        data.eventType as any,
        data.properties || {},
        undefined, // sessionId
        undefined, // page
        undefined, // referrer
        undefined, // ipAddress
        undefined, // userAgent
        data.value
      );

      // Broadcast to admin users
      this.server.to('admin').emit('event_tracked', {
        userId,
        eventType: data.eventType,
        timestamp: new Date(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error tracking event:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('track_activity')
  async handleTrackActivity(
    @MessageBody()
    data: {
      activityType: string;
      title: string;
      description?: string;
      courseId?: string;
      lessonId?: string;
      duration?: number;
      score?: number;
      isCompleted?: boolean;
    },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userId = client.data.userId;

      // Track the activity
      await this.analyticsService.trackActivity(
        userId,
        data.activityType as any,
        data.title,
        data.description,
        data.courseId,
        data.lessonId,
        undefined, // metadata
        data.duration,
        data.score,
        data.isCompleted
      );

      // Broadcast to admin users
      this.server.to('admin').emit('activity_tracked', {
        userId,
        activityType: data.activityType,
        title: data.title,
        timestamp: new Date(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error tracking activity:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('get_insights')
  async handleGetInsights(
    @MessageBody() data: { period?: string; metric?: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userRole = client.data.userRole;

      if (userRole !== 'admin' && userRole !== 'instructor') {
        return { success: false, error: 'Insufficient permissions' };
      }

      const insights = await this.analyticsService.getInsights(data.period || '30d', data.metric);

      return { success: true, insights };
    } catch (error) {
      this.logger.error('Error getting insights:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('get_predictions')
  async handleGetPredictions(
    @MessageBody() data: { horizon?: string; metric?: string },
    @ConnectedSocket() client: Socket
  ) {
    try {
      const userRole = client.data.userRole;

      if (userRole !== 'admin') {
        return { success: false, error: 'Insufficient permissions' };
      }

      const predictions = await this.analyticsService.getPredictions(
        data.horizon || '30d',
        data.metric
      );

      return { success: true, predictions };
    } catch (error) {
      this.logger.error('Error getting predictions:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('subscribe_realtime')
  async handleSubscribeRealtime(@ConnectedSocket() client: Socket) {
    try {
      const userRole = client.data.userRole;

      if (userRole !== 'admin' && userRole !== 'instructor') {
        return { success: false, error: 'Insufficient permissions' };
      }

      client.join('realtime_analytics');

      // Send current real-time data
      const activeUsers = await this.analyticsService.getActiveUsers();
      const realTimeEvents = await this.analyticsService.getRealTimeEvents(50);

      client.emit('realtime_data', {
        activeUsers,
        events: realTimeEvents,
        timestamp: new Date(),
      });

      return { success: true };
    } catch (error) {
      this.logger.error('Error subscribing to realtime:', error);
      return { success: false, error: error.message };
    }
  }

  @SubscribeMessage('unsubscribe_realtime')
  async handleUnsubscribeRealtime(@ConnectedSocket() client: Socket) {
    try {
      client.leave('realtime_analytics');
      return { success: true };
    } catch (error) {
      this.logger.error('Error unsubscribing from realtime:', error);
      return { success: false, error: error.message };
    }
  }

  // Method to broadcast analytics updates to admin users
  async broadcastAnalyticsUpdate(updateType: string, data: any) {
    this.server.to('admin').emit('analytics_update', {
      type: updateType,
      data,
      timestamp: new Date(),
    });
  }

  // Method to broadcast real-time analytics to subscribed users
  async broadcastRealtimeAnalytics(data: any) {
    this.server.to('realtime_analytics').emit('realtime_update', {
      ...data,
      timestamp: new Date(),
    });
  }

  // Method to send insights to specific user
  async sendInsightsToUser(userId: string, insights: any) {
    const socketId = this.connectedUsers.get(userId);

    if (socketId) {
      this.server.to(socketId).emit('insights_update', insights);
    }
  }

  // Method to get connected users count
  getConnectedUsersCount(): number {
    return this.connectedUsers.size;
  }

  // Method to get admin connections count
  getAdminConnectionsCount(): number {
    return this.adminConnections.size;
  }

  // Method to check if user is connected
  isUserConnected(userId: string): boolean {
    return this.connectedUsers.has(userId);
  }
}
