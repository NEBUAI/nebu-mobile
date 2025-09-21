#!/bin/bash
echo "=== VERIFICACIÓN FINAL DE TODOS LOS SERVICIOS ===" > final-verification.log
echo "Fecha: $(date)" >> final-verification.log
echo "" >> final-verification.log

echo "1. Estado de todos los contenedores nebu-mobile:" >> final-verification.log
docker ps | grep nebu-mobile >> final-verification.log
echo "" >> final-verification.log

echo "2. Health check del backend:" >> final-verification.log
wget -qO- http://localhost:3001/api/v1/health | head -c 200 >> final-verification.log 2>&1 || echo "Backend no responde" >> final-verification.log
echo "" >> final-verification.log

echo "3. Health check de LiveKit:" >> final-verification.log
wget -qO- http://localhost:7880/ >> final-verification.log 2>&1 || echo "LiveKit no responde" >> final-verification.log
echo "" >> final-verification.log

echo "4. Logs del backend (últimas 5 líneas):" >> final-verification.log
docker logs nebu-mobile-backend --tail=5 >> final-verification.log 2>&1
echo "" >> final-verification.log

echo "5. Logs de LiveKit (últimas 5 líneas):" >> final-verification.log
docker logs nebu-mobile-livekit --tail=5 >> final-verification.log 2>&1
echo "" >> final-verification.log

echo "VERIFICACIÓN COMPLETADA - Revisar final-verification.log"
