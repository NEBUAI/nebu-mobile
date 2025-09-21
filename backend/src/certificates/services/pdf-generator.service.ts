import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as puppeteer from 'puppeteer';
import * as path from 'path';
import * as fs from 'fs/promises';
import { Certificate } from '../entities/certificate.entity';

@Injectable()
export class PdfGeneratorService {
  private readonly logger = new Logger(PdfGeneratorService.name);
  private readonly uploadsPath: string;

  constructor(private configService: ConfigService) {
    this.uploadsPath = this.configService.get<string>('uploads.path') || './uploads';
  }

  async generateCertificate(
    certificate: Certificate,
    options: {
      template?: string;
      customData?: Record<string, any>;
    } = {}
  ): Promise<string> {
    try {
      const browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox'],
      });

      const page = await browser.newPage();

      // Generar HTML del certificado
      const html = this.generateCertificateHTML(certificate, options);

      await page.setContent(html, { waitUntil: 'networkidle0' });

      // Configurar el PDF
      const pdfBuffer = await page.pdf({
        format: 'A4',
        printBackground: true,
        margin: {
          top: '0.5in',
          right: '0.5in',
          bottom: '0.5in',
          left: '0.5in',
        },
      });

      await browser.close();

      // Guardar el archivo
      const fileName = `certificate-${certificate.id}.pdf`;
      const filePath = path.join(this.uploadsPath, 'certificates', fileName);

      // Crear directorio si no existe
      await fs.mkdir(path.dirname(filePath), { recursive: true });

      await fs.writeFile(filePath, pdfBuffer);

      this.logger.log(`Certificate PDF generated: ${filePath}`);
      return filePath;
    } catch (error) {
      this.logger.error(`Failed to generate certificate PDF:`, error);
      throw error;
    }
  }

  private generateCertificateHTML(
    certificate: Certificate,
    _options: {
      template?: string;
      customData?: Record<string, any>;
    }
  ): string {
    const { user, course } = certificate;
    // const customData = options.customData || {};

    return `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <title>Certificate of Completion</title>
          <style>
            @page {
              size: A4;
              margin: 0;
            }
            
            body {
              font-family: 'Times New Roman', serif;
              margin: 0;
              padding: 0;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              min-height: 100vh;
              display: flex;
              align-items: center;
              justify-content: center;
            }
            
            .certificate {
              background: white;
              width: 800px;
              height: 600px;
              padding: 60px;
              box-shadow: 0 20px 40px rgba(0,0,0,0.1);
              border-radius: 10px;
              position: relative;
              text-align: center;
            }
            
            .border {
              border: 8px solid #4F46E5;
              border-radius: 5px;
              height: 100%;
              display: flex;
              flex-direction: column;
              justify-content: center;
              position: relative;
            }
            
            .border::before {
              content: '';
              position: absolute;
              top: 20px;
              left: 20px;
              right: 20px;
              bottom: 20px;
              border: 2px solid #E5E7EB;
              border-radius: 3px;
            }
            
            .header {
              margin-bottom: 40px;
            }
            
            .title {
              font-size: 36px;
              font-weight: bold;
              color: #1F2937;
              margin-bottom: 10px;
              text-transform: uppercase;
              letter-spacing: 2px;
            }
            
            .subtitle {
              font-size: 18px;
              color: #6B7280;
              margin-bottom: 20px;
            }
            
            .content {
              margin: 40px 0;
            }
            
            .award-text {
              font-size: 20px;
              color: #374151;
              margin-bottom: 30px;
              line-height: 1.6;
            }
            
            .student-name {
              font-size: 32px;
              font-weight: bold;
              color: #4F46E5;
              margin: 20px 0;
              text-decoration: underline;
              text-decoration-color: #4F46E5;
            }
            
            .course-name {
              font-size: 24px;
              color: #1F2937;
              margin: 20px 0;
              font-weight: 600;
            }
            
            .details {
              margin: 40px 0;
              display: flex;
              justify-content: space-around;
              flex-wrap: wrap;
            }
            
            .detail-item {
              margin: 10px;
            }
            
            .detail-label {
              font-size: 14px;
              color: #6B7280;
              text-transform: uppercase;
              letter-spacing: 1px;
            }
            
            .detail-value {
              font-size: 16px;
              color: #1F2937;
              font-weight: 600;
              margin-top: 5px;
            }
            
            .footer {
              margin-top: 40px;
              display: flex;
              justify-content: space-between;
              align-items: center;
            }
            
            .signature {
              text-align: center;
            }
            
            .signature-line {
              border-bottom: 2px solid #1F2937;
              width: 200px;
              margin: 0 auto 10px;
            }
            
            .signature-text {
              font-size: 14px;
              color: #6B7280;
            }
            
            .certificate-number {
              font-size: 12px;
              color: #9CA3AF;
              margin-top: 20px;
            }
            
            .logo {
              position: absolute;
              top: 20px;
              right: 20px;
              width: 80px;
              height: 80px;
              background: #4F46E5;
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              color: white;
              font-size: 24px;
              font-weight: bold;
            }
          </style>
        </head>
        <body>
          <div class="certificate">
            <div class="border">
              <div class="logo">OA</div>
              
              <div class="header">
                <div class="title">Certificate of Completion</div>
                <div class="subtitle">Outliers Academy</div>
              </div>
              
              <div class="content">
                <div class="award-text">
                  This is to certify that
                </div>
                
                <div class="student-name">
                  ${user.firstName} ${user.lastName}
                </div>
                
                <div class="award-text">
                  has successfully completed the course
                </div>
                
                <div class="course-name">
                  "${course.title}"
                </div>
                
                <div class="details">
                  <div class="detail-item">
                    <div class="detail-label">Completion Date</div>
                    <div class="detail-value">
                      ${certificate.completedAt ? new Date(certificate.completedAt).toLocaleDateString() : 'N/A'}
                    </div>
                  </div>
                  
                  <div class="detail-item">
                    <div class="detail-label">Final Score</div>
                    <div class="detail-value">
                      ${certificate.finalScore ? `${certificate.finalScore}%` : 'N/A'}
                    </div>
                  </div>
                  
                  <div class="detail-item">
                    <div class="detail-label">Certificate Number</div>
                    <div class="detail-value">
                      ${certificate.certificateNumber}
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="footer">
                <div class="signature">
                  <div class="signature-line"></div>
                  <div class="signature-text">Instructor Signature</div>
                </div>
                
                <div class="signature">
                  <div class="signature-line"></div>
                  <div class="signature-text">Date of Issue</div>
                </div>
              </div>
              
              <div class="certificate-number">
                Certificate ID: ${certificate.id}
              </div>
            </div>
          </div>
        </body>
      </html>
    `;
  }
}
