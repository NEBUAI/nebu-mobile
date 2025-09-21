import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { UserRole } from '../../users/entities/user.entity';
import { CourseStatus } from '../entities/course.entity';
import { CoursesService } from '../services/courses.service';
import { StripeSyncService } from '../services/stripe-sync.service';
import { CreateCourseDto } from '../dto/create-course.dto';
import { UpdateCourseDto } from '../dto/update-course.dto';

@ApiTags('Courses')
@Controller('courses')
export class CoursesController {
  constructor(
    private readonly coursesService: CoursesService,
    private readonly stripeSyncService: StripeSyncService,
  ) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Crear un nuevo curso' })
  @ApiResponse({ status: 201, description: 'Curso creado exitosamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 403, description: 'No autorizado' })
  create(@Body() createCourseDto: CreateCourseDto, @CurrentUser() user: any) {
    return this.coursesService.create(createCourseDto, user.id);
  }

  @Get()
  @ApiOperation({ summary: 'Obtener todos los cursos' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'category', required: false, type: String })
  @ApiQuery({ name: 'level', required: false, type: String })
  @ApiQuery({ name: 'status', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Lista de cursos obtenida exitosamente' })
  async findAll(
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('category') category?: string,
    @Query('level') level?: string,
    @Query('status') status?: CourseStatus
  ) {
    const result = await this.coursesService.findAll({
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
      search,
      category,
      level,
      status,
    });

    return {
      data: result.courses,
      total: result.total,
      page: page ? parseInt(page, 10) : 1,
      limit: limit ? parseInt(limit, 10) : 12,
    };
  }

  @Get('featured')
  @ApiOperation({ summary: 'Obtener cursos destacados' })
  @ApiResponse({ status: 200, description: 'Cursos destacados obtenidos exitosamente' })
  async findFeatured() {
    return this.coursesService.findFeatured();
  }

  @Get('popular')
  @ApiOperation({ summary: 'Obtener cursos populares' })
  @ApiResponse({ status: 200, description: 'Cursos populares obtenidos exitosamente' })
  async findPopular() {
    const result = await this.coursesService.findAll({
      page: 1,
      limit: 10,
      status: CourseStatus.PUBLISHED,
    });
    return result.courses;
  }

  @Get('top')
  @ApiOperation({ summary: 'Obtener cursos más populares' })
  @ApiResponse({ status: 200, description: 'Top cursos obtenidos exitosamente' })
  @ApiQuery({
    name: 'limit',
    required: false,
    type: Number,
    description: 'Número de cursos a obtener (default: 6)',
  })
  async findTopCourses(@Query('limit') limit?: number) {
    return this.coursesService.findTopCourses(limit || 6);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un curso por ID' })
  @ApiResponse({ status: 200, description: 'Curso encontrado exitosamente' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.coursesService.findOne(id);
  }

  @Get('slug/:slug')
  @ApiOperation({ summary: 'Obtener un curso por slug' })
  @ApiResponse({ status: 200, description: 'Curso encontrado exitosamente' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  findBySlug(@Param('slug') slug: string) {
    return this.coursesService.findBySlug(slug);
  }

  @Patch(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Actualizar un curso' })
  @ApiResponse({ status: 200, description: 'Curso actualizado exitosamente' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  @ApiResponse({ status: 403, description: 'No autorizado' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateCourseDto: UpdateCourseDto,
    @CurrentUser() user: any
  ) {
    return this.coursesService.update(id, updateCourseDto, user);
  }

  @Delete(':id')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Eliminar un curso' })
  @ApiResponse({ status: 200, description: 'Curso eliminado exitosamente' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  @ApiResponse({ status: 403, description: 'No autorizado' })
  remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.coursesService.remove(id, user);
  }

  @Post(':id/publish')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Publicar un curso' })
  @ApiResponse({ status: 200, description: 'Curso publicado exitosamente' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  @ApiResponse({ status: 403, description: 'No autorizado' })
  publish(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.coursesService.publish(id, user);
  }

  @Post(':id/unpublish')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Despublicar un curso' })
  @ApiResponse({ status: 200, description: 'Curso despublicado exitosamente' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  @ApiResponse({ status: 403, description: 'No autorizado' })
  unpublish(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.coursesService.unpublish(id, user);
  }

  @Get(':id/access')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Verificar acceso del usuario a un curso' })
  @ApiResponse({
    status: 200,
    description: 'Estado de acceso verificado',
    schema: {
      type: 'object',
      properties: {
        hasAccess: { type: 'boolean' },
        reason: { type: 'string' },
        expiresAt: { type: 'string', format: 'date-time' },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  async checkAccess(@Param('id', ParseUUIDPipe) courseId: string, @CurrentUser() user: any) {
    const result = await this.coursesService.checkUserAccess(courseId, user.id);
    return {
      hasAccess: result.hasAccess,
      reason: result.reason,
      expiresAt: result.expiresAt,
    };
  }

  // ===== STRIPE INTEGRATION ENDPOINTS =====

  @Post(':id/sync-stripe')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Sincronizar curso con Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Curso sincronizado con Stripe exitosamente',
    schema: {
      type: 'object',
      properties: {
        course: { type: 'object' },
        stripeProduct: { type: 'object' },
        stripePrice: { type: 'object', nullable: true },
      },
    },
  })
  @ApiResponse({ status: 400, description: 'Error en la sincronización' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  async syncWithStripe(@Param('id', ParseUUIDPipe) courseId: string) {
    return await this.stripeSyncService.syncCourseWithStripe(courseId);
  }

  @Patch(':id/update-stripe')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar producto de Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Producto de Stripe actualizado exitosamente',
  })
  @ApiResponse({ status: 400, description: 'Error en la actualización' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  async updateStripeProduct(@Param('id', ParseUUIDPipe) courseId: string) {
    return await this.stripeSyncService.updateStripeProduct(courseId);
  }

  @Delete(':id/disable-stripe')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Deshabilitar integración con Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Integración con Stripe deshabilitada exitosamente',
  })
  @ApiResponse({ status: 400, description: 'Error al deshabilitar integración' })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  async disableStripeIntegration(@Param('id', ParseUUIDPipe) courseId: string) {
    return await this.stripeSyncService.disableStripeIntegration(courseId);
  }

  @Get('stripe-enabled')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener cursos con integración de Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Cursos con integración de Stripe obtenidos exitosamente',
  })
  async getCoursesWithStripe() {
    return await this.stripeSyncService.getCoursesWithStripe();
  }

  @Post('bulk-sync-stripe')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Sincronizar múltiples cursos con Stripe' })
  @ApiResponse({
    status: 200,
    description: 'Sincronización masiva completada',
    schema: {
      type: 'object',
      properties: {
        successful: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              courseId: { type: 'string' },
              stripeProductId: { type: 'string' },
            },
          },
        },
        failed: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              courseId: { type: 'string' },
              error: { type: 'string' },
            },
          },
        },
      },
    },
  })
  async bulkSyncWithStripe(@Body() body: { courseIds: string[] }) {
    return await this.stripeSyncService.syncMultipleCourses(body.courseIds);
  }
}
