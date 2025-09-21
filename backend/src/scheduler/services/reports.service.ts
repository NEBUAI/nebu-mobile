import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { User, UserRole } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { UserCourseEnrollment } from '../../courses/entities/user-course-enrollment.entity';
import { Progress } from '../../progress/entities/progress.entity';
import { AnalyticsEvent, EventType } from '../../analytics/entities/analytics-event.entity';
import { UserActivity } from '../../analytics/entities/user-activity.entity';

interface DailyMetrics {
  date: string;
  userRegistrations: number;
  courseEnrollments: number;
  courseCompletions: number;
  activeUsers: number;
  pageViews: number;
  avgSessionDuration: number;
  systemHealth: string;
}

interface WeeklyMetrics {
  weekOf: string;
  userGrowth: number;
  userRetention: number;
  courseCompletions: number;
  totalRevenue: number;
  avgEngagement: number;
  topCourses: Array<{ courseId: string; title: string; enrollments: number }>;
  userActivityTrends: Array<{ day: string; activeUsers: number }>;
}

interface MonthlyMetrics {
  month: string;
  userGrowth: number;
  churnRate: number;
  revenueGrowth: number;
  coursePerformance: Array<{ courseId: string; completionRate: number; avgScore: number }>;
  userEngagement: {
    totalSessions: number;
    avgSessionDuration: number;
    bounceRate: number;
  };
  systemMetrics: {
    uptime: number;
    avgResponseTime: number;
    errorRate: number;
  };
}

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);

  constructor(
    private notificationsService: NotificationsService,
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Course)
    private courseRepository: Repository<Course>,
    @InjectRepository(UserCourseEnrollment)
    private enrollmentRepository: Repository<UserCourseEnrollment>,
    @InjectRepository(Progress)
    private progressRepository: Repository<Progress>,
    @InjectRepository(AnalyticsEvent)
    private analyticsRepository: Repository<AnalyticsEvent>,
    @InjectRepository(UserActivity)
    private activityRepository: Repository<UserActivity>
  ) {}

  async generateDailyReports(): Promise<void> {
    try {
      this.logger.log('Generating daily reports...');

      // Get yesterday's date range
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);
      yesterday.setHours(0, 0, 0, 0);

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      // Generate comprehensive daily metrics
      const dailyMetrics: DailyMetrics = {
        date: yesterday.toISOString().split('T')[0],
        userRegistrations: await this.getUserRegistrations(yesterday, today),
        courseEnrollments: await this.getCourseEnrollments(yesterday, today),
        courseCompletions: await this.getCourseCompletions(yesterday, today),
        activeUsers: await this.getActiveUsers(yesterday, today),
        pageViews: await this.getPageViews(yesterday, today),
        avgSessionDuration: await this.getAvgSessionDuration(yesterday, today),
        systemHealth: await this.getSystemHealth(),
      };

      // Send report to admins
      await this.sendReportToAdmins({
        type: 'daily',
        metrics: dailyMetrics,
        generatedAt: new Date(),
      });

      this.logger.log(`Daily report generated for ${dailyMetrics.date}:`, dailyMetrics);
    } catch (error) {
      this.logger.error('Error generating daily reports:', error);
      throw error;
    }
  }

  async generateWeeklyReports(): Promise<void> {
    try {
      this.logger.log('Generating weekly reports...');

      // Get week range
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(endDate.getDate() - 7);

      const weeklyMetrics: WeeklyMetrics = {
        weekOf: startDate.toISOString().split('T')[0],
        userGrowth: await this.getUserGrowth(startDate, endDate),
        userRetention: await this.getUserRetention(startDate, endDate),
        courseCompletions: await this.getCourseCompletions(startDate, endDate),
        totalRevenue: await this.getTotalRevenue(startDate, endDate),
        avgEngagement: await this.getAvgEngagement(startDate, endDate),
        topCourses: await this.getTopCourses(startDate, endDate),
        userActivityTrends: await this.getUserActivityTrends(startDate, endDate),
      };

      await this.sendReportToAdmins({
        type: 'weekly',
        metrics: weeklyMetrics,
        generatedAt: new Date(),
      });

      this.logger.log('Weekly reports generated successfully');
    } catch (error) {
      this.logger.error('Error generating weekly reports:', error);
      throw error;
    }
  }

  async generateMonthlyReports(): Promise<void> {
    try {
      this.logger.log('Generating monthly reports...');

      // Get month range
      const endDate = new Date();
      const startDate = new Date();
      startDate.setMonth(endDate.getMonth() - 1);

      const monthlyMetrics: MonthlyMetrics = {
        month: startDate.toISOString().split('T')[0].substring(0, 7),
        userGrowth: await this.getUserGrowth(startDate, endDate),
        churnRate: await this.getChurnRate(startDate, endDate),
        revenueGrowth: await this.getRevenueGrowth(startDate, endDate),
        coursePerformance: await this.getCoursePerformance(startDate, endDate),
        userEngagement: await this.getUserEngagementMetrics(startDate, endDate),
        systemMetrics: await this.getSystemMetrics(),
      };

      await this.sendReportToAdmins({
        type: 'monthly',
        metrics: monthlyMetrics,
        generatedAt: new Date(),
      });

      this.logger.log('Monthly reports generated successfully');
    } catch (error) {
      this.logger.error('Error generating monthly reports:', error);
      throw error;
    }
  }

  // Helper methods for metrics calculation
  private async getUserRegistrations(startDate: Date, endDate: Date): Promise<number> {
    return await this.userRepository.count({
      where: {
        createdAt: Between(startDate, endDate),
      },
    });
  }

  private async getCourseEnrollments(startDate: Date, endDate: Date): Promise<number> {
    return await this.enrollmentRepository.count({
      where: {
        enrolledAt: Between(startDate, endDate),
      },
    });
  }

  private async getCourseCompletions(startDate: Date, endDate: Date): Promise<number> {
    return await this.progressRepository.count({
      where: {
        completedAt: Between(startDate, endDate),
        isCompleted: true,
      },
    });
  }

  private async getActiveUsers(startDate: Date, endDate: Date): Promise<number> {
    return await this.activityRepository
      .createQueryBuilder('activity')
      .select('COUNT(DISTINCT activity.userId)', 'count')
      .where('activity.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .getRawOne()
      .then(result => parseInt(result.count) || 0);
  }

  private async getPageViews(startDate: Date, endDate: Date): Promise<number> {
    return await this.analyticsRepository.count({
      where: {
        eventType: EventType.PAGE_VIEW,
        createdAt: Between(startDate, endDate),
      },
    });
  }

  private async getAvgSessionDuration(startDate: Date, endDate: Date): Promise<number> {
    const result = await this.activityRepository
      .createQueryBuilder('activity')
      .select('AVG(activity.duration)', 'avgDuration')
      .where('activity.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .getRawOne();

    return parseFloat(result.avgDuration) || 0;
  }

  private async getSystemHealth(): Promise<string> {
    // Simple health check - could be expanded with actual metrics
    try {
      await this.userRepository.count();
      return 'healthy';
    } catch {
      return 'unhealthy';
    }
  }

  private async getUserGrowth(startDate: Date, endDate: Date): Promise<number> {
    const currentPeriod = await this.getUserRegistrations(startDate, endDate);
    const previousStart = new Date(startDate);
    const previousEnd = new Date(endDate);
    previousStart.setDate(
      previousStart.getDate() - (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)
    );
    previousEnd.setDate(
      previousEnd.getDate() - (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)
    );

    const previousPeriod = await this.getUserRegistrations(previousStart, previousEnd);

    return previousPeriod > 0 ? ((currentPeriod - previousPeriod) / previousPeriod) * 100 : 0;
  }

  private async getUserRetention(startDate: Date, endDate: Date): Promise<number> {
    const totalUsers = await this.userRepository.count({
      where: {
        createdAt: Between(startDate, endDate),
      },
    });

    const activeUsers = await this.getActiveUsers(startDate, endDate);

    return totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;
  }

  private async getTotalRevenue(_startDate: Date, _endDate: Date): Promise<number> {
    // TODO: Implement revenue calculation when payment entities are available
    return 0;
  }

  private async getAvgEngagement(startDate: Date, endDate: Date): Promise<number> {
    const result = await this.activityRepository
      .createQueryBuilder('activity')
      .select('AVG(activity.duration)', 'avgEngagement')
      .where('activity.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .getRawOne();

    return parseFloat(result.avgEngagement) || 0;
  }

  private async getTopCourses(
    startDate: Date,
    endDate: Date
  ): Promise<Array<{ courseId: string; title: string; enrollments: number }>> {
    const result = await this.enrollmentRepository
      .createQueryBuilder('enrollment')
      .leftJoin('enrollment.course', 'course')
      .select(['course.id as courseId', 'course.title as title', 'COUNT(*) as enrollments'])
      .where('enrollment.enrolledAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('course.id, course.title')
      .orderBy('COUNT(*)', 'DESC')
      .limit(5)
      .getRawMany();

    return result.map(row => ({
      courseId: row.courseId,
      title: row.title,
      enrollments: parseInt(row.enrollments),
    }));
  }

  private async getUserActivityTrends(
    startDate: Date,
    endDate: Date
  ): Promise<Array<{ day: string; activeUsers: number }>> {
    const result = await this.activityRepository
      .createQueryBuilder('activity')
      .select(['DATE(activity.createdAt) as day', 'COUNT(DISTINCT activity.userId) as activeUsers'])
      .where('activity.createdAt BETWEEN :startDate AND :endDate', { startDate, endDate })
      .groupBy('DATE(activity.createdAt)')
      .orderBy('day', 'ASC')
      .getRawMany();

    return result.map(row => ({
      day: row.day,
      activeUsers: parseInt(row.activeUsers),
    }));
  }

  private async getChurnRate(startDate: Date, endDate: Date): Promise<number> {
    const totalUsers = await this.userRepository.count({
      where: {
        createdAt: Between(startDate, endDate),
      },
    });

    // Users who haven't been active in the period
    const inactiveUsers = totalUsers - (await this.getActiveUsers(startDate, endDate));

    return totalUsers > 0 ? (inactiveUsers / totalUsers) * 100 : 0;
  }

  private async getRevenueGrowth(_startDate: Date, _endDate: Date): Promise<number> {
    // TODO: Implement revenue growth calculation
    return 0;
  }

  private async getCoursePerformance(
    _startDate: Date,
    _endDate: Date
  ): Promise<Array<{ courseId: string; completionRate: number; avgScore: number }>> {
    // TODO: Implement course performance analysis
    return [];
  }

  private async getUserEngagementMetrics(
    startDate: Date,
    endDate: Date
  ): Promise<{
    totalSessions: number;
    avgSessionDuration: number;
    bounceRate: number;
  }> {
    const totalSessions = await this.activityRepository.count({
      where: {
        createdAt: Between(startDate, endDate),
      },
    });

    const avgSessionDuration = await this.getAvgSessionDuration(startDate, endDate);

    // Simple bounce rate calculation
    const bounceRate = 25; // Placeholder - would need proper session tracking

    return {
      totalSessions,
      avgSessionDuration,
      bounceRate,
    };
  }

  private async getSystemMetrics(): Promise<{
    uptime: number;
    avgResponseTime: number;
    errorRate: number;
  }> {
    // Placeholder system metrics
    return {
      uptime: 99.9,
      avgResponseTime: 150,
      errorRate: 0.1,
    };
  }

  async generateCustomReport(
    startDate: Date,
    endDate: Date,
    reportType: string
  ): Promise<{
    reportType: string;
    startDate: Date;
    endDate: Date;
    generatedAt: Date;
    data: Record<string, unknown>;
  }> {
    try {
      this.logger.log(`Generating custom report: ${reportType} from ${startDate} to ${endDate}`);

      let data: Record<string, unknown> = {};

      switch (reportType) {
        case 'user_activity':
          data = {
            activeUsers: await this.getActiveUsers(startDate, endDate),
            userRegistrations: await this.getUserRegistrations(startDate, endDate),
            userRetention: await this.getUserRetention(startDate, endDate),
          };
          break;
        case 'course_performance':
          data = {
            enrollments: await this.getCourseEnrollments(startDate, endDate),
            completions: await this.getCourseCompletions(startDate, endDate),
            topCourses: await this.getTopCourses(startDate, endDate),
          };
          break;
        case 'engagement':
          data = {
            pageViews: await this.getPageViews(startDate, endDate),
            avgSessionDuration: await this.getAvgSessionDuration(startDate, endDate),
            userActivityTrends: await this.getUserActivityTrends(startDate, endDate),
          };
          break;
        default:
          data = {
            summary: 'Custom report generated',
            period: `${startDate.toISOString()} to ${endDate.toISOString()}`,
          };
      }

      return {
        reportType,
        startDate,
        endDate,
        generatedAt: new Date(),
        data,
      };
    } catch (error) {
      this.logger.error('Error generating custom report:', error);
      throw error;
    }
  }

  async sendReportToAdmins(reportData: Record<string, unknown>): Promise<void> {
    try {
      this.logger.log('Sending report to admins...');

      // Get admin users
      const adminUsers = await this.userRepository.find({
        where: {
          role: UserRole.ADMIN,
        },
      });

      // Send notification to each admin
      for (const admin of adminUsers) {
        await this.notificationsService.create({
          userId: admin.id,
          title: `${reportData.type} Report Generated`,
          message: `A new ${reportData.type} report has been generated at ${reportData.generatedAt}`,
          type: 'system' as any,
          data: reportData,
        });
      }

      this.logger.log(`Report sent to ${adminUsers.length} administrators`);
    } catch (error) {
      this.logger.error('Error sending report to admins:', error);
      throw error;
    }
  }
}
