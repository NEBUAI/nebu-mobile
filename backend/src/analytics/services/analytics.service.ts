import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, Not } from 'typeorm';
import { AnalyticsEvent, EventType } from '../entities/analytics-event.entity';
import { UserActivity, ActivityType } from '../entities/user-activity.entity';

@Injectable()
export class AnalyticsService {
  constructor(
    @InjectRepository(AnalyticsEvent)
    private eventRepository: Repository<AnalyticsEvent>,
    @InjectRepository(UserActivity)
    private activityRepository: Repository<UserActivity>
  ) {}

  async trackEvent(
    userId: string | null,
    eventType: EventType,
    properties: Record<string, string | number | boolean> = {},
    sessionId?: string,
    page?: string,
    referrer?: string,
    ipAddress?: string,
    userAgent?: string,
    value?: number
  ): Promise<AnalyticsEvent> {
    const event = this.eventRepository.create({
      userId,
      eventType,
      sessionId,
      page,
      referrer,
      ipAddress,
      userAgent,
      properties: JSON.stringify(properties),
      value,
    });

    return this.eventRepository.save(event);
  }

  async trackActivity(
    userId: string,
    activityType: ActivityType,
    title: string,
    description?: string,
    courseId?: string,
    lessonId?: string,
    metadata?: Record<string, string | number | boolean>,
    duration?: number,
    score?: number,
    isCompleted = false
  ): Promise<UserActivity> {
    const activity = this.activityRepository.create({
      userId,
      activityType,
      title,
      description,
      courseId,
      lessonId,
      metadata: metadata ? JSON.stringify(metadata) : null,
      duration,
      score,
      isCompleted,
    });

    return this.activityRepository.save(activity);
  }

  async getEventStats(
    startDate?: Date,
    endDate?: Date,
    eventType?: EventType
  ): Promise<{
    totalEvents: number;
    uniqueUsers: number;
    eventsByType: Array<{ type: EventType; count: number }>;
    eventsByDay: Array<{ date: string; count: number }>;
  }> {
    const whereConditions: Record<string, unknown> = {};

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    if (eventType) {
      whereConditions.eventType = eventType;
    }

    const [totalEvents, uniqueUsers, eventsByType, eventsByDay] = await Promise.all([
      this.eventRepository.count({ where: whereConditions }),
      this.eventRepository
        .createQueryBuilder('event')
        .select('COUNT(DISTINCT event.userId)', 'count')
        .where(whereConditions)
        .getRawOne()
        .then(result => parseInt(result.count) || 0),
      this.getEventsByType(whereConditions),
      this.getEventsByDay(whereConditions),
    ]);

    return {
      totalEvents,
      uniqueUsers,
      eventsByType,
      eventsByDay,
    };
  }

  async getUserActivityStats(
    userId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    totalActivities: number;
    completedActivities: number;
    totalDuration: number;
    activitiesByType: Array<{ type: ActivityType; count: number }>;
    recentActivities: UserActivity[];
  }> {
    const whereConditions: Record<string, unknown> = { userId };

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    const [
      totalActivities,
      completedActivities,
      totalDuration,
      activitiesByType,
      recentActivities,
    ] = await Promise.all([
      this.activityRepository.count({ where: whereConditions }),
      this.activityRepository.count({ where: { ...whereConditions, isCompleted: true } }),
      this.activityRepository
        .createQueryBuilder('activity')
        .select('SUM(activity.duration)', 'total')
        .where(whereConditions)
        .getRawOne()
        .then(result => parseInt(result.total) || 0),
      this.getActivitiesByType(whereConditions),
      this.activityRepository.find({
        where: whereConditions,
        relations: ['course', 'lesson'],
        order: { createdAt: 'DESC' },
        take: 10,
      }),
    ]);

    return {
      totalActivities,
      completedActivities,
      totalDuration,
      activitiesByType,
      recentActivities,
    };
  }

  async getCourseAnalytics(
    courseId: string,
    startDate?: Date,
    endDate?: Date
  ): Promise<{
    enrollments: number;
    completions: number;
    averageScore: number;
    averageDuration: number;
    engagementRate: number;
    activitiesByType: Array<{ type: ActivityType; count: number }>;
  }> {
    const whereConditions: Record<string, unknown> = { courseId };

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    const [enrollments, completions, averageScore, averageDuration, activitiesByType] =
      await Promise.all([
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
        this.getActivitiesByType(whereConditions),
      ]);

    const engagementRate = enrollments > 0 ? (completions / enrollments) * 100 : 0;

    return {
      enrollments,
      completions,
      averageScore,
      averageDuration,
      engagementRate,
      activitiesByType,
    };
  }

  private async getEventsByType(
    whereConditions: Record<string, unknown>
  ): Promise<Array<{ type: EventType; count: number }>> {
    const results = await this.eventRepository
      .createQueryBuilder('event')
      .select('event.eventType', 'type')
      .addSelect('COUNT(*)', 'count')
      .where(whereConditions)
      .groupBy('event.eventType')
      .getRawMany();

    return results.map(({ type, count }) => ({
      type: type as EventType,
      count: parseInt(count),
    }));
  }

  private async getEventsByDay(
    whereConditions: Record<string, unknown>
  ): Promise<Array<{ date: string; count: number }>> {
    const results = await this.eventRepository
      .createQueryBuilder('event')
      .select('DATE(event.createdAt)', 'date')
      .addSelect('COUNT(*)', 'count')
      .where(whereConditions)
      .groupBy('DATE(event.createdAt)')
      .orderBy('date', 'ASC')
      .getRawMany();

    return results.map(({ date, count }) => ({
      date,
      count: parseInt(count),
    }));
  }

  private async getActivitiesByType(
    whereConditions: Record<string, unknown>
  ): Promise<Array<{ type: ActivityType; count: number }>> {
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

  async getInsights(
    period: string,
    metric?: string
  ): Promise<{
    trends: Array<{ date: string; count: number; change: number }>;
    insights: Array<{ type: string; message: string; impact: 'positive' | 'negative' | 'neutral' }>;
    recommendations: Array<{ action: string; priority: 'high' | 'medium' | 'low' }>;
  }> {
    const days = this.parsePeriod(period);
    const endDate = new Date();
    const startDate = new Date(endDate.getTime() - days * 24 * 60 * 60 * 1000);

    // Obtener datos históricos para análisis de tendencias
    const trends = await this.getTrendData(startDate, endDate, metric);

    // Generar insights basados en los datos
    const insights = await this.generateInsights(trends, metric);

    // Generar recomendaciones
    const recommendations = await this.generateRecommendations(insights);

    return {
      trends,
      insights,
      recommendations,
    };
  }

  async getPredictions(
    horizon: string,
    metric?: string
  ): Promise<{
    predictions: Array<{ date: string; predicted: number; confidence: number }>;
    accuracy: number;
    factors: Array<{ factor: string; impact: number }>;
  }> {
    const days = this.parsePeriod(horizon);

    // Implementación simplificada de predicciones
    // En un sistema real, usarías algoritmos de ML como ARIMA, Prophet, etc.
    const predictions = await this.generatePredictions(days, metric);
    const accuracy = 0.85; // Simulado
    const factors = await this.getPredictionFactors(metric);

    return {
      predictions,
      accuracy,
      factors,
    };
  }

  async getActiveUsers(): Promise<{
    total: number;
    byCourse: Array<{ courseId: string; count: number }>;
    byActivity: Array<{ activity: string; count: number }>;
    lastUpdated: Date;
  }> {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const [total, byCourse, byActivity] = await Promise.all([
      this.activityRepository
        .createQueryBuilder('activity')
        .select('COUNT(DISTINCT activity.userId)', 'count')
        .where('activity.createdAt >= :date', { date: fiveMinutesAgo })
        .getRawOne()
        .then(result => parseInt(result.count) || 0),
      this.getActiveUsersByCourse(fiveMinutesAgo),
      this.getActiveUsersByActivity(fiveMinutesAgo),
    ]);

    return {
      total,
      byCourse,
      byActivity,
      lastUpdated: new Date(),
    };
  }

  async getRealTimeEvents(limit: number): Promise<{
    events: Array<{
      id: string;
      type: string;
      userId: string;
      timestamp: Date;
      data: Record<string, unknown>;
    }>;
    total: number;
  }> {
    const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

    const [events, total] = await Promise.all([
      this.eventRepository.find({
        where: { createdAt: Between(fiveMinutesAgo, new Date()) },
        order: { createdAt: 'DESC' },
        take: limit,
        relations: ['user'],
      }),
      this.eventRepository.count({
        where: { createdAt: Between(fiveMinutesAgo, new Date()) },
      }),
    ]);

    return {
      events: events.map(event => ({
        id: event.id,
        type: event.eventType,
        userId: event.userId || 'anonymous',
        timestamp: event.createdAt,
        data: event.properties ? JSON.parse(event.properties) : {},
      })),
      total,
    };
  }

  private parsePeriod(period: string): number {
    const periodMap: { [key: string]: number } = {
      '7d': 7,
      '30d': 30,
      '90d': 90,
      '1y': 365,
    };
    return periodMap[period] || 30;
  }

  private async getTrendData(
    startDate: Date,
    endDate: Date,
    _metric?: string
  ): Promise<Array<{ date: string; count: number; change: number }>> {
    // Implementación simplificada - en producción usarías análisis más sofisticados
    const results = await this.eventRepository
      .createQueryBuilder('event')
      .select('DATE(event.createdAt)', 'date')
      .addSelect('COUNT(*)', 'value')
      .where('event.createdAt BETWEEN :start AND :end', { start: startDate, end: endDate })
      .groupBy('DATE(event.createdAt)')
      .orderBy('date', 'ASC')
      .getRawMany();

    return results.map((result, index) => ({
      date: result.date,
      count: parseInt(result.value),
      change: index > 0 ? parseInt(result.value) - parseInt(results[index - 1].value) : 0,
    }));
  }

  private async generateInsights(
    trends: Array<{ date: string; count: number }>,
    _metric?: string
  ): Promise<
    Array<{ type: string; message: string; impact: 'positive' | 'negative' | 'neutral' }>
  > {
    // Implementación simplificada de generación de insights
    const insights = [];

    if (trends.length > 1) {
      const latest = trends[trends.length - 1];
      const previous = trends[trends.length - 2];
      const change = ((latest.count - previous.count) / previous.count) * 100;

      if (change > 0) {
        insights.push({
          type: 'growth',
          message: `Aumento del ${Math.abs(change).toFixed(1)}% en la actividad`,
          impact: 'positive' as const,
        });
      } else if (change < 0) {
        insights.push({
          type: 'decline',
          message: `Disminución del ${Math.abs(change).toFixed(1)}% en la actividad`,
          impact: 'negative' as const,
        });
      }
    }

    return insights;
  }

  private async generateRecommendations(
    insights: Array<{ type: string; message: string; impact: 'positive' | 'negative' | 'neutral' }>
  ): Promise<Array<{ action: string; priority: 'high' | 'medium' | 'low' }>> {
    const recommendations = [];

    insights.forEach(insight => {
      if (insight.impact === 'negative') {
        recommendations.push({
          action: 'Revisar estrategia de engagement',
          priority: 'high' as const,
        });
      } else if (insight.impact === 'positive') {
        recommendations.push({
          action: 'Mantener estrategia actual',
          priority: 'low' as const,
        });
      }
    });

    return recommendations;
  }

  private async generatePredictions(
    days: number,
    _metric?: string
  ): Promise<Array<{ date: string; predicted: number; confidence: number }>> {
    // Implementación simplificada de predicciones
    const predictions = [];
    const today = new Date();

    for (let i = 1; i <= days; i++) {
      const futureDate = new Date(today.getTime() + i * 24 * 60 * 60 * 1000);
      predictions.push({
        date: futureDate.toISOString().split('T')[0],
        predicted: Math.floor(Math.random() * 100) + 50, // Simulado
        confidence: Math.random() * 0.3 + 0.7, // 70-100%
      });
    }

    return predictions;
  }

  private async getPredictionFactors(
    _metric?: string
  ): Promise<Array<{ factor: string; impact: number }>> {
    // Factores que influyen en las predicciones
    return [
      { factor: 'Temporada académica', impact: 0.8 },
      { factor: 'Marketing activo', impact: 0.6 },
      { factor: 'Calidad del contenido', impact: 0.9 },
      { factor: 'Precio competitivo', impact: 0.7 },
    ];
  }

  private async getActiveUsersByCourse(
    since: Date
  ): Promise<Array<{ courseId: string; count: number }>> {
    const results = await this.activityRepository
      .createQueryBuilder('activity')
      .select('activity.courseId', 'courseId')
      .addSelect('COUNT(DISTINCT activity.userId)', 'count')
      .where('activity.createdAt >= :date AND activity.courseId IS NOT NULL', { date: since })
      .groupBy('activity.courseId')
      .getRawMany();

    return results.map(({ courseId, count }) => ({
      courseId,
      count: parseInt(count),
    }));
  }

  private async getActiveUsersByActivity(
    since: Date
  ): Promise<Array<{ activity: string; count: number }>> {
    const results = await this.activityRepository
      .createQueryBuilder('activity')
      .select('activity.activityType', 'activity')
      .addSelect('COUNT(DISTINCT activity.userId)', 'count')
      .where('activity.createdAt >= :date', { date: since })
      .groupBy('activity.activityType')
      .getRawMany();

    return results.map(({ activity, count }) => ({
      activity,
      count: parseInt(count),
    }));
  }
}
