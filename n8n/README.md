# N8N - Automatización de Flujos de Trabajo

Este directorio contiene la configuración de N8N para Outliers Academy, una herramienta de automatización de flujos de trabajo que permite conectar diferentes servicios y automatizar tareas.

## 🚀 Características

- **Automatización de flujos**: Crear workflows complejos sin código
- **Integración con APIs**: Conectar con servicios externos
- **Webhooks**: Recibir y procesar datos en tiempo real
- **Base de datos**: Almacenamiento persistente en PostgreSQL
- **Autenticación**: Acceso seguro con autenticación básica
- **Métricas**: Monitoreo de rendimiento y uso

## 📋 Configuración

### Variables de Entorno

Las siguientes variables están configuradas en el contenedor:

```bash
# Configuración básica
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http

# Autenticación
N8N_BASIC_AUTH_ACTIVE=true
N8N_USER=admin
N8N_PASSWORD=admin123

# Base de datos
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_DATABASE=n8n_db
DB_POSTGRESDB_USER=outliers_academy

# Logging y métricas
N8N_LOG_LEVEL=info
N8N_METRICS=true
```

### Acceso

- **URL**: http://localhost:5678
- **Usuario**: admin
- **Contraseña**: admin123

## 🔧 Uso

### Iniciar N8N

```bash
# Levantar solo N8N
docker-compose up n8n -d

# Levantar todo el stack
docker-compose up -d
```

### Verificar estado

```bash
# Ver logs
docker-compose logs n8n

# Verificar salud
docker-compose ps n8n
```

## 📊 Casos de Uso para Outliers Academy

### 1. Automatización de Notificaciones
- Enviar emails cuando un usuario completa un curso
- Notificar a instructores sobre nuevas preguntas
- Alertas de progreso de estudiantes

### 2. Integración con Sistemas Externos
- Sincronización con CRM
- Integración con herramientas de marketing
- Conexión con sistemas de pago

### 3. Procesamiento de Datos
- Análisis de progreso de estudiantes
- Generación de reportes automáticos
- Limpieza y transformación de datos

### 4. Webhooks
- Recibir notificaciones de Stripe
- Procesar formularios de contacto
- Integración con servicios de terceros

## 🔒 Seguridad

- Autenticación básica habilitada
- Conexión segura a base de datos
- Encriptación de datos sensibles
- Logs de auditoría

## 📈 Monitoreo

- Métricas de rendimiento habilitadas
- Logs estructurados
- Health checks automáticos
- Integración con sistema de monitoreo

## 🛠️ Desarrollo

### Estructura de archivos

```
n8n/
├── n8n.config.js      # Configuración principal
├── n8n.env           # Variables de entorno
├── init-n8n.sh       # Script de inicialización
└── README.md         # Documentación
```

### Personalización

Para personalizar la configuración:

1. Modificar `n8n.config.js` para cambios de configuración
2. Actualizar `n8n.env` para variables de entorno
3. Reiniciar el contenedor: `docker-compose restart n8n`

## 🔗 Enlaces Útiles

- [Documentación oficial de N8N](https://docs.n8n.io/)
- [Nodos disponibles](https://docs.n8n.io/integrations/)
- [Ejemplos de workflows](https://n8n.io/workflows/)
- [API Reference](https://docs.n8n.io/api/)
