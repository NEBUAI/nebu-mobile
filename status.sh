#!/bin/bash
echo "=== ESTADO ACTUAL ==="
docker ps -a
echo ""
echo "=== INTENTANDO LEVANTAR LIVEKIT ==="
docker-compose up -d livekit
sleep 10
echo ""
echo "=== ESTADO DESPUÉS DE LIVEKIT ==="
docker ps | grep nebu-mobile
echo ""
echo "=== INTENTANDO LEVANTAR BACKEND ==="
docker-compose up -d backend
sleep 15
echo ""
echo "=== ESTADO FINAL ==="
docker ps | grep nebu-mobile
