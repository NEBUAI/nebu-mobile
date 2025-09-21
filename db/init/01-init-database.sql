-- ==============================================
-- OUTLIERS ACADEMY - DATABASE INITIALIZATION
-- ==============================================

-- Crear extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Configurar timezone
SET timezone = 'UTC';

-- Crear usuario de aplicación si no existe
DO $$ BEGIN IF NOT EXISTS (
    SELECT
    FROM pg_user
    WHERE
        usename = 'outliers_app'
) THEN
CREATE USER outliers_app
WITH
    PASSWORD 'secure_app_password';

END IF;

END $$;

-- Otorgar permisos necesarios
GRANT CONNECT ON DATABASE outliers_academy TO outliers_app;

GRANT USAGE ON SCHEMA public TO outliers_app;

GRANT CREATE ON SCHEMA public TO outliers_app;

-- Configuración de performance
ALTER SYSTEM
SET
    shared_preload_libraries = 'pg_stat_statements';

ALTER SYSTEM
SET
    track_activity_query_size = 2048;

ALTER SYSTEM
SET
    pg_stat_statements.track = 'all';

-- Configuración de logging
ALTER SYSTEM
SET
    log_statement = 'all';

ALTER SYSTEM
SET
    log_min_duration_statement = 1000;

-- Log queries > 1s
ALTER SYSTEM
SET
    log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';

-- Reload configuration
SELECT pg_reload_conf ();

-- Crear esquema para métricas si es necesario
CREATE SCHEMA IF NOT EXISTS metrics;

GRANT USAGE ON SCHEMA metrics TO outliers_app;

GRANT CREATE ON SCHEMA metrics TO outliers_app;

-- Log de inicialización
INSERT INTO
    pg_catalog.pg_proc (proname)
VALUES ('database_initialized') ON CONFLICT DO NOTHING;