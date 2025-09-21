-- ==============================================
-- N8N DATABASE INITIALIZATION
-- ==============================================

-- Crear base de datos para N8N
CREATE DATABASE n8n_db;

-- Conectar a la base de datos n8n_db
\c n8n_db;

-- Crear extensiones necesarias para N8N
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Otorgar permisos al usuario de la aplicación
GRANT ALL PRIVILEGES ON DATABASE n8n_db TO outliers_academy;
GRANT ALL ON SCHEMA public TO outliers_academy;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO outliers_academy;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO outliers_academy;

-- Configurar privilegios por defecto para tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO outliers_academy;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO outliers_academy;

-- Log de inicialización
DO $$
BEGIN
    RAISE NOTICE 'N8N database initialized successfully';
END $$;
