-- Create database and user for Nebu Mobile
CREATE DATABASE nebu_db;
CREATE USER nebu_user WITH PASSWORD 'nebu_password_2024!';
GRANT ALL PRIVILEGES ON DATABASE nebu_db TO nebu_user;

-- Connect to the database
\c nebu_db;

-- Grant schema privileges
GRANT ALL ON SCHEMA public TO nebu_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO nebu_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO nebu_user;

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Set default privileges for future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO nebu_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO nebu_user;

-- Nebu-specific initial schema
-- IoT Devices table
CREATE TABLE IF NOT EXISTS iot_devices (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    device_type VARCHAR(100) NOT NULL,
    mac_address VARCHAR(17) UNIQUE,
    ip_address INET,
    status VARCHAR(50) DEFAULT 'offline',
    location VARCHAR(255),
    metadata JSONB,
    user_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP
);

-- Voice Sessions table
CREATE TABLE IF NOT EXISTS voice_sessions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID,
    session_token VARCHAR(512),
    room_name VARCHAR(255),
    status VARCHAR(50) DEFAULT 'active',
    language VARCHAR(10) DEFAULT 'es',
    metadata JSONB,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    duration_seconds INTEGER
);

-- LiveKit Rooms table
CREATE TABLE IF NOT EXISTS livekit_rooms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    room_type VARCHAR(50) DEFAULT 'general',
    max_participants INTEGER DEFAULT 50,
    empty_timeout INTEGER DEFAULT 300,
    metadata JSONB,
    created_by UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- AI Conversations table
CREATE TABLE IF NOT EXISTS ai_conversations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID,
    session_id UUID REFERENCES voice_sessions(id),
    message_type VARCHAR(20) CHECK (message_type IN ('user', 'assistant')),
    content TEXT,
    audio_url VARCHAR(500),
    tokens_used INTEGER,
    processing_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_iot_devices_user_id ON iot_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_iot_devices_status ON iot_devices(status);
CREATE INDEX IF NOT EXISTS idx_voice_sessions_user_id ON voice_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_voice_sessions_status ON voice_sessions(status);
CREATE INDEX IF NOT EXISTS idx_livekit_rooms_name ON livekit_rooms(name);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_session_id ON ai_conversations(session_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON ai_conversations(user_id);
