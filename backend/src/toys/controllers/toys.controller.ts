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
  HttpStatus,
  ParseUUIDPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiParam,
  ApiQuery,
  ApiBearerAuth,
  ApiBody,
} from '@nestjs/swagger';
import { ToysService } from '../services/toys.service';
import { CreateToyDto } from '../dto/create-toy.dto';
import { UpdateToyDto } from '../dto/update-toy.dto';
import { AssignToyDto, AssignToyResponseDto } from '../dto/assign-toy.dto';
import { ToyResponseDto, ToyListResponseDto } from '../dto/toy-response.dto';
import { ToyStatus } from '../entities/toy.entity';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { UserRole } from '../../auth/decorators/user-role.enum';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { User } from '../../users/entities/user.entity';

@ApiTags('toys')
@Controller('toys')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ToysController {
  constructor(private readonly toysService: ToysService) {}

  @Post()
  @ApiOperation({ 
    summary: 'Crear un nuevo juguete',
    description: 'Crea un nuevo juguete IoT con MAC address y configuración inicial'
  })
  @ApiResponse({
    status: HttpStatus.CREATED,
    description: 'Juguete creado exitosamente',
    type: ToyResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.CONFLICT,
    description: 'Ya existe un juguete con ese MAC address',
  })
  @ApiResponse({
    status: HttpStatus.BAD_REQUEST,
    description: 'Datos de entrada inválidos',
  })
  async create(@Body() createToyDto: CreateToyDto): Promise<ToyResponseDto> {
    return this.toysService.create(createToyDto);
  }

  @Get()
  @ApiOperation({ 
    summary: 'Obtener lista de juguetes',
    description: 'Obtiene una lista paginada de juguetes con filtros opcionales'
  })
  @ApiQuery({ name: 'page', required: false, type: Number, description: 'Número de página' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Elementos por página' })
  @ApiQuery({ name: 'status', required: false, enum: ToyStatus, description: 'Filtrar por estado' })
  @ApiQuery({ name: 'userId', required: false, type: String, description: 'Filtrar por usuario' })
  @ApiQuery({ name: 'search', required: false, type: String, description: 'Búsqueda en nombre, modelo, fabricante o MAC' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Lista de juguetes obtenida exitosamente',
    type: ToyListResponseDto,
  })
  async findAll(
    @Query('page') page: number = 1,
    @Query('limit') limit: number = 10,
    @Query('status') status?: ToyStatus,
    @Query('userId') userId?: string,
    @Query('search') search?: string,
  ): Promise<ToyListResponseDto> {
    return this.toysService.findAll(page, limit, status, userId, search);
  }

  @Get('my-toys')
  @ApiOperation({ 
    summary: 'Obtener mis juguetes',
    description: 'Obtiene los juguetes asignados al usuario autenticado'
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Juguetes del usuario obtenidos exitosamente',
    type: [ToyResponseDto],
  })
  async findMyToys(@CurrentUser() user: User): Promise<ToyResponseDto[]> {
    return this.toysService.findByUserId(user.id);
  }

  @Get('statistics')
  @Roles(UserRole.ADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ 
    summary: 'Obtener estadísticas de juguetes',
    description: 'Obtiene estadísticas generales de juguetes (solo administradores)'
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Estadísticas obtenidas exitosamente',
  })
  async getStatistics() {
    return this.toysService.getStatistics();
  }

  @Get('mac/:macAddress')
  @ApiOperation({ 
    summary: 'Buscar juguete por MAC address',
    description: 'Obtiene un juguete específico por su MAC address'
  })
  @ApiParam({ name: 'macAddress', description: 'MAC address del juguete' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Juguete encontrado exitosamente',
    type: ToyResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Juguete no encontrado',
  })
  async findByMacAddress(@Param('macAddress') macAddress: string): Promise<ToyResponseDto> {
    return this.toysService.findByMacAddress(macAddress);
  }

  @Get(':id')
  @ApiOperation({ 
    summary: 'Obtener juguete por ID',
    description: 'Obtiene un juguete específico por su ID'
  })
  @ApiParam({ name: 'id', description: 'ID único del juguete' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Juguete encontrado exitosamente',
    type: ToyResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Juguete no encontrado',
  })
  async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<ToyResponseDto> {
    return this.toysService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ 
    summary: 'Actualizar juguete',
    description: 'Actualiza los datos de un juguete existente'
  })
  @ApiParam({ name: 'id', description: 'ID único del juguete' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Juguete actualizado exitosamente',
    type: ToyResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Juguete no encontrado',
  })
  @ApiResponse({
    status: HttpStatus.CONFLICT,
    description: 'MAC address ya existe en otro juguete',
  })
  async update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() updateToyDto: UpdateToyDto,
  ): Promise<ToyResponseDto> {
    return this.toysService.update(id, updateToyDto);
  }

  @Delete(':id')
  @Roles(UserRole.ADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ 
    summary: 'Eliminar juguete',
    description: 'Elimina un juguete del sistema (solo administradores)'
  })
  @ApiParam({ name: 'id', description: 'ID único del juguete' })
  @ApiResponse({
    status: HttpStatus.NO_CONTENT,
    description: 'Juguete eliminado exitosamente',
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Juguete no encontrado',
  })
  async remove(@Param('id', ParseUUIDPipe) id: string): Promise<void> {
    return this.toysService.remove(id);
  }

  @Post('assign')
  @ApiOperation({ 
    summary: 'Asignar/desasignar juguete',
    description: 'Asigna un juguete a un usuario o lo desasigna'
  })
  @ApiBody({ type: AssignToyDto })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Juguete asignado/desasignado exitosamente',
    type: AssignToyResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Juguete o usuario no encontrado',
  })
  async assignToy(@Body() assignToyDto: AssignToyDto): Promise<AssignToyResponseDto> {
    return this.toysService.assignToy(assignToyDto);
  }

  @Patch('connection/:macAddress')
  @ApiOperation({ 
    summary: 'Actualizar estado de conexión',
    description: 'Actualiza el estado de conexión de un juguete (usado por dispositivos IoT)'
  })
  @ApiParam({ name: 'macAddress', description: 'MAC address del juguete' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        status: { 
          type: 'string', 
          enum: Object.values(ToyStatus),
          description: 'Nuevo estado del juguete'
        },
        batteryLevel: { 
          type: 'string', 
          description: 'Nivel de batería (ej: "85%")',
          example: '85%'
        },
        signalStrength: { 
          type: 'string', 
          description: 'Fuerza de señal WiFi (ej: "-45dBm")',
          example: '-45dBm'
        },
      },
      required: ['status']
    }
  })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Estado de conexión actualizado exitosamente',
    type: ToyResponseDto,
  })
  @ApiResponse({
    status: HttpStatus.NOT_FOUND,
    description: 'Juguete no encontrado',
  })
  async updateConnectionStatus(
    @Param('macAddress') macAddress: string,
    @Body() body: {
      status: ToyStatus;
      batteryLevel?: string;
      signalStrength?: string;
    },
  ): Promise<ToyResponseDto> {
    return this.toysService.updateConnectionStatus(
      macAddress,
      body.status,
      body.batteryLevel,
      body.signalStrength,
    );
  }

  @Get('user/:userId')
  @Roles(UserRole.ADMIN)
  @UseGuards(RolesGuard)
  @ApiOperation({ 
    summary: 'Obtener juguetes de un usuario',
    description: 'Obtiene todos los juguetes asignados a un usuario específico (solo administradores)'
  })
  @ApiParam({ name: 'userId', description: 'ID único del usuario' })
  @ApiResponse({
    status: HttpStatus.OK,
    description: 'Juguetes del usuario obtenidos exitosamente',
    type: [ToyResponseDto],
  })
  async findToysByUserId(@Param('userId', ParseUUIDPipe) userId: string): Promise<ToyResponseDto[]> {
    return this.toysService.findByUserId(userId);
  }
}
