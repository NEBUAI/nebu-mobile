#!/bin/bash
echo "=== DIAGNÓSTICO LIVEKIT ===" > livekit-debug.log
echo "Fecha: $(date)" >> livekit-debug.log
echo "" >> livekit-debug.log

echo "1. Estado del contenedor:" >> livekit-debug.log
docker ps -a | grep livekit >> livekit-debug.log
echo "" >> livekit-debug.log

echo "2. Logs completos de LiveKit:" >> livekit-debug.log
docker logs nebu-mobile-livekit >> livekit-debug.log 2>&1
echo "" >> livekit-debug.log

echo "3. Configuración actual:" >> livekit-debug.log
echo "--- Archivo livekit.yaml ---" >> livekit-debug.log
cat livekit/livekit.yaml >> livekit-debug.log
echo "" >> livekit-debug.log

echo "4. Configuración Docker:" >> livekit-debug.log
echo "--- docker-compose.yml (sección livekit) ---" >> livekit-debug.log
grep -A 20 "livekit:" docker-compose.yml >> livekit-debug.log
echo "" >> livekit-debug.log

echo "5. Verificación de imagen:" >> livekit-debug.log
docker images | grep livekit >> livekit-debug.log
echo "" >> livekit-debug.log

echo "DIAGNÓSTICO COMPLETADO"
