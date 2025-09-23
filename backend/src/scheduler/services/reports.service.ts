import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { User, UserRole } from '../../users/entities/user.entity';
import { Course } from '../../courses/entities/course.entity';
import { UserCourseEnrollment } from '../../courses/entities/user-course-enrollment.entity';

interface DailyMetrics {
  date: string;
  userRegistrations: number;
  courseEnrollments: number;
  courseCompletions: number;
  activeUsers: number;
}

@Injectable()
export class ReportsService {
  private readonly logger = new Logger(ReportsService.name);

  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    @InjectRepository(Course)
    private courseRepository: Repository<Course>,
    @InjectRepository(UserCourseEnrollment)
    private enrollmentRepository: Repository<UserCourseEnrollment>,
    private notificationsService: NotificationsService,
  ) {}

  async generateDailyReport(): Promise<DailyMetrics> {
    const today = new Date();
    const startOfDay = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);

    try {
      const userRegistrations = await this.userRepository.count({
        where: {
          createdAt: Between(startOfDay, endOfDay),
        },
      });

      const courseEnrollments = await this.enrollmentRepository.count({
        where: {
          enrolledAt: Between(startOfDay, endOfDay),
        },
      });

      // Calculate active users (users who logged in today)
      const activeUsers = await this.userRepository.count({
        where: {
          lastLoginAt: Between(startOfDay, endOfDay),
        },
      });

      const report: DailyMetrics = {
        date: startOfDay.toISOString().split('T')[0],
        userRegistrations,
        courseEnrollments,
        courseCompletions: 0, // Simplified - no progress tracking
        activeUsers,
      };

      this.logger.log(`Daily report generated for ${report.date}:`, report);
      return report;
    } catch (error) {
      this.logger.error('Error generating daily report:', error);
      throw error;
    }
  }

  async generateWeeklyReport(): Promise<DailyMetrics[]> {
    const reports: DailyMetrics[] = [];
    const today = new Date();

    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const report = await this.generateDailyReport();
      reports.push(report);
    }

    return reports;
  }

  async generateMonthlyReport(): Promise<DailyMetrics[]> {
    const reports: DailyMetrics[] = [];
    const today = new Date();

    for (let i = 29; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(date.getDate() - i);
      const report = await this.generateDailyReport();
      reports.push(report);
    }

    return reports;
  }

  async getSystemStats(): Promise<{
    totalUsers: number;
    totalCourses: number;
    totalEnrollments: number;
    activeUsers: number;
  }> {
    try {
      const totalUsers = await this.userRepository.count();
      const totalCourses = await this.courseRepository.count();
      const totalEnrollments = await this.enrollmentRepository.count();

      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const activeUsers = await this.userRepository.count({
        where: {
          lastLoginAt: Between(thirtyDaysAgo, new Date()),
        },
      });

      return {
        totalUsers,
        totalCourses,
        totalEnrollments,
        activeUsers,
      };
    } catch (error) {
      this.logger.error('Error getting system stats:', error);
      throw error;
    }
  }
}