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
import { CommentsService } from '../services/comments.service';
import { CreateCommentDto } from '../dto/create-comment.dto';
import { UpdateCommentDto } from '../dto/update-comment.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { Public } from '../../auth/decorators/public.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { Comment } from '../entities/comment.entity';
import { User, UserRole } from '../../users/entities/user.entity';

@ApiTags('Comments')
@Controller('comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear un nuevo comentario' })
  @ApiResponse({
    status: 201,
    description: 'Comentario creado exitosamente',
    type: Comment,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  create(@Body() createCommentDto: CreateCommentDto, @CurrentUser() user: User) {
    return this.commentsService.create(createCommentDto, user.id);
  }

  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener todos los comentarios (solo admin)' })
  @ApiQuery({
    name: 'status',
    required: false,
    type: String,
    description: 'Filtrar por estado del comentario',
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
    description: 'Lista de todos los comentarios',
    type: [Comment],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  findAll(@Query('status') status?: string, @Query('page') page = 1, @Query('limit') limit = 10) {
    return this.commentsService.findAll({ status, page, limit });
  }

  @Get('course/:courseId')
  @Public()
  @ApiOperation({ summary: 'Obtener comentarios de un curso' })
  @ApiParam({
    name: 'courseId',
    type: 'number',
    description: 'ID del curso',
  })
  @ApiQuery({
    name: 'includeHidden',
    required: false,
    type: Boolean,
    description: 'Incluir comentarios ocultos (requiere permisos)',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de comentarios del curso',
    type: [Comment],
  })
  @ApiResponse({ status: 404, description: 'Curso no encontrado' })
  findByCourse(
    @Param('courseId', ParseUUIDPipe) courseId: string,
    @Query('includeHidden') includeHidden?: boolean
  ) {
    return this.commentsService.findByCourse(courseId, includeHidden);
  }

  @Get('lesson/:lessonId')
  @Public()
  @ApiOperation({ summary: 'Obtener comentarios de una lección' })
  @ApiParam({
    name: 'lessonId',
    type: 'number',
    description: 'ID de la lección',
  })
  @ApiQuery({
    name: 'includeHidden',
    required: false,
    type: Boolean,
    description: 'Incluir comentarios ocultos (requiere permisos)',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de comentarios de la lección',
    type: [Comment],
  })
  @ApiResponse({ status: 404, description: 'Lección no encontrada' })
  findByLesson(
    @Param('lessonId', ParseUUIDPipe) lessonId: string,
    @Query('includeHidden') includeHidden?: boolean
  ) {
    return this.commentsService.findByLesson(lessonId, includeHidden);
  }

  @Get('search')
  @Public()
  @ApiOperation({ summary: 'Buscar comentarios por texto' })
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
    name: 'lessonId',
    required: false,
    type: String,
    description: 'Filtrar por lección',
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
    description: 'Resultados de búsqueda de comentarios',
    schema: {
      type: 'object',
      properties: {
        comments: { type: 'array', items: { $ref: '#/components/schemas/Comment' } },
        total: { type: 'number' },
        page: { type: 'number' },
        limit: { type: 'number' },
      },
    },
  })
  searchComments(
    @Query('q') query: string,
    @Query('courseId') courseId?: string,
    @Query('lessonId') lessonId?: string,
    @Query('page') page = 1,
    @Query('limit') limit = 10
  ) {
    return this.commentsService.searchComments({ query, courseId, lessonId, page, limit });
  }

  @Get('stats')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Obtener estadísticas de comentarios' })
  @ApiQuery({
    name: 'courseId',
    required: false,
    type: Number,
    description: 'ID del curso para filtrar estadísticas',
  })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de comentarios',
    schema: {
      type: 'object',
      properties: {
        totalComments: { type: 'number' },
        approvedComments: { type: 'number' },
        pendingComments: { type: 'number' },
        averageCommentsPerLesson: { type: 'number' },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getCommentStats(@Query('courseId') courseId?: string) {
    return this.commentsService.getCommentStats(courseId);
  }

  @Get(':id')
  @Public()
  @ApiOperation({ summary: 'Obtener un comentario específico' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del comentario',
  })
  @ApiResponse({
    status: 200,
    description: 'Comentario encontrado',
    type: Comment,
  })
  @ApiResponse({ status: 404, description: 'Comentario no encontrado' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.commentsService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar un comentario' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del comentario',
  })
  @ApiResponse({
    status: 200,
    description: 'Comentario actualizado exitosamente',
    type: Comment,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Comentario no encontrado' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateCommentDto: UpdateCommentDto,
    @CurrentUser() user: any
  ) {
    return this.commentsService.update(id, updateCommentDto, user.id, user.role);
  }

  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Dar like a un comentario' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del comentario',
  })
  @ApiResponse({
    status: 200,
    description: 'Like agregado exitosamente',
    type: Comment,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 404, description: 'Comentario no encontrado' })
  likeComment(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: User) {
    return this.commentsService.likeComment(id, user.id);
  }

  @Post(':id/pin')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Fijar/desfijar un comentario' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del comentario',
  })
  @ApiResponse({
    status: 200,
    description: 'Comentario fijado/desfijado exitosamente',
    type: Comment,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Comentario no encontrado' })
  pinComment(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: User) {
    return this.commentsService.pinComment(id, user.id, user.role);
  }

  @Patch(':id/moderate')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Moderar un comentario' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del comentario',
  })
  @ApiResponse({
    status: 200,
    description: 'Comentario moderado exitosamente',
    type: Comment,
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Comentario no encontrado' })
  moderateComment(
    @Param('id', ParseUUIDPipe) id: string,
    @Body('status') status: string,
    @CurrentUser() user: any
  ) {
    return this.commentsService.moderateComment(id, status, user.id, user.role);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar un comentario' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID del comentario',
  })
  @ApiResponse({
    status: 200,
    description: 'Comentario eliminado exitosamente',
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Comentario no encontrado' })
  remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: User) {
    return this.commentsService.remove(id, user.id, user.role);
  }
}
