# Nebu Mobile App - Flutter

Una aplicación móvil moderna construida con Flutter, diseñada con una interfaz limpia y funcionalidades esenciales de IA y IoT.

## 🚀 Características

- **Flutter** - Framework moderno para desarrollo móvil multiplataforma
- **Dart** - Lenguaje de programación eficiente y tipado
- **Riverpod** - Gestión de estado reactiva y moderna
- **Go Router** - Navegación declarativa y type-safe
- **Tema Dinámico** - Soporte completo para modo claro y oscuro
- **Componentes Reutilizables** - UI consistente y modular
- **Internacionalización** - Soporte para múltiples idiomas
- **Arquitectura Limpia** - Estructura organizada con separación de responsabilidades

## 📱 Pantallas Principales

- **Splash Screen** - Pantalla de bienvenida con branding
- **Setup Wizard** - Configuración inicial de 7 pasos
- **Home** - Dashboard principal con acciones rápidas
- **IoT Dashboard** - Gestión de dispositivos IoT
- **Voice Agent** - Asistente de voz con IA
- **Profile** - Configuración de usuario
- **QR Scanner** - Escáner para dispositivos

## 🛠️ Tecnologías

### Core
- **Flutter 3.27.3** - Framework principal
- **Dart 3.6.1** - Lenguaje de programación

### State Management
- **Riverpod 2.5.1** - Gestión de estado reactiva
- **Get 4.6.6** - Navegación y dependencias

### Networking & API
- **Dio 5.4.3** - Cliente HTTP
- **Retrofit 4.1.0** - Generación de APIs

### Storage
- **SharedPreferences 2.2.3** - Almacenamiento local
- **Flutter Secure Storage 9.0.0** - Almacenamiento seguro

### Authentication
- **Google Sign In 6.2.1** - Autenticación con Google
- **Sign in with Apple 6.1.0** - Autenticación con Apple
- **Flutter Facebook Auth 7.0.1** - Autenticación con Facebook

### Hardware & Permissions
- **Flutter Blue Plus 1.32.11** - Bluetooth Low Energy
- **Permission Handler 11.3.1** - Manejo de permisos
- **Camera 0.11.0+1** - Acceso a cámara

### Audio & Voice
- **AudioPlayers 6.0.0** - Reproducción de audio
- **Just Audio 0.9.37** - Audio streaming
- **Record 5.1.0** - Grabación de audio

### AI & Communication
- **LiveKit Client 2.1.2** - WebRTC y comunicación en tiempo real
- **Dart OpenAI 5.1.0** - Integración con OpenAI

### UI & UX
- **Cached Network Image 3.3.1** - Carga optimizada de imágenes
- **Shimmer 3.0.0** - Efectos de carga
- **Flutter SVG 2.0.10+1** - Soporte para SVG

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/          # Constantes de la aplicación
│   ├── router/            # Configuración de rutas
│   ├── theme/             # Temas y estilos
│   └── utils/             # Utilidades generales
├── data/
│   ├── models/            # Modelos de datos (Freezed)
│   ├── repositories/      # Repositorios de datos
│   └── services/          # Servicios de API y hardware
├── domain/
│   └── entities/          # Entidades del dominio
├── presentation/
│   ├── providers/         # Providers de estado
│   ├── screens/           # Pantallas de la aplicación
│   ├── setup/             # Setup Wizard completo
│   └── widgets/           # Componentes reutilizables
└── l10n/                  # Archivos de localización
```

## 🚀 Instalación y Configuración

### Prerrequisitos
- Flutter SDK 3.27.3 o superior
- Dart SDK 3.6.1 o superior
- Android Studio / Xcode
- Git

### Pasos de instalación

1. **Clonar el repositorio**
```bash
git clone <repository-url>
cd nebu-mobile
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar código**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configurar variables de entorno**
```bash
# Crear archivo .env en la raíz del proyecto
cp .env.example .env
# Editar con tus configuraciones
```

5. **Ejecutar la aplicación**
```bash
# Para desarrollo
flutter run

# Para release
flutter run --release
```

## 🔧 Configuración de Desarrollo

### Variables de Entorno
Crear archivo `.env` con:
```env
OPENAI_API_KEY=your_openai_api_key
LIVEKIT_API_KEY=your_livekit_api_key
LIVEKIT_API_SECRET=your_livekit_secret
API_BASE_URL=https://your-api-url.com
```

### Permisos Android
Agregar en `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Permisos iOS
Agregar en `ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth for device connection</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for QR scanning</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone for voice commands</string>
```

## 🧪 Testing

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

## 📦 Build

### Android
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (recomendado para Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build para iOS
flutter build ios --release
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Soporte

Para soporte y preguntas:
- Crear un issue en GitHub
- Contactar al equipo de desarrollo

---

**Desarrollado con ❤️ usando Flutter**