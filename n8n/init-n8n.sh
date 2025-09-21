#!/bin/bash

# Script de inicialización para N8N
# Este script configura la base de datos y prepara N8N para su primer uso

set -e

echo "🚀 Inicializando N8N para Outliers Academy..."

# Variables de configuración
DB_HOST=${DB_POSTGRESDB_HOST:-postgres}
DB_PORT=${DB_POSTGRESDB_PORT:-5432}
DB_NAME=${DB_POSTGRESDB_DATABASE:-n8n_db}
DB_USER=${DB_POSTGRESDB_USER:-outliers_academy}
DB_PASSWORD=${DB_POSTGRESDB_PASSWORD:-outliers_academy_2024!}

# Esperar a que PostgreSQL esté disponible
echo "⏳ Esperando a que PostgreSQL esté disponible..."
until pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USER; do
  echo "PostgreSQL no está disponible - esperando..."
  sleep 2
done

echo "✅ PostgreSQL está disponible"

# Crear la base de datos si no existe
echo "🔧 Verificando base de datos N8N..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d postgres -c "CREATE DATABASE $DB_NAME;" 2>/dev/null || echo "Base de datos ya existe"

echo "✅ Base de datos N8N configurada"

# Crear directorios necesarios
echo "📁 Creando directorios de N8N..."
mkdir -p /home/node/.n8n/workflows
mkdir -p /home/node/.n8n/credentials
mkdir -p /home/node/.n8n/nodes
mkdir -p /var/log/n8n

# Configurar permisos
chown -R node:node /home/node/.n8n
chown -R node:node /var/log/n8n

echo "✅ Directorios creados y permisos configurados"

# Verificar configuración
echo "🔍 Verificando configuración de N8N..."
echo "Host: ${N8N_HOST:-localhost}"
echo "Puerto: ${N8N_PORT:-5678}"
echo "Base de datos: $DB_NAME"
echo "Usuario: $DB_USER"

echo "🎉 N8N inicializado correctamente!"
echo "📝 Accede a N8N en: http://${N8N_HOST:-localhost}:${N8N_PORT:-5678}"
echo "👤 Usuario: ${N8N_USER:-admin}"
echo "🔑 Contraseña: ${N8N_PASSWORD:-admin123}"
