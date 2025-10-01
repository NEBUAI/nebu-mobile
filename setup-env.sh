#!/bin/bash

# Script para configurar variables de entorno para Nebu Mobile
echo "🔧 Configurando variables de entorno para Nebu Mobile..."

# Verificar si existe .env
if [ ! -f ".env" ]; then
    echo "📝 Creando archivo .env desde env.example..."
    cp env.example .env
    echo "✅ Archivo .env creado exitosamente"
else
    echo "📝 Archivo .env ya existe"
fi

echo ""
echo "🚨 IMPORTANTE: Debes editar el archivo .env con tus valores reales:"
echo ""
echo "📚 CONFIGURACIONES REQUERIDAS:"
echo ""
echo "🔗 BACKEND:"
echo "   • API_BASE_URL - URL de tu servidor backend"
echo "   • Ejemplo: http://192.168.1.100:3000"
echo ""
echo "🔐 GOOGLE SIGN-IN:"
echo "   • GOOGLE_CLIENT_ID - Desde Google Cloud Console"
echo "   • GOOGLE_WEB_CLIENT_ID - Para autenticación del servidor"
echo ""
echo "📱 FACEBOOK LOGIN:"
echo "   • FACEBOOK_APP_ID - Desde Facebook for Developers"
echo "   • FACEBOOK_CLIENT_TOKEN - Token de cliente de Facebook"
echo ""
echo "🍎 APPLE SIGN-IN:"
echo "   • APPLE_CLIENT_ID - ID de servicio de Apple"
echo "   • APPLE_TEAM_ID - Team ID de Apple Developer"
echo "   • APPLE_KEY_ID - Key ID para firma JWT"
echo "   • APPLE_PRIVATE_KEY_PATH - Ruta al archivo .p8"
echo ""
echo "📡 LIVEKIT:"
echo "   • LIVEKIT_URL - URL del servidor LiveKit"
echo "   • LIVEKIT_API_KEY - API Key de LiveKit Cloud"
echo "   • LIVEKIT_SECRET_KEY - Secret Key de LiveKit Cloud"
echo ""
echo "📱 CONFIGURACIÓN DESARROLLO:"
echo "   Para desarrollo local, usa la IP de tu computadora:"
echo "   • Linux/Mac: ip addr show | grep 'inet ' | grep -v '127.0.0.1'"
echo "   • Windows: ipconfig"
echo "   • Ejemplo: API_BASE_URL=http://192.168.1.100:3000"
echo ""
echo "🔄 DESPUÉS DE CONFIGURAR:"
echo "   npm start (para proyecto Expo)"
echo "   npx expo run:android (para compilar APK local)"
echo ""



