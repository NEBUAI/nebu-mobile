module.exports = {
  // Configuración de base de datos
  database: {
    type: 'postgresdb',
    host: process.env.DB_POSTGRESDB_HOST || 'postgres',
    port: process.env.DB_POSTGRESDB_PORT || 5432,
    database: process.env.DB_POSTGRESDB_DATABASE || 'n8n_db',
    username: process.env.DB_POSTGRESDB_USER || 'outliers_academy',
    password: process.env.DB_POSTGRESDB_PASSWORD || 'outliers_academy_2024!',
  },

  // Configuración de autenticación
  security: {
    basicAuth: {
      active: true,
      user: process.env.N8N_BASIC_AUTH_USER || 'admin',
      password: process.env.N8N_BASIC_AUTH_PASSWORD || 'admin123',
    },
  },

  // Configuración de webhooks
  webhook: {
    url: process.env.WEBHOOK_URL || 'http://localhost:5678',
  },

  // Configuración de logs
  logging: {
    level: process.env.N8N_LOG_LEVEL || 'info',
    output: process.env.N8N_LOG_OUTPUT || 'console',
  },

  // Configuración de métricas
  metrics: {
    enabled: process.env.N8N_METRICS === 'true',
  },

  // Configuración de timezone
  timezone: process.env.GENERIC_TIMEZONE || 'UTC',

  // Configuración de host
  host: process.env.N8N_HOST || 'localhost',
  port: process.env.N8N_PORT || 5678,
  protocol: process.env.N8N_PROTOCOL || 'http',

  // Configuración de encriptación
  encryptionKey: process.env.N8N_ENCRYPTION_KEY || 'outliers_n8n_encryption_key_2024',

  // Configuración de ejecución
  execution: {
    mode: 'regular',
    timeout: 3600, // 1 hora
    maxTimeout: 7200, // 2 horas
  },

  // Configuración de archivos
  files: {
    maxSize: 16777216, // 16MB
  },

  // Configuración de notificaciones
  notifications: {
    enabled: true,
  },

  // Configuración de versionado
  versioning: {
    enabled: true,
  },

  // Configuración de personalización
  customization: {
    enabled: true,
  },
};
