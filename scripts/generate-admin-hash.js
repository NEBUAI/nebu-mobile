#!/usr/bin/env node

const bcrypt = require('bcrypt');

async function generateAdminHash() {
  const password = process.argv[2] || 'admin123';
  
  console.log('🔐 Generando hash para AdminJS...\n');
  
  try {
    const hash = await bcrypt.hash(password, 12);
    
    console.log('✅ Hash generado exitosamente!');
    console.log('📝 Agrega esta línea a tu archivo .env:\n');
    console.log(`ADMIN_PASSWORD_HASH=${hash}`);
    console.log('\n🔑 Credenciales de acceso:');
    console.log(`Email: admin@nebu.academy`);
    console.log(`Password: ${password}`);
    console.log('\n🌐 URL del panel: https://admin.nebu.academy/admin');
    
  } catch (error) {
    console.error('❌ Error generando hash:', error);
  }
}

generateAdminHash();
