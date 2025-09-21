import { NestFactory, Reflector } from '@nestjs/core';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ClassSerializerInterceptor } from '@nestjs/common';
import { AppModule } from './app.module';
import { UploadsService } from './uploads/uploads.service';
import { ErrorHandlingInterceptor } from './common/interceptors/error-handling.interceptor';
import { QueryOptimizationInterceptor } from './common/interceptors/query-optimization.interceptor';
import { ValidationSanitizationPipe } from './common/pipes/validation-sanitization.pipe';
import { getCorsOrigins } from './config/cors.config';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // CORS configuration using unified config
  app.enableCors({
    origin: getCorsOrigins(),
    credentials: true,
  });

  // Log CORS configuration in development
  if (process.env.NODE_ENV !== 'production') {
    console.log('🌐 CORS Configuration:', {
      NODE_ENV: process.env.NODE_ENV,
      FRONTEND_URL: process.env.FRONTEND_URL,
      DOMAIN: process.env.DOMAIN,
    });
  }

  // Global validation pipe with sanitization
  app.useGlobalPipes(new ValidationSanitizationPipe());

  // Global interceptors
  app.useGlobalInterceptors(
    new ClassSerializerInterceptor(app.get(Reflector)),
    new ErrorHandlingInterceptor(),
    new QueryOptimizationInterceptor()
  );

  // API prefix
  app.setGlobalPrefix('api/v1');

  // Swagger documentation
  if (process.env.NODE_ENV !== 'production') {
    const config = new DocumentBuilder()
      .setTitle('Nebu Mobile API')
      .setDescription('API completa para Nebu Mobile - IoT y Voice Agent Platform')
      .setVersion('1.0')
      .addTag('auth', 'Autenticación y autorización')
      .addTag('users', 'Gestión de usuarios')
      .addTag('iot', 'Gestión de dispositivos IoT')
      .addTag('voice', 'Agente de voz y audio')
      .addTag('livekit', 'Comunicación tiempo real')
      .addTag('ai', 'Servicios de inteligencia artificial')
      .addBearerAuth()
      .build();

    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api/docs', app, document);
  }

  // Simple health check endpoint (legacy)
  app.getHttpAdapter().get('/health-simple', (req: any, res: any) => {
    res.json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
      version: '1.0.0',
    });
  });

  // Configurar archivos estáticos para uploads
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
    maxAge: '1d', // Cache por 1 día
  });

  // Crear directorios de uploads
  const uploadsService = app.get(UploadsService);
  await uploadsService.createUploadDirectories();

  const port = process.env.PORT || 3001;
  await app.listen(port);

  // eslint-disable-next-line no-console
  console.log(`
🚀 Nebu Mobile Backend iniciado!
📍 URL: http://localhost:${port}
📚 API Docs: http://localhost:${port}/api/docs
🔍 Health Check: http://localhost:${port}/health
� Health Detailed: http://localhost:${port}/health/detailed
🚀 Readiness: http://localhost:${port}/health/readiness
❤️ Liveness: http://localhost:${port}/health/liveness
�📁 Uploads: http://localhost:${port}/uploads/
🔧 Admin Panel: http://localhost:${port}/admin
🎙️ LiveKit: http://localhost:7880
🤖 Voice Agent: Ready for AI integration
📱 Mobile API: Ready for React Native
  `);
}

bootstrap();
