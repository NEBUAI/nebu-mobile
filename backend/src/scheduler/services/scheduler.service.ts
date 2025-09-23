import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { CleanupService } from './cleanup.service';
import { ReportsService } from './reports.service';
import { User } from '../../users/entities/user.entity';
import { EmailNotificationsService } from '../../notifications/services/email-notifications.service';

@Injectable()
export class SchedulerService {
  private readonly logger = new Logger(SchedulerService.name);

  constructor(
    private notificationsService: NotificationsService,
    private cleanupService: CleanupService,
    private reportsService: ReportsService,
    private emailService: EmailNotificationsService,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async processPendingNotifications() {
    try {
      this.logger.log('Processing pending notifications...');
      await this.notificationsService.processPendingNotifications();
      this.logger.log('Pending notifications processed');
    } catch (error) {
      this.logger.error('Error processing pending notifications:', error);
    }
  }

  @Cron(CronExpression.EVERY_5_MINUTES)
  async cleanupExpiredSessions() {
    try {
      this.logger.log('Cleaning up expired sessions...');
      await this.cleanupService.cleanupExpiredSessions();
      this.logger.log('Expired sessions cleaned up');
    } catch (error) {
      this.logger.error('Error cleaning up expired sessions:', error);
    }
  }
}
