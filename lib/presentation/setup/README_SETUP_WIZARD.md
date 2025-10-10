# Setup Wizard

El Setup Wizard es un flujo de configuración inicial que guía al usuario a través de 7 pasos para configurar la aplicación Nebu.

## 📱 Screens del Setup Wizard

### 1. WelcomeScreen
- Pantalla de bienvenida con información sobre la app
- Muestra características principales (Voice Commands, AI Assistant, Notifications)
- Opción de saltar el setup

### 2. PermissionsScreen
- Solicita permisos necesarios (Microphone, Notifications, Camera)
- Manejo de permisos con permission_handler
- Opción de abrir configuraciones del sistema

### 3. ProfileSetupScreen
- Configuración de perfil de usuario
- Campos: Nombre completo, Email, Avatar
- Validación de formularios
- Selector de avatar con opciones predeterminadas

### 4. PreferencesScreen
- Configuración de idioma y tema
- Selección de idioma (EN, ES, FR, DE, PT, IT)
- Selección de tema (System, Light, Dark)
- Configuraciones adicionales (Haptic, Auto-save, Analytics)

### 5. VoiceSetupScreen
- Configuración de funciones de voz
- Prueba de reconocimiento de voz
- Configuración de síntesis de voz
- Animaciones interactivas

### 6. NotificationsScreen
- Configuración de notificaciones
- Tipos de notificaciones (Push, Reminders, Voice, Updates, Marketing)
- Configuración de horas silenciosas
- Vista previa de notificaciones

### 7. CompletionScreen
- Pantalla de finalización
- Animación de éxito
- Resumen de configuración
- Botón para iniciar la app

## 🎛️ SetupWizardController

Controlador que maneja la lógica del setup wizard:

```dart
// Funciones principales
nextStep()           // Avanzar al siguiente paso
previousStep()       // Retroceder al paso anterior
goToStep(int step)   // Ir a un paso específico
completeSetup()      // Finalizar setup y navegar a main
skipSetup()          // Saltar setup completo
canProceed()         // Verificar si puede continuar

// Datos del formulario
userName             // Nombre del usuario
userEmail            // Email del usuario
avatarUrl            // URL del avatar
selectedLanguage     // Idioma seleccionado
selectedTheme        // Tema seleccionado
notificationsEnabled // Notificaciones habilitadas
voiceEnabled         // Voz habilitada

// Permisos
microphonePermission     // Permiso de micrófono
cameraPermission         // Permiso de cámara
notificationsPermission  // Permiso de notificaciones
```

## 🎨 Componentes Reutilizables

### CustomButton
Botón personalizado con múltiples variantes:
- `ButtonVariant.primary` - Botón principal con gradiente
- `ButtonVariant.secondary` - Botón secundario
- `ButtonVariant.outline` - Botón con borde

### CustomInput
Campo de entrada personalizado con:
- Validación integrada
- Iconos prefijo/sufijo
- Soporte para contraseñas
- Mensajes de error

### GradientText
Texto con gradiente aplicado usando ShaderMask.

### SetupProgressIndicator
Indicador de progreso que muestra el paso actual y porcentaje.

## 🚀 Uso

```dart
// Navegar al setup wizard
Get.to(() => const SetupWizardScreen());

// O usar en rutas
GetPage(
  name: '/setup',
  page: () => const SetupWizardScreen(),
)
```

## 🔧 Configuración Requerida

### Dependencias necesarias:
```yaml
dependencies:
  get: ^4.6.6
  permission_handler: ^11.0.1
```

### Permisos en Android (android/app/src/main/AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### Permisos en iOS (ios/Runner/Info.plist):
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone for voice commands</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera for photo capture</string>
```

## 🎯 Características

- ✅ Navegación fluida entre pasos
- ✅ Validación de formularios
- ✅ Manejo de permisos
- ✅ Animaciones suaves
- ✅ Tema oscuro/claro
- ✅ Componentes reutilizables
- ✅ Responsive design
- ✅ Estado persistente
- ✅ Opción de saltar setup

## 📝 Notas de Implementación

1. **Estado**: Usa GetX para manejo de estado reactivo
2. **Navegación**: PageView con control deshabilitado para navegación manual
3. **Validación**: Validación en tiempo real con mensajes de error
4. **Permisos**: Manejo robusto de permisos con fallback a configuraciones
5. **Animaciones**: Animaciones personalizadas para mejor UX
6. **Temas**: Soporte completo para temas claro/oscuro

## 🔮 Próximas Mejoras

- [ ] Integración con backend para guardar configuración
- [ ] Soporte para más idiomas
- [ ] Configuración avanzada de voz
- [ ] Temas personalizados
- [ ] Configuración de accesibilidad
- [ ] Tutorial interactivo
- [ ] Configuración de privacidad avanzada
