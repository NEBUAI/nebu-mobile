import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Certificate, CertificateStatus } from '../entities/certificate.entity';
import { CreateCertificateDto } from '../dto/create-certificate.dto';
import { GenerateCertificateDto } from '../dto/generate-certificate.dto';
import { PdfGeneratorService } from './pdf-generator.service';

@Injectable()
export class CertificatesService {
  constructor(
    @InjectRepository(Certificate)
    private certificateRepository: Repository<Certificate>,
    private pdfGeneratorService: PdfGeneratorService
  ) {}

  async create(createCertificateDto: CreateCertificateDto): Promise<Certificate> {
    // Verificar si ya existe un certificado para este usuario y curso
    const existingCertificate = await this.certificateRepository.findOne({
      where: {
        userId: createCertificateDto.userId,
        courseId: createCertificateDto.courseId,
      },
    });

    if (existingCertificate) {
      throw new BadRequestException('Certificate already exists for this user and course');
    }

    const certificateNumber = this.generateCertificateNumber();

    const certificate = this.certificateRepository.create({
      ...createCertificateDto,
      certificateNumber,
      status: (createCertificateDto.status as any) || 'pending',
      metadata: createCertificateDto.metadata
        ? JSON.stringify(createCertificateDto.metadata)
        : null,
    });

    return this.certificateRepository.save(certificate);
  }

  async generate(generateCertificateDto: GenerateCertificateDto): Promise<Certificate> {
    const certificate = await this.certificateRepository.findOne({
      where: {
        userId: generateCertificateDto.userId,
        courseId: generateCertificateDto.courseId,
      },
      relations: ['user', 'course'],
    });

    if (!certificate) {
      throw new NotFoundException('Certificate not found');
    }

    if (certificate.status === CertificateStatus.ISSUED) {
      throw new BadRequestException('Certificate already issued');
    }

    try {
      // Generar el PDF del certificado
      const pdfPath = await this.pdfGeneratorService.generateCertificate(certificate, {
        template: generateCertificateDto.template || 'default',
        customData: generateCertificateDto.customData,
      });

      // Actualizar el certificado
      certificate.status = CertificateStatus.GENERATED;
      certificate.filePath = pdfPath;
      certificate.downloadUrl = this.generateDownloadUrl(certificate.id);
      certificate.issuedAt = generateCertificateDto.issuedAt || new Date();
      certificate.expiresAt = generateCertificateDto.expiresAt;

      return this.certificateRepository.save(certificate);
    } catch (error) {
      certificate.status = CertificateStatus.PENDING;
      await this.certificateRepository.save(certificate);
      throw new BadRequestException(`Failed to generate certificate: ${(error as Error).message}`);
    }
  }

  async findByUser(userId: string): Promise<Certificate[]> {
    return this.certificateRepository.find({
      where: { userId },
      relations: ['course'],
      order: { issuedAt: 'DESC' },
    });
  }

  async findByCourse(courseId: string): Promise<Certificate[]> {
    return this.certificateRepository.find({
      where: { courseId },
      relations: ['user'],
      order: { issuedAt: 'DESC' },
    });
  }

  async findOne(id: string): Promise<Certificate> {
    const certificate = await this.certificateRepository.findOne({
      where: { id },
      relations: ['user', 'course'],
    });

    if (!certificate) {
      throw new NotFoundException('Certificate not found');
    }

    return certificate;
  }

  async findByCertificateNumber(certificateNumber: string): Promise<Certificate> {
    const certificate = await this.certificateRepository.findOne({
      where: { certificateNumber },
      relations: ['user', 'course'],
    });

    if (!certificate) {
      throw new NotFoundException('Certificate not found');
    }

    return certificate;
  }

  async verify(certificateNumber: string): Promise<{
    valid: boolean;
    certificate?: Certificate;
    message: string;
  }> {
    try {
      const certificate = await this.findByCertificateNumber(certificateNumber);

      if (certificate.status !== CertificateStatus.ISSUED) {
        return {
          valid: false,
          message: 'Certificate is not issued',
        };
      }

      if (certificate.expiresAt && certificate.expiresAt < new Date()) {
        return {
          valid: false,
          certificate,
          message: 'Certificate has expired',
        };
      }

      return {
        valid: true,
        certificate,
        message: 'Certificate is valid',
      };
    } catch {
      return {
        valid: false,
        message: 'Certificate not found',
      };
    }
  }

  async revoke(id: string, reason: string): Promise<Certificate> {
    const certificate = await this.findOne(id);

    if (certificate.status === CertificateStatus.REVOKED) {
      throw new BadRequestException('Certificate already revoked');
    }

    certificate.status = CertificateStatus.REVOKED;
    certificate.revocationReason = reason;

    return this.certificateRepository.save(certificate);
  }

  async getStats(): Promise<{
    total: number;
    issued: number;
    pending: number;
    revoked: number;
    byMonth: Array<{ month: string; count: number }>;
  }> {
    const [total, issued, pending, revoked] = await Promise.all([
      this.certificateRepository.count(),
      this.certificateRepository.count({ where: { status: CertificateStatus.ISSUED } }),
      this.certificateRepository.count({ where: { status: CertificateStatus.PENDING } }),
      this.certificateRepository.count({ where: { status: CertificateStatus.REVOKED } }),
    ]);

    // Estadísticas por mes (últimos 12 meses)
    const twelveMonthsAgo = new Date();
    twelveMonthsAgo.setMonth(twelveMonthsAgo.getMonth() - 12);

    const byMonth = await this.certificateRepository
      .createQueryBuilder('certificate')
      .select("DATE_TRUNC('month', certificate.issuedAt)", 'month')
      .addSelect('COUNT(*)', 'count')
      .where('certificate.issuedAt >= :date', { date: twelveMonthsAgo })
      .groupBy("DATE_TRUNC('month', certificate.issuedAt)")
      .orderBy('month', 'ASC')
      .getRawMany();

    return {
      total,
      issued,
      pending,
      revoked,
      byMonth: byMonth.map(item => ({
        month: item.month,
        count: parseInt(item.count),
      })),
    };
  }

  private generateCertificateNumber(): string {
    const timestamp = Date.now().toString(36);
    const random = Math.random().toString(36).substring(2, 8);
    return `CERT-${timestamp}-${random}`.toUpperCase();
  }

  async findByUserAndCourse(userId: string, courseId: string): Promise<Certificate> {
    const certificate = await this.certificateRepository.findOne({
      where: { userId, courseId },
      relations: ['user', 'course'],
    });

    if (!certificate) {
      throw new NotFoundException('Certificate not found for this user and course');
    }

    return certificate;
  }

  async autoGenerateCertificate(
    userId: string,
    courseId: string,
    template = 'default'
  ): Promise<Certificate> {
    // Verificar si ya existe un certificado
    let certificate = await this.certificateRepository.findOne({
      where: { userId, courseId },
      relations: ['user', 'course'],
    });

    if (!certificate) {
      // Crear el certificado si no existe
      const createDto: CreateCertificateDto = {
        userId,
        courseId,
        status: 'pending' as any,
        metadata: { autoGenerated: true },
      };
      certificate = await this.create(createDto);
    }

    if (certificate.status === 'issued') {
      throw new BadRequestException('Certificate already issued');
    }

    // Generar el PDF
    try {
      const pdfPath = await this.pdfGeneratorService.generateCertificate(certificate, {
        template,
        customData: { autoGenerated: true },
      });

      // Actualizar el certificado
      certificate.status = 'generated' as any;
      certificate.filePath = pdfPath;
      certificate.downloadUrl = this.generateDownloadUrl(certificate.id);
      certificate.issuedAt = new Date();

      return this.certificateRepository.save(certificate);
    } catch (error) {
      certificate.status = 'pending' as any;
      await this.certificateRepository.save(certificate);
      throw new BadRequestException(
        `Failed to auto-generate certificate: ${(error as Error).message}`
      );
    }
  }

  private generateDownloadUrl(certificateId: string): string {
    return `${process.env.API_URL}/certificates/${certificateId}/download`;
  }
}
