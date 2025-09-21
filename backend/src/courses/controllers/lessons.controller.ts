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
  Put,
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
import { LessonsService } from '../services/lessons.service';
import { CreateLessonDto } from '../dto/create-lesson.dto';
import { UpdateLessonDto } from '../dto/update-lesson.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { Public } from '../../auth/decorators/public.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Lesson } from '../entities/lesson.entity';
import { UserRole } from '../../users/entities/user.entity';

@ApiTags('Lessons')
@Controller('lessons')
export class LessonsController {
  constructor(private readonly lessonsService: LessonsService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear una nueva lección' })
  @ApiResponse({
    status: 201,
    description: 'Lección creada exitosamente',
    type: Lesson,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  create(@Body() createLessonDto: CreateLessonDto, @CurrentUser() user: any) {
    return this.lessonsService.create(createLessonDto, user?.id);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener todas las lecciones (solo admin)' })
  @ApiQuery({
    name: 'search',
    required: false,
    type: String,
    description: 'Buscar por título o descripción',
  })
  @ApiQuery({
    name: 'type',
    required: false,
    type: String,
    description: 'Filtrar por tipo de lección',
  })
  @ApiQuery({
    name: 'status',
    required: false,
    type: String,
    description: 'Filtrar por estado',
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
    description: 'Lista de todas las lecciones',
    type: [Lesson],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  findAll(
    @Query('search') search?: string,
    @Query('type') type?: string,
    @Query('status') status?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.lessonsService.findAll({ search, type, status, page, limit });
  }

  @Get('course/:courseId')
  @Public()
  @ApiOperation({ summary: 'Obtener lecciones de un curso específico' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiQuery({
    name: 'includeUnpublished',
    required: false,
    type: Boolean,
    description: 'Incluir lecciones no publicadas (requiere permisos)',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de lecciones del curso',
    type: [Lesson],
  })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  findByCourse(
    @Param('courseId', ParseUUIDPipe) courseId: string,
    @Query('includeUnpublished') includeUnpublished?: boolean
  ) {
    return this.lessonsService.findByCourse(courseId, includeUnpublished);
  }

  @Get(':id')
  @Public()
  @ApiOperation({ summary: 'Obtener una lección por ID' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la lección',
  })
  @ApiResponse({
    status: 200,
    description: 'Lección encontrada',
    type: Lesson,
  })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.lessonsService.findOne(id);
  }

  @Get('course/:courseId/slug/:slug')
  @Public()
  @ApiOperation({ summary: 'Obtener una lección por slug dentro de un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiParam({
    name: 'slug',
    type: 'string',
    description: 'Slug de la lección',
  })
  @ApiResponse({
    status: 200,
    description: 'Lección encontrada',
    type: Lesson,
  })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  findBySlug(@Param('courseId', ParseUUIDPipe) courseId: string, @Param('slug') slug: string) {
    return this.lessonsService.findBySlug(courseId, slug);
  }

  @Get('search')
  @Public()
  @ApiOperation({ summary: 'Buscar lecciones por texto' })
  @ApiQuery({
    name: 'q',
    required: true,
    type: String,
    description: 'Término de búsqueda',
  })
  @ApiQuery({
    name: 'type',
    required: false,
    type: String,
    description: 'Filtrar por tipo de lección',
  })
  @ApiQuery({
    name: 'level',
    required: false,
    type: String,
    description: 'Filtrar por nivel',
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
    description: 'Resultados de búsqueda',
    schema: {
      type: 'object',
      properties: {
        lessons: { type: 'array', items: { $ref: '#/components/schemas/Lesson' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
      },
    },
  })
  searchLessons(
    @Query('q') query: string,
    @Query('type') type?: string,
    @Query('level') level?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.lessonsService.searchLessons({ query, type, level, page, limit });
  }

  @Get(':id/stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener estadísticas de una lección' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la lección',
  })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de la lección',
    schema: {
      type: 'object',
      properties: {
        completionRate: { type: 'number', description: 'Tasa de finalización (%)' },
        averageWatchTime: {
          type: 'number',
          description: 'Tiempo promedio de visualización (minutos)',
        },
        studentsCount: { type: 'number', description: 'Número de estudiantes' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  getLessonStats(@Param('id', ParseUUIDPipe) id: string) {
    return this.lessonsService.getLessonStats(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar una lección' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la lección',
  })
  @ApiResponse({
    status: 200,
    description: 'Lección actualizada exitosamente',
    type: Lesson,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateLessonDto: UpdateLessonDto,
    @CurrentUser() user: any
  ) {
    return this.lessonsService.update(id, updateLessonDto, user?.id);
  }

  @Put('course/:courseId/reorder')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Reordenar lecciones de un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        lessonIds: {
          type: 'array',
          items: { type: 'number' },
          description: 'Array de IDs de lecciones en el nuevo orden',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: 'Lecciones reordenadas exitosamente',
    type: [Lesson],
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  reorderLessons(
    @Param('courseId', ParseUUIDPipe) courseId: string,
    @Body('lessonIds') lessonIds: string[]
  ) {
    return this.lessonsService.reorderLessons(courseId, lessonIds);
  }

  @Post(':id/duplicate')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Duplicar una lección' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la lección a duplicar',
  })
  @ApiResponse({
    status: 201,
    description: 'Lección duplicada exitosamente',
    type: Lesson,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  duplicateLesson(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.lessonsService.duplicateLesson(id, user?.id);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar una lección' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la lección',
  })
  @ApiResponse({
    status: 200,
    description: 'Lección eliminada exitosamente',
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.lessonsService.remove(id, user?.id);
  }
}
