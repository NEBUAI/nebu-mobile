# Documentación de Migración: React Native → Flutter

## Resumen de la Aplicación Actual

### Arquitectura
- **Framework**: React Native + Expo
- **Lenguaje**: TypeScript
- **State Management**: Redux Toolkit
- **Navegación**: React Navigation (Stack + Bottom Tabs)
- **Internacionalización**: i18next (ES/EN)

### Servicios Principales

#### 1. AuthService (`src/services/authService.ts`)
**Funcionalidades:**
- Login/Register con email/password
- Social Auth (Google, Facebook, Apple)
- Token management (access + refresh tokens)
- Password reset
- Email verification

**Equivalentes Flutter:**
```yaml
# pubspec.yaml
dependencies:
  dio: ^5.4.0  # HTTP client (reemplaza axios)
  shared_preferences: ^2.2.0  # Storage (reemplaza AsyncStorage)
  google_sign_in: ^6.1.0
  sign_in_with_apple: ^5.0.0
  flutter_facebook_auth: ^6.0.0
```

#### 2. BluetoothService (`src/services/bluetoothService.ts`)
**Funcionalidades:**
- Conexión BLE con dispositivos
- Scan de dispositivos
- Gestión de permisos

**Equivalentes Flutter:**
```yaml
dependencies:
  flutter_blue_plus: ^1.31.0
  permission_handler: ^11.0.0
```

#### 3. OpenAI Voice Service (`src/services/openaiVoiceService.ts`)
**Funcionalidades:**
- Integración con OpenAI API
- Manejo de audio

**Equivalentes Flutter:**
```yaml
dependencies:
  openai_dart: ^0.2.0
  audioplayers: ^5.2.0
  record: ^5.0.0
```

#### 4. LiveKit Service (`src/services/livekitService.ts`)
**Funcionalidades:**
- WebRTC comunicación en tiempo real

**Equivalentes Flutter:**
```yaml
dependencies:
  livekit_client: ^2.0.0
```

#### 5. API Service (`src/services/api.ts`)
**Funcionalidades:**
- Cliente HTTP centralizado
- Interceptores para tokens

**Equivalentes Flutter:**
- Dio con interceptores

### Estado (Redux Slices)

#### authSlice
```typescript
interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
```

#### themeSlice
```typescript
interface ThemeState {
  isDarkMode: boolean;
}
```

#### languageSlice
```typescript
interface LanguageState {
  currentLanguage: 'en' | 'es';
}
```

#### iotSlice
```typescript
interface IoTState {
  devices: Device[];
  connectedDevice: Device | null;
  isScanning: boolean;
}
```

**State Management en Flutter:**
Opciones recomendadas:
1. **Riverpod** (recomendado) - Moderno, type-safe, testable
2. **Bloc/Cubit** - Pattern similar a Redux
3. **Provider** - Simple, oficial de Flutter

### Navegación

```
Root
├── Splash
├── Auth (si no autenticado)
│   ├── Welcome
│   ├── Login
│   └── Register
└── HomeStack (autenticado o bypass)
    ├── Setup Flow
    │   ├── ConnectionSetup
    │   ├── ToyNameSetup
    │   ├── AgeSetup
    │   ├── PersonalitySetup
    │   ├── VoiceSetup
    │   ├── FavoritesSetup
    │   └── WorldInfoSetup
    └── Main (Bottom Tabs)
        ├── Home
        ├── VoiceAgent
        ├── IoTDashboard
        ├── DeviceManagement
        └── Profile
```

**Equivalente Flutter:**
```yaml
dependencies:
  go_router: ^13.0.0  # Navegación declarativa
  # o
  auto_route: ^7.8.0  # Generación de código para rutas
```

### Screens Identificadas

1. **SplashScreen**
2. **WelcomeScreen**
3. **HomeScreen**
4. **ProfileScreen**
5. **VoiceAgentScreen**
6. **IoTDashboardScreen**
7. **DeviceManagementScreen**
8. **QRScannerScreen**
9. **RobotSetupScreenMock**
10. **Setup Wizard (7 screens)**

### Componentes UI Reutilizables

1. **Button** - Botón personalizado
2. **AnimatedButton** - Botón con animaciones
3. **PrimaryButton** - Botón principal de auth
4. **SocialLoginButton** - Botones de redes sociales
5. **Input** / **ModernInput** - Inputs de texto
6. **Header** - Header de navegación
7. **GradientText** - Texto con gradiente
8. **StatusBadge** - Badge de estado
9. **QRCodeScanner** - Escáner QR
10. **LanguageSelector** - Selector de idioma
11. **FloatingActionButton** - FAB
12. **ParticleBackground** - Fondo animado
13. **AnimatedCard** - Card con animación

### Dependencias Críticas Mapeadas

| React Native | Flutter |
|--------------|---------|
| `@react-navigation/*` | `go_router` o `auto_route` |
| `@reduxjs/toolkit` + `react-redux` | `riverpod` o `bloc` |
| `axios` | `dio` |
| `@react-native-async-storage/async-storage` | `shared_preferences` |
| `@react-native-google-signin/google-signin` | `google_sign_in` |
| `expo-apple-authentication` | `sign_in_with_apple` |
| `react-native-fbsdk-next` | `flutter_facebook_auth` |
| `react-native-ble-plx` | `flutter_blue_plus` |
| `expo-camera` | `camera` + `mobile_scanner` |
| `i18next` + `react-i18next` | `easy_localization` o `flutter_localizations` |
| `expo-av` | `audioplayers` + `just_audio` |
| `livekit-react-native` | `livekit_client` |
| `openai` | `openai_dart` |
| `expo-linear-gradient` | `flutter/widgets` (LinearGradient built-in) |
| `react-native-permissions` | `permission_handler` |
| `react-native-keychain` | `flutter_secure_storage` |

### Configuración de Entorno
- Variables de entorno en `.env` → usar `flutter_dotenv` o `envied`

### Plan de Migración Paso a Paso

#### Fase 1: Setup Inicial ✓
- [x] Análisis de arquitectura actual
- [ ] Crear proyecto Flutter
- [ ] Configurar estructura de carpetas
- [ ] Setup de dependencias base

#### Fase 2: Capa de Datos
- [ ] Modelos de datos (User, Device, etc.)
- [ ] API Service con Dio
- [ ] Auth Service
- [ ] Bluetooth Service
- [ ] Voice Service
- [ ] LiveKit Service

#### Fase 3: State Management
- [ ] Setup de Riverpod/Bloc
- [ ] Auth Provider/Bloc
- [ ] Theme Provider
- [ ] Language Provider
- [ ] IoT Provider

#### Fase 4: UI Base
- [ ] Theme configuration
- [ ] Componentes reutilizables
- [ ] Internacionalización

#### Fase 5: Navegación
- [ ] Setup de go_router/auto_route
- [ ] Definir rutas
- [ ] Guards de autenticación

#### Fase 6: Screens
- [ ] SplashScreen
- [ ] WelcomeScreen
- [ ] Auth screens
- [ ] Setup wizard
- [ ] Main screens (Home, Profile, etc.)

#### Fase 7: Features Avanzadas
- [ ] Social authentication
- [ ] Bluetooth connectivity
- [ ] Voice agent
- [ ] QR Scanner
- [ ] LiveKit integration

#### Fase 8: Testing & Polish
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Performance optimization
- [ ] UI/UX refinements

#### Fase 9: Build & Deploy
- [ ] Android build configuration
- [ ] iOS build configuration
- [ ] CI/CD setup

## Notas Importantes

1. **Flutter tiene gradientes built-in** - No necesitas librería externa
2. **Manejo de permisos** es más directo en Flutter con `permission_handler`
3. **Animaciones** - Flutter tiene AnimationController y Hero transitions nativas
4. **Responsive design** - Usa `MediaQuery` y `LayoutBuilder`
5. **Testing** - Flutter tiene mejor soporte para testing desde el inicio

## Recomendaciones

1. **Empezar con MVP**: Migrar auth + navegación básica primero
2. **State Management**: Riverpod es la opción más moderna
3. **Navegación**: go_router es declarativo y más simple
4. **Testing**: Escribir tests desde el inicio
5. **Estructura de carpetas recomendada**:
```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   └── entities/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   └── providers/ (o blocs/)
├── l10n/
└── main.dart
```
