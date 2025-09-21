import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, Not } from 'typeorm';
import { AnalyticsEvent, EventType } from '../entities/analytics-event.entity';
import { UserActivity, ActivityType } from '../entities/user-activity.entity';

@Injectable()
export class ReportsService {
  constructor(
    @InjectRepository(AnalyticsEvent)
    private eventRepository: Repository<AnalyticsEvent>,
    @InjectRepository(UserActivity)
    private activityRepository: Repository<UserActivity>
  ) {}

  async generateDashboardReport(
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    overview: {
      totalUsers: number;
      activeUsers: number;
      totalCourses: number;
      completedCourses: number;
      totalRevenue: number;
    };
    engagement: {
      averageSessionDuration: number;
      pageViews: number;
      bounceRate: number;
      topPages: Array<{ page: string; views: number }>;
    };
    learning: {
      courseCompletions: number;
      averageCourseScore: number;
      mostPopularCourses: Array<{ courseId: string; enrollments: number }>;
      learningPathProgress: Array<{ step: string; completions: number }>;
    };
    revenue: {
      totalRevenue: number;
      monthlyRevenue: Array<{ month: string; revenue: number }>;
      revenueByCourse: Array<{ courseId: string; revenue: number }>;
      subscriptionRevenue: number;
      oneTimeRevenue: number;
    };
  }> {
    const whereConditions: Record<string, unknown> = {};

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    const [overview, engagement, learning, revenue] = await Promise.all([
      this.getOverviewStats(whereConditions),
      this.getEngagementStats(whereConditions),
      this.getLearningStats(whereConditions),
      this.getRevenueStats(whereConditions),
    ]);

    return {
      overview,
      engagement,
      learning,
      revenue,
    };
  }

  async generateUserReport(
    userId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    profile: {
      totalActivities: number;
      completedCourses: number;
      totalStudyTime: number;
      averageScore: number;
      joinDate: Date;
    };
    progress: {
      coursesInProgress: number;
      coursesCompleted: number;
      certificatesEarned: number;
      currentStreak: number;
    };
    activity: {
      dailyActivity: Array<{ date: string; activities: number }>;
      activityByType: Array<{ type: ActivityType; count: number }>;
      recentActivity: UserActivity[];
    };
  }> {
    const whereConditions: any = { userId };

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    const [profile, progress, activity] = await Promise.all([
      this.getUserProfileStats(userId, whereConditions),
      this.getUserProgressStats(userId, whereConditions),
      this.getUserActivityStats(userId, whereConditions),
    ]);

    return {
      profile,
      progress,
      activity,
    };
  }

  async generateCourseReport(
    courseId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    performance: {
      enrollments: number;
      completions: number;
      completionRate: number;
      averageScore: number;
      averageDuration: number;
    };
    engagement: {
      totalLessons: number;
      completedLessons: number;
      averageTimePerLesson: number;
      dropOffPoints: Array<{ lessonId: string; dropOffRate: number }>;
    };
    feedback: {
      averageRating: number;
      totalReviews: number;
      ratingDistribution: Array<{ rating: number; count: number }>;
    };
  }> {
    const whereConditions: any = { courseId };

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    const [performance, engagement, feedback] = await Promise.all([
      this.getCoursePerformanceStats(courseId, whereConditions),
      this.getCourseEngagementStats(courseId, whereConditions),
      this.getCourseFeedbackStats(courseId, whereConditions),
    ]);

    return {
      performance,
      engagement,
      feedback,
    };
  }

  private async getOverviewStats(_whereConditions: any) {
    const [totalUsers, activeUsers, totalCourses, completedCourses, totalRevenue] =
      await Promise.all([
        this.eventRepository
          .createQueryBuilder('event')
          .select('COUNT(DISTINCT event.userId)', 'count')
          .where('event.userId IS NOT NULL')
          .getRawOne()
          .then(result => parseInt(result.count) || 0),
        this.eventRepository
          .createQueryBuilder('event')
          .select('COUNT(DISTINCT event.userId)', 'count')
          .where('event.userId IS NOT NULL AND event.createdAt >= :date', {
            date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000), // Last 30 days
          })
          .getRawOne()
          .then(result => parseInt(result.count) || 0),
        this.activityRepository
          .createQueryBuilder('activity')
          .select('COUNT(DISTINCT activity.courseId)', 'count')
          .where('activity.courseId IS NOT NULL')
          .getRawOne()
          .then(result => parseInt(result.count) || 0),
        this.activityRepository
          .createQueryBuilder('activity')
          .select('COUNT(DISTINCT activity.courseId)', 'count')
          .where('activity.courseId IS NOT NULL AND activity.activityType = :type', {
            type: ActivityType.LESSON_COMPLETE,
          })
          .getRawOne()
          .then(result => parseInt(result.count) || 0),
        this.eventRepository
          .createQueryBuilder('event')
          .select('SUM(event.value)', 'total')
          .where('event.eventType IN (:...types)', {
            types: [EventType.PAYMENT_SUCCESS, EventType.SUBSCRIPTION_CREATE],
          })
          .getRawOne()
          .then(result => parseFloat(result.total) || 0),
      ]);

    return {
      totalUsers,
      activeUsers,
      totalCourses,
      completedCourses,
      totalRevenue,
    };
  }

  private async getEngagementStats(_whereConditions: any) {
    // Simplified implementation - would need more complex queries for real metrics
    const pageViews = await this.eventRepository.count({
      where: { ..._whereConditions, eventType: EventType.PAGE_VIEW },
    });

    return {
      averageSessionDuration: 0, // Would need session tracking
      pageViews,
      bounceRate: 0, // Would need session tracking
      topPages: [], // Would need page tracking
    };
  }

  private async getLearningStats(_whereConditions: any) {
    const [courseCompletions, averageCourseScore] = await Promise.all([
      this.activityRepository.count({
        where: {
          ..._whereConditions,
          activityType: ActivityType.LESSON_COMPLETE,
          isCompleted: true,
        },
      }),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('AVG(activity.score)', 'average')
        .where({ ..._whereConditions, score: Not(null) })
        .getRawOne()
        .then(result => parseFloat(result.average) || 0),
    ]);

    return {
      courseCompletions,
      averageCourseScore,
      mostPopularCourses: [], // Would need course data
      learningPathProgress: [], // Would need learning path data
    };
  }

  private async getRevenueStats(_whereConditions: any) {
    const [totalRevenue, subscriptionRevenue, oneTimeRevenue] = await Promise.all([
      this.eventRepository
        .createQueryBuilder('event')
        .select('SUM(event.value)', 'total')
        .where('event.eventType IN (:...types)', {
          types: [EventType.PAYMENT_SUCCESS, EventType.SUBSCRIPTION_CREATE],
        })
        .getRawOne()
        .then(result => parseFloat(result.total) || 0),
      this.eventRepository
        .createQueryBuilder('event')
        .select('SUM(event.value)', 'total')
        .where('event.eventType = :type', { type: EventType.SUBSCRIPTION_CREATE })
        .getRawOne()
        .then(result => parseFloat(result.total) || 0),
      this.eventRepository
        .createQueryBuilder('event')
        .select('SUM(event.value)', 'total')
        .where('event.eventType = :type', { type: EventType.PAYMENT_SUCCESS })
        .getRawOne()
        .then(result => parseFloat(result.total) || 0),
    ]);

    return {
      totalRevenue,
      monthlyRevenue: [], // Would need monthly breakdown
      revenueByCourse: [], // Would need course revenue data
      subscriptionRevenue,
      oneTimeRevenue,
    };
  }

  private async getUserProfileStats(userId: string, whereConditions: any) {
    const [totalActivities, completedCourses, totalStudyTime, averageScore] = await Promise.all([
      this.activityRepository.count({ where: whereConditions }),
      this.activityRepository.count({
        where: {
          ...whereConditions,
          activityType: ActivityType.LESSON_COMPLETE,
          isCompleted: true,
        },
      }),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('SUM(activity.duration)', 'total')
        .where(whereConditions)
        .getRawOne()
        .then(result => parseInt(result.total) || 0),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('AVG(activity.score)', 'average')
        .where({ ...whereConditions, score: Not(null) })
        .getRawOne()
        .then(result => parseFloat(result.average) || 0),
    ]);

    return {
      totalActivities,
      completedCourses,
      totalStudyTime,
      averageScore,
      joinDate: new Date(), // Would need user creation date
    };
  }

  private async getUserProgressStats(userId: string, whereConditions: any) {
    const [coursesInProgress, coursesCompleted, certificatesEarned] = await Promise.all([
      this.activityRepository.count({
        where: { ...whereConditions, activityType: ActivityType.COURSE_ENROLLMENT },
      }),
      this.activityRepository.count({
        where: {
          ...whereConditions,
          activityType: ActivityType.LESSON_COMPLETE,
          isCompleted: true,
        },
      }),
      this.activityRepository.count({
        where: { ...whereConditions, activityType: ActivityType.CERTIFICATE_EARNED },
      }),
    ]);

    return {
      coursesInProgress,
      coursesCompleted,
      certificatesEarned,
      currentStreak: 0, // Would need streak calculation
    };
  }

  private async getUserActivityStats(userId: string, whereConditions: any) {
    const [dailyActivity, activityByType, recentActivity] = await Promise.all([
      this.getDailyActivityStats(whereConditions),
      this.getActivityByTypeStats(whereConditions),
      this.activityRepository.find({
        where: whereConditions,
        relations: ['course', 'lesson'],
        order: { createdAt: 'DESC' },
        take: 10,
      }),
    ]);

    return {
      dailyActivity,
      activityByType,
      recentActivity,
    };
  }

  private async getCoursePerformanceStats(courseId: string, whereConditions: any) {
    const [enrollments, completions, averageScore, averageDuration] = await Promise.all([
      this.activityRepository.count({
        where: { ...whereConditions, activityType: ActivityType.COURSE_ENROLLMENT },
      }),
      this.activityRepository.count({
        where: {
          ...whereConditions,
          activityType: ActivityType.LESSON_COMPLETE,
          isCompleted: true,
        },
      }),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('AVG(activity.score)', 'average')
        .where({ ...whereConditions, score: Not(null) })
        .getRawOne()
        .then(result => parseFloat(result.average) || 0),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('AVG(activity.duration)', 'average')
        .where({ ...whereConditions, duration: Not(null) })
        .getRawOne()
        .then(result => parseFloat(result.average) || 0),
    ]);

    const completionRate = enrollments > 0 ? (completions / enrollments) * 100 : 0;

    return {
      enrollments,
      completions,
      completionRate,
      averageScore,
      averageDuration,
    };
  }

  private async getCourseEngagementStats(courseId: string, whereConditions: any) {
    const [totalLessons, completedLessons, averageTimePerLesson] = await Promise.all([
      this.activityRepository.count({
        where: { ...whereConditions, activityType: ActivityType.LESSON_START },
      }),
      this.activityRepository.count({
        where: {
          ...whereConditions,
          activityType: ActivityType.LESSON_COMPLETE,
          isCompleted: true,
        },
      }),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('AVG(activity.duration)', 'average')
        .where({ ...whereConditions, activityType: ActivityType.LESSON_COMPLETE })
        .getRawOne()
        .then(result => parseFloat(result.average) || 0),
    ]);

    return {
      totalLessons,
      completedLessons,
      averageTimePerLesson,
      dropOffPoints: [], // Would need lesson-level data
    };
  }

  private async getCourseFeedbackStats(_courseId: string, _whereConditions: any) {
    // Simplified - would need review/rating data
    return {
      averageRating: 0,
      totalReviews: 0,
      ratingDistribution: [],
    };
  }

  private async getDailyActivityStats(whereConditions: any) {
    const results = await this.activityRepository
      .createQueryBuilder('activity')
      .select('DATE(activity.createdAt)', 'date')
      .addSelect('COUNT(*)', 'activities')
      .where(whereConditions)
      .groupBy('DATE(activity.createdAt)')
      .orderBy('date', 'ASC')
      .getRawMany();

    return results.map(({ date, activities }) => ({
      date,
      activities: parseInt(activities),
    }));
  }

  private async getActivityByTypeStats(whereConditions: any) {
    const results = await this.activityRepository
      .createQueryBuilder('activity')
      .select('activity.activityType', 'type')
      .addSelect('COUNT(*)', 'count')
      .where(whereConditions)
      .groupBy('activity.activityType')
      .getRawMany();

    return results.map(({ type, count }) => ({
      type: type as ActivityType,
      count: parseInt(count),
    }));
  }

  async exportDashboardReport(
    startDate?: Date,
    endDate?: Date,
    format: 'csv' | 'json' = 'csv'
  ): Promise<{
    data: string;
    filename: string;
    contentType: string;
  }> {
    const report = await this.generateDashboardReport(startDate, endDate);

    if (format === 'json') {
      return {
        data: JSON.stringify(report, null, 2),
        filename: `dashboard-report-${new Date().toISOString().split('T')[0]}.json`,
        contentType: 'application/json',
      };
    }

    // Generar CSV
    const csvData = this.convertToCSV(report);
    return {
      data: csvData,
      filename: `dashboard-report-${new Date().toISOString().split('T')[0]}.csv`,
      contentType: 'text/csv',
    };
  }

  private convertToCSV(data: any): string {
    const headers = ['Metric', 'Value', 'Category', 'Date'];

    const rows = [];

    // Overview metrics
    Object.entries(data.overview).forEach(([key, value]) => {
      rows.push([key, value, 'overview', new Date().toISOString()]);
    });

    // Engagement metrics
    Object.entries(data.engagement).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach((item: any) => {
          rows.push([
            `${key}_${item.page || item.activity}`,
            item.views || item.count,
            'engagement',
            new Date().toISOString(),
          ]);
        });
      } else {
        rows.push([key, value, 'engagement', new Date().toISOString()]);
      }
    });

    // Learning metrics
    Object.entries(data.learning).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach((item: any) => {
          rows.push([
            `${key}_${item.courseId || item.step}`,
            item.enrollments || item.completions,
            'learning',
            new Date().toISOString(),
          ]);
        });
      } else {
        rows.push([key, value, 'learning', new Date().toISOString()]);
      }
    });

    // Revenue metrics
    Object.entries(data.revenue).forEach(([key, value]) => {
      if (Array.isArray(value)) {
        value.forEach((item: any) => {
          rows.push([
            `${key}_${item.month || item.courseId}`,
            item.revenue,
            'revenue',
            new Date().toISOString(),
          ]);
        });
      } else {
        rows.push([key, value, 'revenue', new Date().toISOString()]);
      }
    });

    const csvContent = [headers, ...rows]
      .map(row => row.map(field => `"${field}"`).join(','))
      .join('\n');

    return csvContent;
  }
}
