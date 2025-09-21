import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  ParseUUIDPipe,
  Query,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiQuery,
  ApiBody,
} from '@nestjs/swagger';
import { ProgressService } from '../services/progress.service';
import { CreateProgressDto, ProgressStatus } from '../dto/create-progress.dto';
import { UpdateProgressDto } from '../dto/update-progress.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Progress } from '../entities/progress.entity';
import { UserRole } from '../../users/entities/user.entity';

@ApiTags('Progress')
@Controller('progress')
@UseGuards(JwtAuthGuard)
export class ProgressController {
  constructor(private readonly progressService: ProgressService) {}

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear un nuevo registro de progreso' })
  @ApiResponse({
    status: 201,
    description: 'Progreso creado exitosamente',
    type: Progress,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  create(@Body() createProgressDto: CreateProgressDto) {
    return this.progressService.create(createProgressDto);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener todos los registros de progreso (solo admin)' })
  @ApiQuery({
    name: 'status',
    required: false,
    type: String,
    description: 'Filtrar por estado de progreso',
  })
  @ApiQuery({
    name: 'courseId',
    required: false,
    type: String,
    description: 'Filtrar por curso',
  })
  @ApiQuery({
    name: 'userId',
    required: false,
    type: String,
    description: 'Filtrar por usuario',
  })
  @ApiQuery({
    name: 'page',
    required: false,
    type: Number,
    description: 'Número de página',
  })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Elementos por página',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de todos los progresos',
    type: [Progress],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  findAll(
    @Query('status') status?: string,
    @Query('courseId') courseId?: string,
    @Query('userId') userId?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.progressService.findAll({ status, courseId, userId, page, limit });
  }

  @Get('my-progress')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener el progreso del usuario actual' })
  @ApiResponse({
    status: 200,
    description: 'Progreso del usuario',
    type: [Progress],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  getMyProgress(@CurrentUser() user: any) {
    return this.progressService.findByUser(user.id);
  }

  @Get('my-summary')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener resumen de progreso del usuario actual' })
  @ApiResponse({
    status: 200,
    description: 'Resumen de progreso del usuario',
    schema: {
      type: 'object',
      properties: {
        totalCourses: { type: 'number' },
        activeCourses: { type: 'number' },
        completedCourses: { type: 'number' },
        totalTimeSpent: { type: 'number' },
        averageScore: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  getMyProgressSummary(@CurrentUser() user: any) {
    return this.progressService.getUserProgressSummary(user.id);
  }

  @Get('user/:userId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener progreso de un usuario específico' })
  @ApiParam({
    name: 'userId',
    type: 'number',
    description: 'ID del usuario',
  })
  @ApiResponse({
    status: 200,
    description: 'Progreso del usuario',
    type: [Progress],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  findByUser(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.progressService.findByUser(userId);
  }

  @Get('course/:courseId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener progreso de todos los usuarios en un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiResponse({
    status: 200,
    description: 'Progreso del curso',
    type: [Progress],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  findByCourse(@Param('courseId', ParseUUIDPipe) courseId: string) {
    return this.progressService.findByCourse(courseId);
  }

  @Get('course/:courseId/overview')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener resumen de progreso de un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiResponse({
    status: 200,
    description: 'Resumen de progreso del curso',
    schema: {
      type: 'object',
      properties: {
        totalStudents: { type: 'number' },
        activeStudents: { type: 'number' },
        completedStudents: { type: 'number' },
        averageCompletionRate: { type: 'number' },
        averageTimeSpent: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  getCourseProgressOverview(@Param('courseId', ParseUUIDPipe) courseId: string) {
    return this.progressService.getCourseProgressOverview(courseId);
  }

  @Get('my-course/:courseId')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener mi progreso en un curso específico' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiResponse({
    status: 200,
    description: 'Progreso del usuario en el curso',
    type: [Progress],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  getMyProgressInCourse(
    @Param('courseId', ParseUUIDPipe) courseId: string,
    @CurrentUser() user: any
  ) {
    return this.progressService.findUserCourseProgress(user.id, courseId);
  }

  @Get('my-course/:courseId/stats')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener estadísticas de mi progreso en un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de progreso del usuario en el curso',
    schema: {
      type: 'object',
      properties: {
        totalLessons: { type: 'number' },
        completedLessons: { type: 'number' },
        completionPercentage: { type: 'number' },
        totalTimeSpent: { type: 'number' },
        averageScore: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  getMyStatsInCourse(@Param('courseId', ParseUUIDPipe) courseId: string, @CurrentUser() user: any) {
    return this.progressService.getUserCourseStats(user.id, courseId);
  }

  @Get(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener un registro de progreso específico' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del progreso',
  })
  @ApiResponse({
    status: 200,
    description: 'Progreso encontrado',
    type: Progress,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Progreso no encontrado' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.progressService.findOne(id);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar un registro de progreso' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del progreso',
  })
  @ApiResponse({
    status: 200,
    description: 'Progreso actualizado exitosamente',
    type: Progress,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Progreso no encontrado' })
  update(@Param('id', ParseUUIDPipe) id: string, @Body() updateProgressDto: UpdateProgressDto) {
    return this.progressService.update(id, updateProgressDto);
  }

  @Post('track')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Registrar o actualizar progreso de una lección' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        courseId: { type: 'string', description: 'ID del curso' },
        lessonId: { type: 'string', description: 'ID de la lección' },
        progress: { type: 'number', description: 'Porcentaje de progreso (0-100)' },
        timeSpent: { type: 'number', description: 'Tiempo invertido en minutos' },
        watchTime: { type: 'number', description: 'Tiempo de visualización en minutos' },
        status: { type: 'string', description: 'Estado del progreso' },
      },
      required: ['courseId', 'lessonId'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Progreso registrado exitosamente',
    type: Progress,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  trackProgress(
    @CurrentUser() user: any,
    @Body('courseId') courseId: string,
    @Body('lessonId') lessonId: string,
    @Body('progress') progress?: number,
    @Body('timeSpent') timeSpent?: number,
    @Body('watchTime') watchTime?: number,
    @Body('status') status?: ProgressStatus
  ) {
    return this.progressService.updateOrCreate(user.id, courseId, lessonId, {
      progress,
      timeSpent,
      watchTime,
      status,
    });
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar un registro de progreso (solo admin)' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del progreso',
  })
  @ApiResponse({
    status: 200,
    description: 'Progreso eliminado exitosamente',
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Progreso no encontrado' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.progressService.remove(id);
  }
}
