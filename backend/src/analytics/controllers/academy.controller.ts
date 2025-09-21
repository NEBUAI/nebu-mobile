import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AcademyService } from '../services/academy.service';
import { AcademyStatsDto } from '../dto/academy-stats.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('Academy')
@Controller('academy')
export class AcademyController {
  constructor(private readonly academyService: AcademyService) {}

  @Get('stats')
  @ApiOperation({ summary: 'Obtener estadísticas públicas de la academia' })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas obtenidas exitosamente',
    type: AcademyStatsDto,
  })
  async getAcademyStats(): Promise<AcademyStatsDto> {
    return this.academyService.getAcademyStats();
  }

  @Get('stats/private')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Obtener estadísticas detalladas de la academia (requiere autenticación)',
  })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas detalladas obtenidas exitosamente',
    type: AcademyStatsDto,
  })
  async getDetailedAcademyStats(): Promise<AcademyStatsDto> {
    return this.academyService.getAcademyStats();
  }
}
