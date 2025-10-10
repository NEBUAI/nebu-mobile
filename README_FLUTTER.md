# Nebu Mobile - Flutter

Migración de la aplicación móvil Nebu de React Native a Flutter.

## 🚀 Estado del Proyecto

**Progreso Total: ~60%**

La base fundamental de la aplicación está completada y funcional. Pendientes features avanzadas y screens específicas.

## ✅ Completado

### Infraestructura Base
- ✅ Proyecto Flutter creado y configurado
- ✅ Todas las dependencias instaladas
- ✅ Estructura de carpetas (Clean Architecture)
- ✅ Configuración de entorno (.env)
- ✅ Sistema de temas (Light/Dark)
- ✅ Constantes y configuraciones

### Modelos de Datos (Freezed)
- ✅ User, AuthTokens, AuthResponse
- ✅ SocialAuthResult
- ✅ IoTDevice, DeviceStatus, IoTMetrics
- ✅ Code generation configurado

### Servicios
- ✅ **AuthService** - Login, registro, social auth, tokens, password reset
- ✅ **ApiService** - Cliente HTTP con Dio, interceptores, refresh token automático
- ✅ **BluetoothService** - Scan, conexión, servicios, características

### State Management (Riverpod)
- ✅ **AuthProvider** - Estado de autenticación completo
- ✅ **ThemeProvider** - Dark/Light mode
- ✅ **LanguageProvider** - Internacionalización EN/ES

### Navegación (go_router)
- ✅ Router configurado con guards de autenticación
- ✅ Bottom navigation con 4 tabs
- ✅ Rutas para todas las screens principales
- ✅ Deep linking preparado

### Screens Implementadas
- ✅ **SplashScreen** - Con animaciones
- ✅ **WelcomeScreen** - Pantalla de bienvenida
- ✅ **HomeScreen** - Dashboard principal con quick actions
- ✅ **ProfileScreen** - Perfil completo con settings
- ✅ **VoiceAgentScreen** - Placeholder para agente de voz
- ✅ **IoTDashboardScreen** - Dashboard de dispositivos IoT
- ✅ **DeviceManagementScreen** - Gestión de dispositivos
- ✅ **QRScannerScreen** - Escáner QR
- ✅ **MainScreen** - Bottom navigation container

### Configuración de Aplicación
- ✅ main.dart completo con inicialización de dependencias
- ✅ Providers configurados e integrados
- ✅ Temas aplicados
- ✅ Router integrado

## 📋 Pendiente

### Servicios Adicionales
- [ ] VoiceService - Integración con OpenAI
- [ ] LiveKitService - WebRTC
- [ ] RobotService - Control de robot
- [ ] DeviceTokenService - Push notifications

### Screens Setup Wizard
- [ ] ConnectionSetupScreen
- [ ] ToyNameSetupScreen
- [ ] AgeSetupScreen
- [ ] PersonalitySetupScreen
- [ ] VoiceSetupScreen
- [ ] FavoritesSetupScreen
- [ ] WorldInfoSetupScreen

### UI Components
- [ ] CustomButton con variantes
- [ ] CustomInput con validaciones
- [ ] GradientText
- [ ] StatusBadge
- [ ] AnimatedCard
- [ ] FloatingActionButton personalizado
- [ ] SocialLoginButton
- [ ] LoadingIndicator

### Funcionalidades Avanzadas
- [ ] Implementación completa de QR Scanner
- [ ] Integración con cámara
- [ ] Sistema de audio/voice completo
- [ ] Implementación de LiveKit
- [ ] Animaciones avanzadas
- [ ] Particle background

### Internacionalización
- [ ] Setup completo de easy_localization
- [ ] Migrar traducciones de React Native
- [ ] Archivos de traducción EN/ES

### Testing
- [ ] Unit tests para servicios
- [ ] Widget tests para componentes
- [ ] Integration tests

### Build & Deploy
- [ ] Configurar permisos Android
- [ ] Configurar permisos iOS
- [ ] Iconos y splash screens
- [ ] Configuración de release builds

## 🏗️ Arquitectura

```
lib/
├── core/                   # Configuración y utilidades
│   ├── constants/         # Constantes de la app
│   ├── theme/             # Temas Light/Dark
│   ├── router/            # Configuración de navegación
│   └── utils/             # Utilidades (env config)
│
├── data/                   # Capa de datos
│   ├── models/            # Modelos con Freezed
│   └── services/          # Servicios (API, Auth, BLE)
│
├── domain/                 # Lógica de negocio (pendiente)
│   └── entities/
│
├── presentation/           # UI Layer
│   ├── providers/         # Riverpod providers
│   ├── screens/           # Pantallas de la app
│   └── widgets/           # Componentes reutilizables
│
└── l10n/                   # Traducciones
```

## 🛠️ Tecnologías

- **Framework**: Flutter 3.27.3
- **Lenguaje**: Dart 3.6.1
- **State Management**: Riverpod 2.6+
- **Navegación**: go_router 14+
- **HTTP**: Dio 5+
- **Code Generation**: Freezed, json_serializable
- **Storage**: SharedPreferences + FlutterSecureStorage
- **Auth**: Google Sign In, Apple Sign In, Facebook Auth
- **IoT**: Flutter Blue Plus
- **Audio**: just_audio, audioplayers, record
- **Otros**: LiveKit, OpenAI, mobile_scanner

## 🚀 Cómo Ejecutar

### Prerequisitos

```bash
# Verificar Flutter instalado
flutter doctor

# Verificar dispositivos disponibles
flutter devices
```

### Ejecutar la App

```bash
# Instalar dependencias
flutter pub get

# Generar código (Freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar en modo debug
flutter run

# Ejecutar en dispositivo específico
flutter run -d <device-id>

# Ejecutar en web
flutter run -d chrome
```

### Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
# Backend API
URL_BACKEND=https://api.nebu.com
API_TIMEOUT=30000

# OpenAI
OPENAI_API_KEY=your_key_here

# LiveKit
LIVEKIT_URL=wss://your-server.com
LIVEKIT_API_KEY=your_key
LIVEKIT_API_SECRET=your_secret

# Social Auth
GOOGLE_WEB_CLIENT_ID=your_id
GOOGLE_IOS_CLIENT_ID=your_id
FACEBOOK_APP_ID=your_id

# Environment
APP_ENV=development
DEBUG_MODE=true
```

### Build para Producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📱 Screens

### Flujo Principal

1. **Splash** → Muestra logo con animación
2. **Welcome** → Pantalla de bienvenida (si no autenticado)
3. **Home** → Dashboard principal con:
   - Quick actions (Scan QR, Devices, IoT, Voice)
   - Bottom navigation (Home, Voice, IoT, Profile)

### Bottom Navigation

- **Home** - Dashboard con accesos rápidos
- **Voice** - Agente de voz (placeholder)
- **IoT** - Dashboard de dispositivos IoT
- **Profile** - Perfil y configuración

### Otras Screens

- **Device Management** - Gestión de dispositivos
- **QR Scanner** - Escaneo de códigos QR
- **Setup Wizard** - 7 screens de configuración inicial (pendiente)

## 🎨 Temas

La app incluye temas Light y Dark completamente configurados con:

- Paleta de colores personalizada (Indigo/Purple)
- Gradientes integrados
- Estilos de botones (Elevated, Outlined)
- Estilos de inputs
- Estilos de cards
- Bottom navigation personalizado

## 🔐 Autenticación

Soporta múltiples métodos:

- Email/Password
- Google Sign In
- Facebook Login
- Apple Sign In
- Refresh token automático
- Secure storage para tokens

## 📖 Documentación Adicional

- [MIGRATION_DOCS.md](MIGRATION_DOCS.md) - Análisis completo de migración desde React Native
- [FLUTTER_MIGRATION_STATUS.md](FLUTTER_MIGRATION_STATUS.md) - Estado detallado de la migración

## 🤝 Contribuir

Para continuar el desarrollo:

1. Implementar screens del setup wizard
2. Completar servicios (Voice, LiveKit, Robot)
3. Crear componentes UI reutilizables
4. Agregar traducciones completas
5. Implementar testing

## 📝 Notas

- El proyecto usa Clean Architecture con Riverpod
- Los modelos usan Freezed para inmutabilidad
- La navegación es declarativa con go_router
- Se prefiere composition over inheritance
- Todos los servicios usan dependency injection

---

**Última actualización**: 2025-10-10
