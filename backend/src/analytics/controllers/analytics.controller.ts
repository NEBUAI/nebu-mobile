import { Controller, Get, Post, Body, Query, UseGuards, ParseUUIDPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AnalyticsService } from '../services/analytics.service';
import { ReportsService } from '../services/reports.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { UserRole } from '../../users/entities/user.entity';
import { EventType } from '../entities/analytics-event.entity';
import { ActivityType } from '../entities/user-activity.entity';

@ApiTags('analytics')
@Controller('analytics')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AnalyticsController {
  constructor(
    private readonly analyticsService: AnalyticsService,
    private readonly reportsService: ReportsService
  ) {}

  @Post('track/event')
  @ApiOperation({ summary: 'Registrar evento de analytics' })
  @ApiResponse({ status: 201, description: 'Evento registrado exitosamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  trackEvent(
    @CurrentUser() user: any,
    @Body('eventType') eventType: EventType,
    @Body('properties') properties: Record<string, any> = {},
    @Body('sessionId') sessionId?: string,
    @Body('page') page?: string,
    @Body('referrer') referrer?: string,
    @Body('value') value?: number
  ) {
    return this.analyticsService.trackEvent(
      user?.id,
      eventType,
      properties,
      sessionId,
      page,
      referrer,
      undefined, // ipAddress
      undefined, // userAgent
      value
    );
  }

  @Post('track/activity')
  @ApiOperation({ summary: 'Registrar actividad de usuario' })
  @ApiResponse({ status: 201, description: 'Actividad registrada exitosamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  trackActivity(
    @CurrentUser() user: any,
    @Body('activityType') activityType: ActivityType,
    @Body('title') title: string,
    @Body('description') description?: string,
    @Body('courseId') courseId?: string,
    @Body('lessonId') lessonId?: string,
    @Body('metadata') metadata?: Record<string, any>,
    @Body('duration') duration?: number,
    @Body('score') score?: number,
    @Body('isCompleted') isCompleted = false
  ) {
    return this.analyticsService.trackActivity(
      user.id,
      activityType,
      title,
      description,
      courseId,
      lessonId,
      metadata,
      duration,
      score,
      isCompleted
    );
  }

  @Get('stats/events')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener estadísticas de eventos' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiQuery({ name: 'eventType', required: false, description: 'Tipo de evento' })
  @ApiResponse({ status: 200, description: 'Estadísticas obtenidas exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getEventStats(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('eventType') eventType?: EventType
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.analyticsService.getEventStats(start, end, eventType);
  }

  @Get('stats/user/:userId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener estadísticas de usuario' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiResponse({ status: 200, description: 'Estadísticas obtenidas exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getUserStats(
    @Query('userId', ParseUUIDPipe) userId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.analyticsService.getUserActivityStats(userId, start, end);
  }

  @Get('stats/my')
  @ApiOperation({ summary: 'Obtener mis estadísticas de actividad' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiResponse({ status: 200, description: 'Estadísticas obtenidas exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  getMyStats(
    @CurrentUser() user: any,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.analyticsService.getUserActivityStats(user.id, start, end);
  }

  @Get('stats/course/:courseId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener estadísticas de curso' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiResponse({ status: 200, description: 'Estadísticas obtenidas exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getCourseStats(
    @Query('courseId', ParseUUIDPipe) courseId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.analyticsService.getCourseAnalytics(courseId, start, end);
  }

  @Get('reports/dashboard')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Generar reporte de dashboard' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiResponse({ status: 200, description: 'Reporte generado exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getDashboardReport(@Query('startDate') startDate?: string, @Query('endDate') endDate?: string) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.reportsService.generateDashboardReport(start, end);
  }

  @Get('reports/user/:userId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Generar reporte de usuario' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiResponse({ status: 200, description: 'Reporte generado exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getUserReport(
    @Query('userId', ParseUUIDPipe) userId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.reportsService.generateUserReport(userId, start, end);
  }

  @Get('reports/course/:courseId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Generar reporte de curso' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiResponse({ status: 200, description: 'Reporte generado exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getCourseReport(
    @Query('courseId', ParseUUIDPipe) courseId: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.reportsService.generateCourseReport(courseId, start, end);
  }

  @Get('reports/export/dashboard')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Exportar reporte de dashboard a CSV' })
  @ApiQuery({ name: 'startDate', required: false, description: 'Fecha de inicio' })
  @ApiQuery({ name: 'endDate', required: false, description: 'Fecha de fin' })
  @ApiQuery({
    name: 'format',
    required: false,
    description: 'Formato de exportación (csv, json)',
  })
  @ApiResponse({ status: 200, description: 'Reporte exportado exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  exportDashboardReport(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('format') format = 'csv'
  ) {
    const start = startDate ? new Date(startDate) : undefined;
    const end = endDate ? new Date(endDate) : undefined;

    return this.reportsService.exportDashboardReport(start, end, format as 'csv' | 'json');
  }

  @Get('insights/trends')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener insights y tendencias' })
  @ApiQuery({
    name: 'period',
    required: false,
    description: 'Período de análisis (7d, 30d, 90d, 1y)',
  })
  @ApiQuery({ name: 'metric', required: false, description: 'Métrica específica a analizar' })
  @ApiResponse({ status: 200, description: 'Insights obtenidos exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getInsights(@Query('period') period = '30d', @Query('metric') metric?: string) {
    return this.analyticsService.getInsights(period, metric);
  }

  @Get('insights/predictions')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Obtener predicciones basadas en datos históricos' })
  @ApiQuery({
    name: 'horizon',
    required: false,
    description: 'Horizonte de predicción (7d, 30d, 90d)',
  })
  @ApiQuery({ name: 'metric', required: false, description: 'Métrica a predecir' })
  @ApiResponse({ status: 200, description: 'Predicciones obtenidas exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getPredictions(@Query('horizon') horizon = '30d', @Query('metric') metric?: string) {
    return this.analyticsService.getPredictions(horizon, metric);
  }

  @Get('real-time/active-users')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener usuarios activos en tiempo real' })
  @ApiResponse({ status: 200, description: 'Usuarios activos obtenidos exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getActiveUsers() {
    return this.analyticsService.getActiveUsers();
  }

  @Get('real-time/events')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener eventos en tiempo real' })
  @ApiQuery({ name: 'limit', required: false, description: 'Límite de eventos' })
  @ApiResponse({ status: 200, description: 'Eventos en tiempo real obtenidos exitosamente' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getRealTimeEvents(@Query('limit') limit = 50) {
    return this.analyticsService.getRealTimeEvents(limit);
  }
}
