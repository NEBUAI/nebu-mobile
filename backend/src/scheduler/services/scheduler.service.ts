import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { CleanupService } from './cleanup.service';
import { ReportsService } from './reports.service';
import { User } from '../../users/entities/user.entity';
import { UserCourseEnrollment } from '../../courses/entities/user-course-enrollment.entity';
import { Progress } from '../../progress/entities/progress.entity';
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
    @InjectRepository(UserCourseEnrollment)
    private enrollmentRepository: Repository<UserCourseEnrollment>,
    @InjectRepository(Progress)
    private progressRepository: Repository<Progress>
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

  @Cron(CronExpression.EVERY_HOUR)
  async cleanupOldLogs() {
    try {
      this.logger.log('Cleaning up old logs...');
      await this.cleanupService.cleanupOldLogs();
      this.logger.log('Old logs cleaned up');
    } catch (error) {
      this.logger.error('Error cleaning up old logs:', error);
    }
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async generateDailyReports() {
    try {
      this.logger.log('Generating daily reports...');
      await this.reportsService.generateDailyReports();
      this.logger.log('Daily reports generated');
    } catch (error) {
      this.logger.error('Error generating daily reports:', error);
    }
  }

  @Cron(CronExpression.EVERY_WEEK)
  async generateWeeklyReports() {
    try {
      this.logger.log('Generating weekly reports...');
      await this.reportsService.generateWeeklyReports();
      this.logger.log('Weekly reports generated');
    } catch (error) {
      this.logger.error('Error generating weekly reports:', error);
    }
  }

  @Cron(CronExpression.EVERY_1ST_DAY_OF_MONTH_AT_MIDNIGHT)
  async generateMonthlyReports() {
    try {
      this.logger.log('Generating monthly reports...');
      await this.reportsService.generateMonthlyReports();
      this.logger.log('Monthly reports generated');
    } catch (error) {
      this.logger.error('Error generating monthly reports:', error);
    }
  }

  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async sendReminderEmails() {
    try {
      this.logger.log('Sending reminder emails...');
      await this.sendReminderEmailsInternal();
      this.logger.log('Reminder emails sent');
    } catch (error) {
      this.logger.error('Error sending reminder emails:', error);
    }
  }

  private async sendReminderEmailsInternal() {
    try {
      // 1. Users who haven't logged in for 7 days
      await this.sendInactiveUserReminders();

      // 2. Users with incomplete courses (enrolled but not completed)
      await this.sendIncompleteCoursesReminders();

      // 3. Course completion reminders (courses started but stalled)
      await this.sendCourseCompletionReminders();

      // 4. Weekly progress summary for active learners
      await this.sendWeeklyProgressSummary();
    } catch (error) {
      this.logger.error('Error in sendReminderEmailsInternal:', error);
      throw error;
    }
  }

  private async sendInactiveUserReminders(): Promise<void> {
    try {
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      // Find users who haven't logged in for 7 days
      const inactiveUsers = await this.userRepository
        .createQueryBuilder('user')
        .leftJoin('user.activities', 'activity')
        .where('user.lastLoginAt < :sevenDaysAgo OR user.lastLoginAt IS NULL', { sevenDaysAgo })
        .andWhere('user.isActive = true')
        .andWhere('user.email IS NOT NULL')
        .groupBy('user.id')
        .getMany();

      this.logger.log(`Found ${inactiveUsers.length} inactive users`);

      for (const user of inactiveUsers) {
        // Create notification first
        const notification = await this.notificationsService.create({
          userId: user.id,
          title: '¡Te extrañamos! Continúa tu aprendizaje',
          message: `Hola ${user.firstName || user.email}, te extrañamos. Vuelve a continuar tu aprendizaje. Tienes cursos esperándote.`,
          type: 'reminder' as any,
          data: {
            type: 'inactive_user_reminder',
            daysInactive: 7,
            loginUrl: `${process.env.FRONTEND_URL}/login`,
          },
        });

        // Send email using the notification
        await this.emailService.sendEmail(notification);
      }

      this.logger.log(`Sent inactive user reminders to ${inactiveUsers.length} users`);
    } catch (error) {
      this.logger.error('Error sending inactive user reminders:', error);
    }
  }

  private async sendIncompleteCoursesReminders(): Promise<void> {
    try {
      // Find users with enrollments but no recent progress
      const threeDaysAgo = new Date();
      threeDaysAgo.setDate(threeDaysAgo.getDate() - 3);

      const usersWithIncomplete = await this.enrollmentRepository
        .createQueryBuilder('enrollment')
        .leftJoinAndSelect('enrollment.user', 'user')
        .leftJoinAndSelect('enrollment.course', 'course')
        .leftJoin('enrollment.progress', 'progress')
        .where('enrollment.enrolledAt < :threeDaysAgo', { threeDaysAgo })
        .andWhere('(progress.id IS NULL OR progress.completedAt IS NULL)')
        .andWhere('user.isActive = true')
        .andWhere('user.email IS NOT NULL')
        .getMany();

      this.logger.log(`Found ${usersWithIncomplete.length} users with incomplete courses`);

      for (const enrollment of usersWithIncomplete) {
        const user = enrollment.user;
        const course = enrollment.course;

        const notification = await this.notificationsService.create({
          userId: user.id,
          title: `Continúa tu curso: ${course.title}`,
          message: `Hola ${user.firstName || user.email}, tienes el curso "${course.title}" pendiente. ¡Continúa tu progreso!`,
          type: 'reminder' as any,
          data: {
            courseId: course.id,
            courseTitle: course.title,
            enrolledDays: Math.floor(
              (Date.now() - enrollment.enrolledAt.getTime()) / (1000 * 60 * 60 * 24)
            ),
          },
        });

        await this.emailService.sendEmail(notification);
      }

      this.logger.log(`Sent incomplete course reminders to ${usersWithIncomplete.length} users`);
    } catch (error) {
      this.logger.error('Error sending incomplete course reminders:', error);
    }
  }

  private async sendCourseCompletionReminders(): Promise<void> {
    try {
      const oneWeekAgo = new Date();
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

      // Find users who started courses but haven't made progress in a week
      const stalledProgress = await this.progressRepository
        .createQueryBuilder('progress')
        .leftJoinAndSelect('progress.user', 'user')
        .leftJoinAndSelect('progress.course', 'course')
        .where('progress.updatedAt < :oneWeekAgo', { oneWeekAgo })
        .andWhere('progress.completedAt IS NULL')
        .andWhere('progress.completionPercentage > 0')
        .andWhere('progress.completionPercentage < 100')
        .andWhere('user.isActive = true')
        .andWhere('user.email IS NOT NULL')
        .getMany();

      this.logger.log(`Found ${stalledProgress.length} users with stalled progress`);

      for (const progress of stalledProgress) {
        const user = progress.user;
        const course = progress.course;

        const notification = await this.notificationsService.create({
          userId: user.id,
          title: `¡Estás cerca de completar "${course.title}"!`,
          message: `Has completado ${Math.round(Number(progress.completionPercentage))}% de "${course.title}". ¡Continúa y termínalo!`,
          type: 'reminder' as any,
          data: {
            courseId: course.id,
            courseTitle: course.title,
            progress: Number(progress.completionPercentage),
            lastActivity: progress.updatedAt.toLocaleDateString(),
          },
        });

        await this.emailService.sendEmail(notification);
      }

      this.logger.log(`Sent stalled progress reminders to ${stalledProgress.length} users`);
    } catch (error) {
      this.logger.error('Error sending course completion reminders:', error);
    }
  }

  private async sendWeeklyProgressSummary(): Promise<void> {
    try {
      const oneWeekAgo = new Date();
      oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

      // Find users who made progress in the last week
      const activeUsers = await this.progressRepository
        .createQueryBuilder('progress')
        .leftJoinAndSelect('progress.user', 'user')
        .leftJoinAndSelect('progress.course', 'course')
        .where('progress.updatedAt >= :oneWeekAgo', { oneWeekAgo })
        .andWhere('user.isActive = true')
        .andWhere('user.email IS NOT NULL')
        .groupBy('user.id')
        .getMany();

      this.logger.log(`Found ${activeUsers.length} active users for weekly summary`);

      for (const progress of activeUsers) {
        const user = progress.user;

        // Get user's weekly stats
        const weeklyStats = await this.getUserWeeklyStats(user.id, oneWeekAgo);

        if (weeklyStats.coursesStudied > 0) {
          const notification = await this.notificationsService.create({
            userId: user.id,
            title: '📊 Tu resumen semanal de aprendizaje',
            message: `Esta semana estudiaste ${weeklyStats.coursesStudied} cursos y completaste ${weeklyStats.lessonsCompleted} lecciones. ¡Excelente progreso!`,
            type: 'achievement' as any,
            data: weeklyStats,
          });

          await this.emailService.sendEmail(notification);
        }
      }

      this.logger.log(`Sent weekly summaries to ${activeUsers.length} active users`);
    } catch (error) {
      this.logger.error('Error sending weekly progress summaries:', error);
    }
  }

  private async getUserWeeklyStats(
    userId: string,
    startDate: Date
  ): Promise<{
    coursesStudied: number;
    lessonsCompleted: number;
    totalStudyTime: number;
    achievementsEarned: number;
    streakDays: number;
  }> {
    const coursesStudied = await this.progressRepository.count({
      where: {
        userId,
        updatedAt: Between(startDate, new Date()),
      },
    });

    // For now, return simple metrics - can be expanded with actual lesson tracking
    return {
      coursesStudied,
      lessonsCompleted: coursesStudied * 3, // Estimated
      totalStudyTime: coursesStudied * 45, // Estimated minutes
      achievementsEarned: coursesStudied > 2 ? 1 : 0,
      streakDays: coursesStudied > 0 ? 7 : 0,
    };
  }
}
