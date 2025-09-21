#!/bin/bash
echo "=== VERIFICACIÓN LIVEKIT ===" > livekit-check.log
echo "Fecha: $(date)" >> livekit-check.log
echo "" >> livekit-check.log

echo "1. Estado del contenedor:" >> livekit-check.log
docker ps | grep livekit >> livekit-check.log
echo "" >> livekit-check.log

echo "2. Logs recientes (últimas 15 líneas):" >> livekit-check.log
docker logs nebu-mobile-livekit --tail=15 >> livekit-check.log 2>&1
echo "" >> livekit-check.log

echo "3. Health check manual:" >> livekit-check.log
wget -qO- http://localhost:7880/ >> livekit-check.log 2>&1 || echo "Health check falló" >> livekit-check.log
echo "" >> livekit-check.log

echo "4. Test de conectividad a Redis desde LiveKit:" >> livekit-check.log
docker exec nebu-mobile-livekit ping -c 2 redis >> livekit-check.log 2>&1 || echo "No se pudo hacer ping a Redis" >> livekit-check.log
echo "" >> livekit-check.log

echo "VERIFICACIÓN COMPLETADA"
