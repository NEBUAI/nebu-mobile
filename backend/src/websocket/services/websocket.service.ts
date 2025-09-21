import { Injectable, Logger } from '@nestjs/common';
import { NotificationsGateway } from '../gateway/notifications.gateway';
import { ProgressGateway } from '../gateway/progress.gateway';
import { AnalyticsGateway } from '../gateway/analytics.gateway';

@Injectable()
export class WebSocketService {
  private readonly logger = new Logger(WebSocketService.name);

  constructor(
    private notificationsGateway: NotificationsGateway,
    private progressGateway: ProgressGateway,
    private analyticsGateway: AnalyticsGateway
  ) {}

  // Notification methods
  async sendNotificationToUser(userId: string, notification: any) {
    try {
      await this.notificationsGateway.sendNotificationToUser(userId, notification);
      this.logger.log(`Notification sent to user ${userId}`);
    } catch (error) {
      this.logger.error(`Failed to send notification to user ${userId}:`, error);
    }
  }

  async sendNotificationToUsers(userIds: string[], notification: any) {
    try {
      await this.notificationsGateway.sendNotificationToUsers(userIds, notification);
      this.logger.log(`Notification sent to ${userIds.length} users`);
    } catch (error) {
      this.logger.error(`Failed to send notification to users:`, error);
    }
  }

  async broadcastNotification(notification: any) {
    try {
      await this.notificationsGateway.broadcastNotification(notification);
      this.logger.log('Notification broadcasted to all users');
    } catch (error) {
      this.logger.error('Failed to broadcast notification:', error);
    }
  }

  // Progress methods
  async sendProgressUpdate(userId: string, progressData: any) {
    try {
      await this.progressGateway.sendProgressUpdate(userId, progressData);
      this.logger.log(`Progress update sent to user ${userId}`);
    } catch (error) {
      this.logger.error(`Failed to send progress update to user ${userId}:`, error);
    }
  }

  async broadcastCourseProgress(courseId: string, progressData: any) {
    try {
      await this.progressGateway.broadcastCourseProgress(courseId, progressData);
      this.logger.log(`Progress update broadcasted to course ${courseId}`);
    } catch (error) {
      this.logger.error(`Failed to broadcast progress to course ${courseId}:`, error);
    }
  }

  // Analytics methods
  async broadcastAnalyticsUpdate(updateType: string, data: any) {
    try {
      await this.analyticsGateway.broadcastAnalyticsUpdate(updateType, data);
      this.logger.log(`Analytics update broadcasted: ${updateType}`);
    } catch (error) {
      this.logger.error(`Failed to broadcast analytics update:`, error);
    }
  }

  async broadcastRealtimeAnalytics(data: any) {
    try {
      await this.analyticsGateway.broadcastRealtimeAnalytics(data);
      this.logger.log('Realtime analytics broadcasted');
    } catch (error) {
      this.logger.error('Failed to broadcast realtime analytics:', error);
    }
  }

  async sendInsightsToUser(userId: string, insights: any) {
    try {
      await this.analyticsGateway.sendInsightsToUser(userId, insights);
      this.logger.log(`Insights sent to user ${userId}`);
    } catch (error) {
      this.logger.error(`Failed to send insights to user ${userId}:`, error);
    }
  }

  // Utility methods
  async getConnectedUsersCount(): Promise<number> {
    return this.analyticsGateway.getConnectedUsersCount();
  }

  async getAdminConnectionsCount(): Promise<number> {
    return this.analyticsGateway.getAdminConnectionsCount();
  }

  async isUserConnected(userId: string): Promise<boolean> {
    return this.analyticsGateway.isUserConnected(userId);
  }
}
