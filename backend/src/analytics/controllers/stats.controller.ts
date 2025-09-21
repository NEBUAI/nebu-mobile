import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { StatsService } from '../services/stats.service';

@ApiTags('stats')
@Controller('stats')
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get('overview')
  @ApiOperation({ summary: 'Obtener estadísticas generales de la academia' })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas obtenidas exitosamente',
    schema: {
      type: 'object',
      properties: {
        totalStudents: { type: 'number', description: 'Total de estudiantes' },
        totalCourses: { type: 'number', description: 'Total de cursos' },
        totalReviews: { type: 'number', description: 'Total de reseñas' },
        averageRating: { type: 'number', description: 'Calificación promedio' },
        totalHours: { type: 'number', description: 'Total de horas de contenido' },
        totalLessons: { type: 'number', description: 'Total de lecciones' },
      },
    },
  })
  async getOverview() {
    return this.statsService.getOverviewStats();
  }

  @Get('courses/popular')
  @ApiOperation({ summary: 'Obtener cursos más populares' })
  @ApiResponse({ status: 200, description: 'Cursos populares obtenidos exitosamente' })
  async getPopularCourses() {
    return this.statsService.getPopularCourses();
  }

  @Get('courses/featured')
  @ApiOperation({ summary: 'Obtener cursos destacados' })
  @ApiResponse({ status: 200, description: 'Cursos destacados obtenidos exitosamente' })
  async getFeaturedCourses() {
    return this.statsService.getFeaturedCourses();
  }

  @Get('performance')
  @ApiOperation({ summary: 'Obtener métricas de rendimiento de la plataforma en tiempo real' })
  @ApiResponse({
    status: 200,
    description: 'Métricas de rendimiento obtenidas exitosamente',
    schema: {
      type: 'object',
      properties: {
        platform: {
          type: 'object',
          properties: {
            uptime: { type: 'number', description: 'Tiempo de actividad en segundos' },
            memoryUsage: { type: 'object', description: 'Uso de memoria del sistema' },
            cpuUsage: { type: 'number', description: 'Uso de CPU en porcentaje' },
            activeConnections: { type: 'number', description: 'Conexiones activas' },
            responseTime: { type: 'number', description: 'Tiempo de respuesta promedio en ms' },
          },
        },
        database: {
          type: 'object',
          properties: {
            connectionPool: { type: 'object', description: 'Estado del pool de conexiones' },
            queryPerformance: {
              type: 'object',
              description: 'Métricas de rendimiento de consultas',
            },
            cacheHitRate: { type: 'number', description: 'Tasa de aciertos de caché' },
          },
        },
        business: {
          type: 'object',
          properties: {
            activeUsers: { type: 'number', description: 'Usuarios activos en la última hora' },
            newEnrollments: {
              type: 'number',
              description: 'Nuevas inscripciones en las últimas 24h',
            },
            courseCompletions: {
              type: 'number',
              description: 'Cursos completados en las últimas 24h',
            },
            revenue: { type: 'object', description: 'Métricas de ingresos' },
          },
        },
        timestamp: {
          type: 'string',
          format: 'date-time',
          description: 'Timestamp de las métricas',
        },
      },
    },
  })
  async getPerformanceMetrics() {
    return this.statsService.getPerformanceMetrics();
  }
}
