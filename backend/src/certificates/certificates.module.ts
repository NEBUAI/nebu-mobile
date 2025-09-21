import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CertificatesController } from './controllers/certificates.controller';
import { CertificatesService } from './services/certificates.service';
import { PdfGeneratorService } from './services/pdf-generator.service';
import { Certificate } from './entities/certificate.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Certificate])],
  controllers: [CertificatesController],
  providers: [CertificatesService, PdfGeneratorService],
  exports: [CertificatesService, PdfGeneratorService],
})
export class CertificatesModule {}
