-- Create database and user for Outliers Academy
CREATE DATABASE outliers_academy_db;
CREATE USER outliers_academy WITH PASSWORD 'outliers_academy_2024!';
GRANT ALL PRIVILEGES ON DATABASE outliers_academy_db TO outliers_academy;

-- Connect to the database
\c outliers_academy_db;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO outliers_academy;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO outliers_academy;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO outliers_academy;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO outliers_academy;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO outliers_academy;
