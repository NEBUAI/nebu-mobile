import { Injectable } from '@nestjs/common';

@Injectable()
export class CompanyService {
  async getCompanyInfo() {
    return {
      email: process.env.COMPANY_EMAIL || 'info@outliersacademy.com',
      phone: process.env.COMPANY_PHONE || '+51999999999',
      whatsapp: process.env.COMPANY_WHATSAPP || '51999999999',
      calendly: process.env.COMPANY_CALENDLY || 'https://calendly.com/outliersacademy',
      address: process.env.COMPANY_ADDRESS || 'Lima, Perú',
      socialMedia: {
        facebook: process.env.COMPANY_FACEBOOK || 'https://facebook.com/outliersacademy',
        twitter: process.env.COMPANY_TWITTER || 'https://twitter.com/outliersacademy',
        linkedin: process.env.COMPANY_LINKEDIN || 'https://linkedin.com/company/outliersacademy',
        instagram: process.env.COMPANY_INSTAGRAM || 'https://instagram.com/outliersacademy',
      },
    };
  }
}
