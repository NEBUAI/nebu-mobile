# Nebu Mobile App

Una aplicación móvil moderna construida con React Native y Expo, diseñada con una interfaz limpia y funcionalidades esenciales.

## 🚀 Características

- **React Native + Expo** - Framework moderno para desarrollo móvil multiplataforma
- **TypeScript** - Tipado estático para mejor desarrollo y mantenimiento
- **Redux Toolkit** - Gestión de estado global eficiente
- **React Navigation** - Navegación nativa fluida
- **Tema Dinámico** - Soporte para modo claro y oscuro
- **Componentes Reutilizables** - UI consistente y modular
- **Arquitectura Escalable** - Estructura organizada de carpetas

## 📱 Pantallas Principales

- **Splash Screen** - Pantalla de bienvenida con branding
- **Login** - Autenticación de usuario con validación
- **Home** - Dashboard principal con acciones rápidas
- **Profile** - Perfil de usuario y configuraciones

## 🛠️ Tecnologías Utilizadas

- React Native 0.73.4
- Expo SDK 50
- TypeScript 5.3.3
- Redux Toolkit 2.0.1
- React Navigation 6.x
- Expo Vector Icons

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- **Node.js** (versión 18 o superior)
- **npm** o **yarn**
- **Expo CLI** (opcional pero recomendado)
- **Android Studio** (para desarrollo Android)
- **Xcode** (para desarrollo iOS - solo macOS)

### Instalación de Expo CLI

```bash
npm install -g @expo/cli
```

## 🚀 Instalación y Configuración

### 1. Clonar el repositorio

```bash
git clone <repository-url>
cd nebu-mobile
```

### 2. Instalar dependencias

```bash
npm install
# o
yarn install
```

### 3. Ejecutar la aplicación

#### Modo de desarrollo

```bash
npm start
# o
expo start
```

#### Ejecutar en Android

```bash
npm run android
# o
expo start --android
```

#### Ejecutar en iOS

```bash
npm run ios
# o
expo start --ios
```

#### Ejecutar en Web

```bash
npm run web
# o
expo start --web
```

## 📱 Ejecutar en Dispositivo Físico

### Android

1. Habilita la **Depuración USB** en tu dispositivo Android
2. Conecta tu dispositivo via USB
3. Ejecuta `npm run android`

### iOS

1. Instala **Expo Go** desde la App Store
2. Ejecuta `npm start`
3. Escanea el código QR con la cámara de tu iPhone

## 🏗️ Estructura del Proyecto

```
nebu-mobile/
├── src/
│   ├── components/          # Componentes reutilizables
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Header.tsx
│   │   └── index.ts
│   ├── screens/             # Pantallas principales
│   │   ├── SplashScreen.tsx
│   │   ├── LoginScreen.tsx
│   │   ├── HomeScreen.tsx
│   │   ├── ProfileScreen.tsx
│   │   └── index.ts
│   ├── navigation/          # Configuración de navegación
│   │   ├── RootNavigator.tsx
│   │   ├── AuthNavigator.tsx
│   │   ├── MainNavigator.tsx
│   │   └── index.ts
│   ├── store/              # Estado global (Redux)
│   │   ├── index.ts
│   │   ├── authSlice.ts
│   │   ├── themeSlice.ts
│   │   └── hooks.ts
│   ├── types/              # Definiciones de TypeScript
│   │   └── index.ts
│   └── utils/              # Utilidades y temas
│       └── theme.ts
├── assets/                 # Recursos estáticos
│   ├── icon.png
│   ├── splash.png
│   ├── adaptive-icon.png
│   └── favicon.png
├── App.tsx                 # Componente principal
├── app.json               # Configuración de Expo
├── package.json
├── tsconfig.json
└── README.md
```

## 🎨 Sistema de Temas

La aplicación incluye un sistema de temas robusto con soporte para modo claro y oscuro:

### Colores Principales

- **Primary**: #007AFF (Azul iOS)
- **Success**: #34C759
- **Warning**: #FF9500
- **Error**: #FF3B30

### Uso del Tema

```typescript
import { useAppSelector } from '@/store/hooks';
import { getTheme } from '@/utils/theme';

const isDarkMode = useAppSelector((state) => state.theme.isDarkMode);
const theme = getTheme(isDarkMode);
```

## 🔧 Scripts Disponibles

- `npm start` - Inicia el servidor de desarrollo
- `npm run android` - Ejecuta en emulador/dispositivo Android
- `npm run ios` - Ejecuta en simulador/dispositivo iOS
- `npm run web` - Ejecuta en navegador web
- `npm run lint` - Ejecuta ESLint para verificar código
- `npm run type-check` - Verifica tipos de TypeScript
- `npm run build:android` - Construye APK para Android
- `npm run build:ios` - Construye IPA para iOS

## 📦 Construcción para Producción

### Android (APK)

```bash
npm run build:android
```

### iOS (IPA)

```bash
npm run build:ios
```

## 🧪 Testing

Para ejecutar pruebas (cuando estén configuradas):

```bash
npm test
```

## 📝 Configuración de Desarrollo

### ESLint

El proyecto incluye configuración de ESLint para mantener calidad de código:

```bash
npm run lint
```

### TypeScript

Verificar tipos sin compilar:

```bash
npm run type-check
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🆘 Solución de Problemas

### Error: Metro bundler no inicia

```bash
npx expo start --clear
```

### Error: Dependencias no encontradas

```bash
rm -rf node_modules
npm install
```

### Error: Cache de Expo

```bash
npx expo start --clear
```

### Problemas con Android

1. Verifica que Android SDK esté instalado
2. Configura las variables de entorno ANDROID_HOME
3. Acepta las licencias de Android SDK

### Problemas con iOS

1. Verifica que Xcode esté instalado (solo macOS)
2. Instala Xcode Command Line Tools
3. Acepta las licencias de Xcode

## 📞 Soporte

Para soporte técnico o preguntas:

- Crea un issue en el repositorio
- Revisa la documentación de [Expo](https://docs.expo.dev/)
- Consulta la documentación de [React Native](https://reactnative.dev/)

---

**Nebu** - Conectando el futuro 🚀
