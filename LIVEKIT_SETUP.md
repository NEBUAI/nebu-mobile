# LiveKit IoT Setup Guide 🚀

Esta app está configurada para conectarse a **LiveKit Cloud** como dispositivo IoT con las credenciales proporcionadas. Todo está listo para usar!

## ⚡ Configuración Automática

Las credenciales están pre-configuradas en el archivo `.env`:

```bash
LIVEKIT_URL=wss://brody-v541z1he.livekit.cloud
LIVEKIT_API_KEY=APiGHveqSVySCUp
LIVEKIT_API_SECRET=ES8dDuwnbOvLQZVwwuwXjyJIxuZBde524Ecz9IkDaZQ
DEFAULT_IOT_ROOM=nebu-iot-room
DEFAULT_PARTICIPANT_PREFIX=nebu-mobile
```

## 📦 Dependencias Instaladas

- `@livekit/react-native`: SDK oficial de LiveKit para React Native
- `@livekit/react-native-webrtc`: WebRTC para React Native
- `livekit-client`: Cliente JavaScript de LiveKit
- `react-native-get-random-values`: Polyfills para React Native

## 🔧 Configuración Creada

### 1. Servicio LiveKit (`src/services/livekitService.ts`)
- Clase `LiveKitIoTService` para manejar conexiones
- Métodos para enviar/recibir datos IoT
- Manejo de eventos de conexión
- Generación de tokens de acceso

### 2. Redux Store (`src/store/iotSlice.ts`)
- Estados de conexión
- Lista de dispositivos IoT conectados
- Historial de datos recientes
- Acciones async para conectar/desconectar

### 3. Pantalla Dashboard (`src/screens/IoTDashboardScreen.tsx`)
- Interfaz completa para gestionar dispositivos IoT
- Estados de conexión en tiempo real
- Lista de dispositivos conectados
- Historial de datos recibidos
- Modal para configurar conexión

## 🚀 Cómo Usar (¡Ya está listo!)

### 1. Ejecutar la app
```bash
npm start
# o
expo start
```

### 2. Conectar a LiveKit
1. Navega a la pestaña **"IoT Devices"** 
2. Toca **"Connect"**
3. Los valores por defecto ya están configurados:
   - ✅ **Server URL**: Auto-configurado desde `.env`
   - ✅ **Room Name**: `nebu-iot-room`
   - ✅ **Participant Name**: Se genera automáticamente
4. Toca **"Connect"** para conectarte

### 3. Probar funcionalidad
- **"Send Test Data"**: Envía datos de sensores simulados
- **"Run Tests"**: Ejecuta pruebas automáticas de conexión

## 🔧 Datos de Ejemplo

Los datos que se envían tienen esta estructura:
```typescript
const iotData: IoTDeviceData = {
  deviceId: 'mobile-test-device',
  deviceType: 'sensor',
  data: {
    temperature: 23.5,        // °C
    humidity: 65.2,           // %
    pressure: 1013.25,        // hPa
    battery: 85,              // %
    signal: 92,               // %
    timestamp: Date.now()
  },
  timestamp: Date.now()
};
```

## 📱 Funcionalidades

### Dashboard IoT
- ✅ Estado de conexión en tiempo real
- ✅ Lista de dispositivos conectados
- ✅ Historial de datos recientes
- ✅ Envío de datos de prueba
- ✅ Configuración de conexión

### Gestión de Dispositivos
- ✅ Auto-detección de nuevos dispositivos
- ✅ Estados online/offline
- ✅ Última vez visto
- ✅ Datos más recientes por dispositivo

### Comunicación en Tiempo Real
- ✅ Envío de datos bi-direccional
- ✅ Eventos de conexión/desconexión
- ✅ Manejo de errores
- ✅ Reconexión automática

## 🧪 Pruebas Automáticas

La app incluye un sistema de pruebas integrado:

- **Prueba de Conexión**: Verifica conectividad con LiveKit
- **Prueba de Datos**: Valida envío de información IoT
- **Acceso desde Dashboard**: Botón "Run Tests" en la interfaz

## 🔒 Seguridad & Producción

⚠️ **Importante**: Las credenciales actuales son para desarrollo. Para producción:

1. **Genera tokens en el backend**: Nunca expongas API secrets en el cliente
2. **Usa HTTPS/WSS**: Conexiones seguras siempre
3. **Permisos granulares**: Configura acceso por dispositivo
4. **Rotación de tokens**: Implementa expiración y renovación

## 🛠 Comandos Útiles

```bash
# Instalar dependencias
npm install

# Ejecutar app
npm start

# Verificar tipos TypeScript  
npm run type-check

# Linting
npm run lint

# Limpiar cache de Metro
npx expo start --clear
```

## 📚 Recursos

- [LiveKit Docs](https://docs.livekit.io/)
- [React Native SDK](https://docs.livekit.io/realtime/client/react-native/)
- [Server SDK](https://docs.livekit.io/realtime/server/generating-tokens/)