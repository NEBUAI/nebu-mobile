# 🚦 Traefik Gateway Configuration

## 📁 Estructura del Directorio Gateway

```
gateway/
├── traefik.yml          # Configuración principal de Traefik
├── dynamic.yml          # Configuración dinámica (middlewares, routers)
├── letsencrypt/
│   └── acme.json       # Certificados SSL de Let's Encrypt
└── logs/
    ├── traefik.log     # Logs del sistema Traefik
    └── access.log      # Logs de acceso (formato JSON)
```

## ⚙️ Configuración

### 🔧 traefik.yml (Configuración Principal)
- **Entrypoints**: HTTP (80) y HTTPS (443) con redirección automática
- **Providers**: Docker con network isolation y file provider para dynamic.yml
- **SSL**: Let's Encrypt con HTTP Challenge automático
- **Logging**: Logs estructurados en JSON
- **API**: Dashboard seguro solo por HTTPS

### 🔄 dynamic.yml (Configuración Dinámica)
- **Middlewares de Seguridad**:
  - Headers de seguridad (HSTS, XSS Protection, etc.)
  - Rate limiting (100 req/min average, 200 burst)
  - CORS para API endpoints
  
- **Routers**:
  - Dashboard: `traefik.${DOMAIN}`
  - Métricas: `metrics.${DOMAIN}/metrics`

- **TLS Options**: 
  - Solo TLS 1.2 y 1.3
  - Cipher suites seguros

## 🚀 Servicios Expuestos

| Servicio          | URL                           | Descripción                  |
| ----------------- | ----------------------------- | ---------------------------- |
| Frontend          | `https://${DOMAIN}`           | Aplicación Next.js principal |
| Backend API       | `https://api.${DOMAIN}`       | API NestJS                   |
| Admin Panel       | `https://admin.${DOMAIN}`     | AdminJS Dashboard            |
| Traefik Dashboard | `https://traefik.${DOMAIN}`   | Panel de control de Traefik  |
| pgAdmin           | `https://pgadmin.${DOMAIN}`   | Admin PostgreSQL (dev)       |
| Portainer         | `https://portainer.${DOMAIN}` | Gestión Docker (management)  |

## 🔒 Seguridad Implementada

### SSL/TLS
- ✅ Certificados SSL automáticos con Let's Encrypt
- ✅ Redirección HTTP → HTTPS automática
- ✅ HSTS headers con max-age de 1 año
- ✅ Solo TLS 1.2+ y cipher suites seguros

### Headers de Seguridad
- ✅ `X-Frame-Options: DENY`
- ✅ `X-Content-Type-Options: nosniff`
- ✅ `X-XSS-Protection: 1; mode=block`
- ✅ `Strict-Transport-Security`
- ✅ `Referrer-Policy: strict-origin-when-cross-origin`

### Rate Limiting
- ✅ 100 requests/minuto promedio
- ✅ Burst de hasta 200 requests
- ✅ Ventana deslizante de 1 minuto

## 📊 Monitoreo

### Logs
- **traefik.log**: Logs del sistema en formato estructurado
- **access.log**: Logs de acceso en JSON para análisis

### Métricas
- ✅ Métricas de Prometheus habilitadas
- ✅ Labels por entrypoint y servicio
- ✅ Endpoint `/metrics` expuesto de forma segura

## 🔧 Variables de Entorno Requeridas

```bash
# En .env o docker.env
DOMAIN=outliers.academy
ACME_EMAIL=admin@outliers.academy
```

## 🚨 Notas Importantes

1. **acme.json**: Permisos 600 (solo lectura/escritura propietario)
2. **Primer arranque**: Los certificados SSL se generan automáticamente
3. **Renovación**: Automática cada 60 días
4. **Backup**: Incluir `gateway/letsencrypt/acme.json` en backups

## 🐛 Troubleshooting

### Verificar certificados
```bash
docker logs outliers-traefik | grep -i acme
```

### Ver configuración cargada
- Dashboard: `https://traefik.${DOMAIN}`
- Sección "Configuration" muestra providers activos

### Logs en tiempo real
```bash
docker logs -f outliers-traefik
tail -f gateway/logs/access.log | jq
```
