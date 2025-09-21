#!/bin/bash

# ==============================================
# DATABASE INITIALIZATION SCRIPT
# ==============================================

set -e

echo "🚀 Initializing databases..."

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until docker exec outliers-academy-postgres pg_isready -U outliers_academy -d outliers_academy_dev; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "✅ PostgreSQL is ready!"

# Create N8N database if it doesn't exist
echo "🔧 Creating N8N database..."
docker exec outliers-academy-postgres psql -U outliers_academy -d outliers_academy_dev -c "
DO \$\$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'n8n_db') THEN
        PERFORM dblink_exec('dbname=outliers_academy_dev', 'CREATE DATABASE n8n_db');
    END IF;
END
\$\$;
" || docker exec outliers-academy-postgres psql -U outliers_academy -d outliers_academy_dev -c "CREATE DATABASE n8n_db;" 2>/dev/null || true

# Verify N8N database was created
if docker exec outliers-academy-postgres psql -U outliers_academy -d n8n_db -c "SELECT 1;" >/dev/null 2>&1; then
    echo "✅ N8N database created successfully!"
else
    echo "❌ Failed to create N8N database"
    exit 1
fi

echo "🎉 Database initialization completed!"



