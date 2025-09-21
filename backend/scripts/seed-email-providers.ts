import { DataSource } from 'typeorm';
import { config } from 'dotenv';
import * as bcrypt from 'bcryptjs';
import { EmailProvider, EmailProviderType, EmailProviderStatus } from '../src/email/entities/email-provider.entity';
import { EmailAccount, EmailAccountType, EmailAccountStatus } from '../src/email/entities/email-account.entity';

// Load environment variables
config();

const AppDataSource = new DataSource({
  type: 'postgres',
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT || '5432'),
  username: process.env.DATABASE_USERNAME || 'outliers_academy',
  password: process.env.DATABASE_PASSWORD || 'outliers_academy_2024!',
  database: process.env.DATABASE_NAME || 'outliers_academy_db',
  entities: [__dirname + '/../src/**/*.entity{.ts,.js}'],
  synchronize: false,
  logging: true,
});

async function seedEmailProviders() {
  try {
    await AppDataSource.initialize();
    console.log('Database connection established');

    const emailProviderRepository = AppDataSource.getRepository(EmailProvider);
    const emailAccountRepository = AppDataSource.getRepository(EmailAccount);

    // Create Hostinger provider
    const hostingerProvider = emailProviderRepository.create({
      name: 'Hostinger',
      host: 'smtp.hostinger.com',
      port: 587,
      secure: false,
      type: EmailProviderType.SMTP,
      status: EmailProviderStatus.ACTIVE,
      description: 'Proveedor principal de correo para Outliers Academy',
      priority: 1,
      dailyLimit: 1000,
      sentToday: 0,
      lastResetDate: new Date(),
    });

    await emailProviderRepository.save(hostingerProvider);
  console.log('Hostinger provider created');

    // Create Gmail provider (backup)
    const gmailProvider = emailProviderRepository.create({
      name: 'Gmail',
      host: 'smtp.gmail.com',
      port: 587,
      secure: false,
      type: EmailProviderType.SMTP,
      status: EmailProviderStatus.ACTIVE,
      description: 'Proveedor de respaldo para correos importantes',
      priority: 2,
      dailyLimit: 500,
      sentToday: 0,
      lastResetDate: new Date(),
    });

    await emailProviderRepository.save(gmailProvider);
  console.log('Gmail provider created');

    // Create email accounts
    const accounts = [
      {
        email: 'team@outliers.academy',
        password: 'B#v6jzkWG6o',
        fromName: 'Outliers Academy Team',
        type: EmailAccountType.TEAM,
        description: 'Cuenta principal para comunicación general',
        dailyLimit: 500,
        providerId: hostingerProvider.id,
      },
      {
        email: 'noreply@outliers.academy',
        password: 'j5TrI!WsbYW/',
        fromName: 'Outliers Academy',
        type: EmailAccountType.NOREPLY,
        description: 'Cuenta para notificaciones automáticas',
        dailyLimit: 1000,
        providerId: hostingerProvider.id,
      },
      {
        email: 'admin@outliers.academy',
        password: 'B#v6jzkWG6o',
        fromName: 'Outliers Academy Admin',
        type: EmailAccountType.ADMIN,
        description: 'Cuenta para administración y alertas del sistema',
        dailyLimit: 200,
        providerId: hostingerProvider.id,
      },
      {
        email: 'support@outliers.academy',
        password: 'B#v6jzkWG6o',
        fromName: 'Outliers Academy Support',
        type: EmailAccountType.SUPPORT,
        description: 'Cuenta para soporte al cliente',
        dailyLimit: 300,
        providerId: hostingerProvider.id,
      },
    ];

    for (const accountData of accounts) {
      const hashedPassword = await bcrypt.hash(accountData.password, 10);
      
      const account = emailAccountRepository.create({
        ...accountData,
        password: hashedPassword,
        status: EmailAccountStatus.ACTIVE,
        sentToday: 0,
        lastResetDate: new Date(),
      });

      await emailAccountRepository.save(account);
  console.log(`Account ${accountData.email} created`);
    }

  console.log('Email providers and accounts seeded successfully!');

  } catch (error) {
  console.error('Error seeding email providers:', error);
  } finally {
    await AppDataSource.destroy();
    console.log('Database connection closed');
  }
}

// Run the seed function
seedEmailProviders();
