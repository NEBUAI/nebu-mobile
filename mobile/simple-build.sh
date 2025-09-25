#!/bin/bash

echo "🔍 Verificando estado del proyecto..."

# Verificar archivos esenciales
echo "📁 Archivos de configuración:"
ls -la package.json app.json eas.json app.config.js

echo ""
echo "📦 Dependencias:"
ls -la node_modules/ | head -5

echo ""
echo "Comandos disponibles:"
which npm
which npx
which expo

echo ""
echo " Intentando compilar APK..."

# Intentar con expo build
echo "Método 1: Expo build"
npx expo build:android --type apk --non-interactive || echo " Expo build falló"

echo ""
echo "Método 2: EAS build local"
npx eas build --platform android --profile preview --local --non-interactive || echo " EAS build local falló"

echo ""
echo "Método 3: EAS build cloud"
npx eas build --platform android --profile preview --non-interactive || echo " EAS build cloud falló"

echo ""
echo " Estado final:"
echo "Si todos los métodos fallaron, necesitas:"
echo "1. npm install -g @expo/eas-cli"
echo "2. eas login"
echo "3. eas build:configure"
echo "4. eas build --platform android --profile preview"
