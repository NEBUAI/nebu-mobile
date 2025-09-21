import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  UseGuards,
  ParseUUIDPipe,
  Res,
  NotFoundException,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { Response } from 'express';
import { CertificatesService } from '../services/certificates.service';
import { CreateCertificateDto } from '../dto/create-certificate.dto';
import { GenerateCertificateDto } from '../dto/generate-certificate.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { CurrentUser } from '../../auth/decorators/current-user.decorator';
import { UserRole } from '../../users/entities/user.entity';
import { Certificate } from '../entities/certificate.entity';
import * as fs from 'fs/promises';

@ApiTags('certificates')
@Controller('certificates')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class CertificatesController {
  constructor(private readonly certificatesService: CertificatesService) {}

  @Post()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Crear un certificado' })
  @ApiResponse({ status: 201, description: 'Certificado creado exitosamente', type: Certificate })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  create(@Body() createCertificateDto: CreateCertificateDto) {
    return this.certificatesService.create(createCertificateDto);
  }

  @Post('generate')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Generar certificado PDF' })
  @ApiResponse({ status: 201, description: 'Certificado generado exitosamente', type: Certificate })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  generate(@Body() generateCertificateDto: GenerateCertificateDto) {
    return this.certificatesService.generate(generateCertificateDto);
  }

  @Get('my')
  @ApiOperation({ summary: 'Obtener mis certificados' })
  @ApiResponse({
    status: 200,
    description: 'Certificados obtenidos exitosamente',
    type: [Certificate],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  getMyCertificates(@CurrentUser() user: any) {
    return this.certificatesService.findByUser(user.id);
  }

  @Get('course/:courseId')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Obtener certificados de un curso' })
  @ApiParam({ name: 'courseId', description: 'ID del curso' })
  @ApiResponse({
    status: 200,
    description: 'Certificados obtenidos exitosamente',
    type: [Certificate],
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getByCourse(@Param('courseId', ParseUUIDPipe) courseId: string) {
    return this.certificatesService.findByCourse(courseId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obtener un certificado específico' })
  @ApiParam({ name: 'id', description: 'ID del certificado' })
  @ApiResponse({ status: 200, description: 'Certificado encontrado', type: Certificate })
  @ApiResponse({ status: 404, description: 'Certificado no encontrado' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.certificatesService.findOne(id);
  }

  @Get('verify/:certificateNumber')
  @ApiOperation({ summary: 'Verificar certificado por número' })
  @ApiParam({ name: 'certificateNumber', description: 'Número del certificado' })
  @ApiResponse({
    status: 200,
    description: 'Verificación completada',
    schema: {
      type: 'object',
      properties: {
        valid: { type: 'boolean', description: 'Si el certificado es válido' },
        certificate: { type: 'object', description: 'Datos del certificado si es válido' },
        message: { type: 'string', description: 'Mensaje de verificación' },
      },
    },
  })
  verify(@Param('certificateNumber') certificateNumber: string) {
    return this.certificatesService.verify(certificateNumber);
  }

  @Get(':id/download')
  @ApiOperation({ summary: 'Descargar certificado PDF' })
  @ApiParam({ name: 'id', description: 'ID del certificado' })
  @ApiResponse({ status: 200, description: 'Archivo PDF del certificado' })
  @ApiResponse({ status: 404, description: 'Certificado no encontrado' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  async download(@Param('id', ParseUUIDPipe) id: string, @Res() res: Response) {
    const certificate = await this.certificatesService.findOne(id);

    if (!certificate.filePath) {
      throw new NotFoundException('Certificate file not found');
    }

    try {
      const fileBuffer = await fs.readFile(certificate.filePath);

      res.set({
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="certificate-${certificate.certificateNumber}.pdf"`,
        'Content-Length': fileBuffer.length.toString(),
      });

      res.send(fileBuffer);
    } catch {
      throw new NotFoundException('Certificate file not found');
    }
  }

  @Patch(':id/revoke')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Revocar certificado' })
  @ApiParam({ name: 'id', description: 'ID del certificado' })
  @ApiResponse({ status: 200, description: 'Certificado revocado exitosamente', type: Certificate })
  @ApiResponse({ status: 400, description: 'Certificado ya revocado' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  @ApiResponse({ status: 404, description: 'Certificado no encontrado' })
  revoke(@Param('id', ParseUUIDPipe) id: string, @Body('reason') reason: string) {
    return this.certificatesService.revoke(id, reason);
  }

  @Get('admin/stats')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiOperation({ summary: 'Obtener estadísticas de certificados' })
  @ApiResponse({
    status: 200,
    description: 'Estadísticas obtenidas exitosamente',
    schema: {
      type: 'object',
      properties: {
        total: { type: 'number', description: 'Total de certificados' },
        issued: { type: 'number', description: 'Certificados emitidos' },
        pending: { type: 'number', description: 'Certificados pendientes' },
        revoked: { type: 'number', description: 'Certificados revocados' },
        byMonth: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              month: { type: 'string', description: 'Mes' },
              count: { type: 'number', description: 'Cantidad' },
            },
          },
        },
      },
    },
  })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  getStats() {
    return this.certificatesService.getStats();
  }

  @Post('auto-generate')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.INSTRUCTOR)
  @ApiOperation({ summary: 'Generar certificado automáticamente al completar curso' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        userId: { type: 'string', description: 'ID del usuario' },
        courseId: { type: 'string', description: 'ID del curso' },
        template: { type: 'string', description: 'Plantilla a usar', default: 'default' },
      },
      required: ['userId', 'courseId'],
    },
  })
  @ApiResponse({
    status: 201,
    description: 'Certificado generado automáticamente',
    type: Certificate,
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  @ApiResponse({ status: 403, description: 'Permisos insuficientes' })
  autoGenerate(
    @Body('userId') userId: string,
    @Body('courseId') courseId: string,
    @Body('template') template = 'default'
  ) {
    return this.certificatesService.autoGenerateCertificate(userId, courseId, template);
  }

  @Get('user/:userId/course/:courseId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Obtener certificado específico de usuario y curso' })
  @ApiParam({ name: 'userId', description: 'ID del usuario' })
  @ApiParam({ name: 'courseId', description: 'ID del curso' })
  @ApiResponse({
    status: 200,
    description: 'Certificado encontrado',
    type: Certificate,
  })
  @ApiResponse({ status: 404, description: 'Certificado no encontrado' })
  @ApiResponse({ status: 401, description: 'No autorizado' })
  findByUserAndCourse(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Param('courseId', ParseUUIDPipe) courseId: string
  ) {
    return this.certificatesService.findByUserAndCourse(userId, courseId);
  }
}
