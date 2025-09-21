import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan } from 'typeorm';
import { AnalyticsEvent } from '../../analytics/entities/analytics-event.entity';
import { UserActivity } from '../../analytics/entities/user-activity.entity';

@Injectable()
export class CleanupService {
  private readonly logger = new Logger(CleanupService.name);

  constructor(
    @InjectRepository(AnalyticsEvent)
    private eventRepository: Repository<AnalyticsEvent>,
    @InjectRepository(UserActivity)
    private activityRepository: Repository<UserActivity>
  ) {}

  async cleanupExpiredSessions(): Promise<void> {
    try {
      // Clean up old analytics events (older than 1 year)
      const oneYearAgo = new Date();
      oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);

      const deletedEvents = await this.eventRepository.delete({
        createdAt: LessThan(oneYearAgo),
      });

      this.logger.log(`Cleaned up ${deletedEvents.affected || 0} old analytics events`);

      // Clean up old user activities (older than 6 months)
      const sixMonthsAgo = new Date();
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

      const deletedActivities = await this.activityRepository.delete({
        createdAt: LessThan(sixMonthsAgo),
      });

      this.logger.log(`Cleaned up ${deletedActivities.affected || 0} old user activities`);
    } catch (error) {
      this.logger.error('Error cleaning up expired sessions:', error);
      throw error;
    }
  }

  async cleanupOldLogs(): Promise<void> {
    try {
      // This would typically clean up log files
      // For now, we'll just log that the cleanup was attempted
      this.logger.log('Old logs cleanup completed (no action needed in current setup)');
    } catch (error) {
      this.logger.error('Error cleaning up old logs:', error);
      throw error;
    }
  }
}
