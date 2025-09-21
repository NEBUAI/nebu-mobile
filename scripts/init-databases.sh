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

# N8N database creation removed - not needed for Nebu Mobile

echo "🎉 Database initialization completed!"



