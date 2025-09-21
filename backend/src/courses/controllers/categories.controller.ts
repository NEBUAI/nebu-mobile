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
import { CategoriesService } from '../services/categories.service';
import { CreateCategoryDto } from '../dto/create-category.dto';
import { UpdateCategoryDto } from '../dto/update-category.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { Public } from '../../auth/decorators/public.decorator';
import { Category } from '../entities/category.entity';
import { UserRole } from '../../users/entities/user.entity';

@ApiTags('Categories')
@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Crear una nueva categoría' })
  @ApiResponse({
    status: 201,
    description: 'Categoría creada exitosamente',
    type: Category,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  create(@Body() createCategoryDto: CreateCategoryDto) {
    return this.categoriesService.create(createCategoryDto);
  }

  @Get()
  @Public()
  @ApiOperation({ summary: 'Obtener todas las categorías' })
  @ApiQuery({
    name: 'active',
    required: false,
    type: Boolean,
    description: 'Filtrar solo categorías activas',
  })
  @ApiResponse({
    status: 200,
    description: 'Lista de categorías',
    type: [Category],
  })
  findAll(@Query('active') activeOnly?: boolean) {
    if (activeOnly === true) {
      return this.categoriesService.findAllActive();
    }
    return this.categoriesService.findAll();
  }

  @Get('hierarchy')
  @Public()
  @ApiOperation({ summary: 'Obtener jerarquía de categorías' })
  @ApiResponse({
    status: 200,
    description: 'Jerarquía de categorías con subcategorías',
    type: [Category],
  })
  getHierarchy() {
    return this.categoriesService.getHierarchy();
  }

  @Get(':id')
  @Public()
  @ApiOperation({ summary: 'Obtener una categoría por ID' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la categoría',
  })
  @ApiResponse({
    status: 200,
    description: 'Categoría encontrada',
    type: Category,
  })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.categoriesService.findOne(id);
  }

  @Get('slug/:slug')
  @Public()
  @ApiOperation({ summary: 'Obtener una categoría por slug' })
  @ApiParam({
    name: 'slug',
    type: 'string',
    description: 'Slug de la categoría',
  })
  @ApiResponse({
    status: 200,
    description: 'Categoría encontrada',
    type: Category,
  })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  findBySlug(@Param('slug') slug: string) {
    return this.categoriesService.findBySlug(slug);
  }

  @Get(':id/stats')
  @Public()
  @ApiOperation({ summary: 'Obtener estadísticas de una categoría' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la categoría',
  })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas de la categoría',
    schema: {
      type: 'object',
      properties: {
        coursesCount: { type: 'number', description: 'Número de cursos' },
        studentsCount: { type: 'number', description: 'Número de estudiantes' },
        avgRating: { type: 'number', description: 'Calificación promedio' },
      },
    },
  })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  getCategoryStats(@Param('id', ParseUUIDPipe) id: string) {
    return this.categoriesService.getCategoryStats(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Actualizar una categoría' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la categoría',
  })
  @ApiResponse({
    status: 200,
    description: 'Categoría actualizada exitosamente',
    type: Category,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  update(@Param('id', ParseUUIDPipe) id: string, @Body() updateCategoryDto: UpdateCategoryDto) {
    return this.categoriesService.update(id, updateCategoryDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Eliminar una categoría' })
  @ApiParam({
    name: 'id',
    type: 'number',
    description: 'ID de la categoría',
  })
  @ApiResponse({
    status: 200,
    description: 'Categoría eliminada exitosamente',
  })
  @ApiResponse({ status: 400, description: 'No se puede eliminar la categoría' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Categoría no encontrada' })
  remove(@Param('id', ParseUUIDPipe) id: string) {
    return this.categoriesService.remove(id);
  }
}
