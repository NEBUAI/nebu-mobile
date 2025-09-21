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
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { UserProgressService } from '../services/user-progress.service';
import { CreateUserProgressDto } from '../dto/create-user-progress.dto';
import { UpdateUserProgressDto } from '../dto/update-user-progress.dto';

@ApiTags('User Progress')
@Controller('progress')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UserProgressController {
  constructor(private readonly userProgressService: UserProgressService) {}

  @Post()
  @ApiOperation({ summary: 'Crear o actualizar progreso del usuario' })
  @ApiResponse({ status: 201, description: 'Progreso creado/actualizado exitosamente' })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  create(@Body() createUserProgressDto: CreateUserProgressDto, @CurrentUser() user: any) {
    return this.userProgressService.createOrUpdate({
      ...createUserProgressDto,
      userId: user.id,
    });
  }

  @Get('user/:userId')
  @ApiOperation({ summary: 'Obtener progreso del usuario' })
  @ApiQuery({ name: 'courseId', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Progreso del usuario obtenido exitosamente' })
  findByUser(
    @Param('userId', ParseUUIDPipe) userId: string,
    @CurrentUser() user: any,
    @Query('courseId') courseId?: string
  ) {
    // Solo permitir que el usuario vea su propio progreso
    if (user.id !== userId) {
      throw new Error('No autorizado para ver este progreso');
    }
    return this.userProgressService.findByUser(userId, courseId);
  }

  @Get('course/:courseId')
  @ApiOperation({ summary: 'Obtener progreso del usuario en un curso específico' })
  @ApiResponse({ status: 200, description: 'Progreso del curso obtenido exitosamente' })
  findByCourse(@Param('courseId', ParseUUIDPipe) courseId: string, @CurrentUser() user: any) {
    return this.userProgressService.findByUserAndCourse(user.id, courseId);
  }

  @Get('my')
  @ApiOperation({ summary: 'Obtener mi progreso' })
  @ApiQuery({ name: 'courseId', required: false, type: String })
  @ApiResponse({ status: 200, description: 'Mi progreso obtenido exitosamente' })
  findMyProgress(@CurrentUser() user: any, @Query('courseId') courseId?: string) {
    return this.userProgressService.findByUser(user.id, courseId);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Actualizar progreso del usuario' })
  @ApiResponse({ status: 200, description: 'Progreso actualizado exitosamente' })
  @ApiResponse({ status: 404, description: 'Progreso no encontrado' })
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateUserProgressDto: UpdateUserProgressDto,
    @CurrentUser() user: any
  ) {
    return this.userProgressService.update(id, updateUserProgressDto, user.id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Eliminar progreso del usuario' })
  @ApiResponse({ status: 200, description: 'Progreso eliminado exitosamente' })
  @ApiResponse({ status: 404, description: 'Progreso no encontrado' })
  remove(@Param('id', ParseUUIDPipe) id: string, @CurrentUser() user: any) {
    return this.userProgressService.remove(id, user.id);
  }

  @Post('track')
  @ApiOperation({ summary: 'Rastrear progreso de lección' })
  @ApiResponse({ status: 200, description: 'Progreso rastreado exitosamente' })
  trackProgress(@Body() trackData: any, @CurrentUser() user: any) {
    return this.userProgressService.trackProgress({
      ...trackData,
      userId: user.id,
    });
  }

  @Get('stats/:courseId')
  @ApiOperation({ summary: 'Obtener estadísticas de progreso del curso' })
  @ApiResponse({ status: 200, description: 'Estadísticas obtenidas exitosamente' })
  getCourseStats(@Param('courseId', ParseUUIDPipe) courseId: string) {
    return this.userProgressService.getCourseStats(courseId);
  }
}
