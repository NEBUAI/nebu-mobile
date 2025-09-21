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
} from '@nestjs/swagger';
import { ReviewsService } from '../services/reviews.service';
import { CreateReviewDto } from '../dto/create-review.dto';
import { UpdateReviewDto } from '../dto/update-review.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { Public } from '../../auth/decorators/public.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Review } from '../entities/review.entity';
import { UserRole } from '../../users/entities/user.entity';

@ApiTags('Reviews')
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear una nueva reseña' })
  @ApiResponse({
    status: 201,
    description: 'Reseña creada exitosamente',
    type: Review,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos o reseña duplicada' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  create(@Body() createReviewDto: CreateReviewDto, @CurrentUser() user: any) {
    return this.reviewsService.create(createReviewDto, user.id);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener todas las reseñas (solo admin)' })
  @ApiQuery({
    name: 'status',
    required: false,
    type: String,
    description: 'Filtrar por estado de la reseña',
  })
  @ApiQuery({
    name: 'rating',
    required: false,
    type: Number,
    description: 'Filtrar por calificación',
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
    description: 'Lista de todas las reseñas',
    type: [Review],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  findAll(
    @Query('status') status?: string,
    @Query('rating') rating?: number,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.reviewsService.findAll({ status, rating, page, limit });
  }

  @Get('my-reviews')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener mis reseñas' })
  @ApiResponse({
    status: 200,
    description: 'Lista de reseñas del usuario',
    type: [Review],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  getMyReviews(@CurrentUser() user: any) {
    return this.reviewsService.findByUser(user.id);
  }

  @Get('course/:courseId')
  @Public()
  @ApiOperation({ summary: 'Obtener reseñas de un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiQuery({
    name: 'includeHidden',
    required: false,
    type: Boolean,
    description: 'Incluir reseñas ocultas (requiere permisos)',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de reseñas del curso',
    type: [Review],
  })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  findByCourse(
    @Param('courseId', ParseUUIDPipe) courseId: string,
    @Query('includeHidden') includeHidden?: boolean
  ) {
    return this.reviewsService.findByCourse(courseId, includeHidden);
  }

  @Get('course/:courseId/stats')
  @Public()
  @ApiOperation({ summary: 'Obtener estadísticas de reseñas de un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de reseñas del curso',
    schema: {
      type: 'object',
      properties: {
        totalReviews: { type: 'number' },
        averageRating: { type: 'number' },
        ratingDistribution: {
          type: 'object',
          properties: {
            1: { type: 'number' },
            2: { type: 'number' },
            3: { type: 'number' },
            4: { type: 'number' },
            5: { type: 'number' },
          },
        },
        verifiedPurchases: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  getCourseReviewStats(@Param('courseId', ParseUUIDPipe) courseId: string) {
    return this.reviewsService.getCourseReviewStats(courseId);
  }

  @Get('search')
  @Public()
  @ApiOperation({ summary: 'Buscar reseñas por texto' })
  @ApiQuery({
    name: 'q',
    required: true,
    type: String,
    description: 'Término de búsqueda',
  })
  @ApiQuery({
    name: 'courseId',
    required: false,
    type: String,
    description: 'Filtrar por curso',
  })
  @ApiQuery({
    name: 'rating',
    required: false,
    type: Number,
    description: 'Filtrar por calificación',
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
    description: 'Resultados de búsqueda de reseñas',
    schema: {
      type: 'object',
      properties: {
        reviews: { type: 'array', items: { $ref: '#/components/schemas/Review' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
      },
    },
  })
  searchReviews(
    @Query('q') query: string,
    @Query('courseId') courseId?: string,
    @Query('rating') rating?: number,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.reviewsService.searchReviews({ query, courseId, rating, page, limit });
  }

  @Get('stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener estadísticas generales de reseñas' })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas generales de reseñas',
    schema: {
      type: 'object',
      properties: {
        totalReviews: { type: 'number' },
        approvedReviews: { type: 'number' },
        pendingReviews: { type: 'number' },
        averageRating: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getReviewStats() {
    return this.reviewsService.getReviewStats();
  }

  @Get('user/:userId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener reseñas de un usuario específico' })
  @ApiParam({
    name: 'userId',
    type: 'number',
    description: 'ID del usuario',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de reseñas del usuario',
    type: [Review],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Usuario no encontrado' })
  findByUser(@Param('userId', ParseUUIDPipe) userId: string) {
    return this.reviewsService.findByUser(userId);
  }

  @Get(':id')
  @Public()
  @ApiOperation({ summary: 'Obtener una reseña específica' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la reseña',
  })
  @ApiResponse({
    status: 200,
    description: 'Reseña encontrada',
    type: Review,
  })
  @ApiResponse({ status: 404, description: 'Reseña no encontrada' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.reviewsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar una reseña' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la reseña',
  })
  @ApiResponse({
    status: 200,
    description: 'Reseña actualizada exitosamente',
    type: Review,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Reseña no encontrada' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateReviewDto: UpdateReviewDto,
    @CurrentUser() user: any
  ) {
    return this.reviewsService.update(id, updateReviewDto, user.id, user.role);
  }

  @Patch(':id/moderate')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Moderar una reseña' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la reseña',
  })
  @ApiResponse({
    status: 200,
    description: 'Reseña moderada exitosamente',
    type: Review,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Reseña no encontrada' })
  moderateReview(
    @Param('id', ParseUUIDPipe) id: string,
    @Body('status') status: string,
    @CurrentUser() user: any
  ) {
    return this.reviewsService.moderateReview(id, status, user.id, user.role);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar una reseña' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la reseña',
  })
  @ApiResponse({
    status: 200,
    description: 'Reseña eliminada exitosamente',
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Reseña no encontrada' })
  remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.reviewsService.remove(id, user.id, user.role);
  }
}
