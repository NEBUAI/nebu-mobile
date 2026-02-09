# 🚀 Deploy a Google Play Store con Gradle

## ✅ Configuración completada

Ya está configurado Gradle Play Publisher para automatizar el deploy.

## 📋 Pasos para activar:

### 1. Obtén las credenciales de Service Account

Ve a [Google Play Console → API Access](https://play.google.com/console/developers/api-access):

1. Crea un Service Account (o usa uno existente)
2. Descarga el archivo JSON de credenciales
3. Dale permisos de **"Release Manager"** o **"Admin"**

### 2. Guarda las credenciales

```bash
# Copia el archivo JSON descargado a:
cp ~/Downloads/tu-service-account-key.json android/service-account.json
```

⚠️ Este archivo está en `.gitignore` (no se subirá a Git)

### 3. Genera el App Bundle

```bash
flutter build appbundle --release
```

### 4. Deploy automático

```bash
cd android
./gradlew publishReleaseBundle
```

✅ **Esto subirá automáticamente a Internal Testing en Play Console**

## 🎯 Comandos disponibles:

```bash
# Deploy a Internal Testing (por defecto)
./gradlew publishReleaseBundle

# Deploy a Alpha
./gradlew publishReleaseBundle -Ptrack=alpha

# Deploy a Beta
./gradlew publishReleaseBundle -Ptrack=beta

# Deploy a Production
./gradlew publishReleaseBundle -Ptrack=production
```

## 📝 Cambiar el track por defecto

Edita `android/app/build.gradle`:

```gradle
play {
    track = "beta"  // Cambia a: internal, alpha, beta, production
}
```

## 🔄 Workflow completo:

```bash
# 1. Compilar
flutter build appbundle --release

# 2. Deploy
cd android && ./gradlew publishReleaseBundle

# 3. ¡Listo! Ya está en Play Store
```

## 📚 Más información:

- [Gradle Play Publisher Docs](https://github.com/Triple-T/gradle-play-publisher)
- [Google Play Publishing API](https://developers.google.com/android-publisher)
