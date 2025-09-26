#!/bin/bash

# Script para configurar variables de entorno
echo "🔧 Configurando variables de entorno para Nebu Mobile..."

# Verificar si existe .env
if [ ! -f ".env" ]; then
    echo "📝 Creando archivo .env desde env.example..."
    cp env.example .env
    echo "✅ Archivo .env creado"
else
    echo "📝 Archivo .env ya existe"
fi

echo ""
echo "🚨 IMPORTANTE: Debes editar el archivo .env con tus valores reales:"
echo ""
echo "1. API_BASE_URL - URL de tu backend (ej: http://192.168.1.100:3000)"
echo "2. GOOGLE_CLIENT_ID - ID de cliente de Google"
echo "3. FACEBOOK_APP_ID - ID de aplicación de Facebook"
echo "4. LIVEKIT_URL - URL de tu servidor LiveKit"
echo ""
echo "📱 Para desarrollo local, usa la IP de tu computadora en lugar de localhost"
echo "   Ejemplo: API_BASE_URL=http://192.168.1.100:3000"
echo ""
echo "💡 Para encontrar tu IP local:"
echo "   - Linux/Mac: ip addr show | grep 'inet ' | grep -v '127.0.0.1'"
echo "   - Windows: ipconfig"
echo ""
echo "🔄 Después de editar .env, reinicia el servidor de desarrollo:"
echo "   npm start"



