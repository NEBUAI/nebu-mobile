#!/bin/bash

# Script de linting para Flutter
# Ejecuta análisis de código con diferentes niveles de verbosidad

echo "🔍 Ejecutando análisis de código Flutter..."

# Función para mostrar errores
show_errors() {
    echo "❌ Errores encontrados:"
    echo "================================"
}

# Función para mostrar warnings
show_warnings() {
    echo "⚠️  Warnings encontrados:"
    echo "================================"
}

# Función para mostrar info
show_info() {
    echo "ℹ️  Sugerencias encontradas:"
    echo "================================"
}

# Ejecutar análisis básico
echo "1. Análisis básico..."
if flutter analyze --no-fatal-infos 2>&1; then
    echo "✅ Análisis básico completado sin errores críticos"
else
    echo "❌ Análisis básico encontró problemas"
fi

echo ""

# Ejecutar análisis con información
echo "2. Análisis detallado..."
if dart analyze --fatal-infos 2>&1; then
    echo "✅ Análisis detallado completado"
else
    echo "❌ Análisis detallado encontró problemas"
fi

echo ""

# Verificar formato de código
echo "3. Verificando formato de código..."
if dart format --set-exit-if-changed lib/ 2>&1; then
    echo "✅ Código está bien formateado"
else
    echo "⚠️  Código necesita formateo. Ejecutando 'dart format lib/' para corregir..."
    dart format lib/
fi

echo ""

# Verificar imports
echo "4. Verificando imports..."
echo "Archivos con imports relativos:"
find lib/ -name "*.dart" -exec grep -l "import '\.\./" {} \;

echo ""

# Verificar documentación
echo "5. Verificando documentación..."
echo "Archivos sin documentación de clase:"
find lib/ -name "*.dart" -exec grep -L "///" {} \; | head -5

echo ""

# Verificar uso de print statements
echo "6. Verificando uso de print statements..."
echo "Archivos con print statements:"
find lib/ -name "*.dart" -exec grep -l "print(" {} \;

echo ""

# Verificar archivos grandes
echo "7. Verificando archivos grandes (>300 líneas):"
find lib/ -name "*.dart" -exec wc -l {} \; | awk '$1 > 300 {print $2 ": " $1 " líneas"}'

echo ""
echo "🎯 Análisis completado!"
echo "Para corregir automáticamente algunos problemas:"
echo "  - dart format lib/"
echo "  - dart fix --apply"
