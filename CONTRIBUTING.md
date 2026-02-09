# Contribuir a Nebu Mobile

## Estrategia de ramas (GitHub Flow)

Usamos **GitHub Flow**: `main` es la rama de produccion. Todo cambio entra via Pull Request.

```
main (produccion)
 └── feat/nueva-funcionalidad   ← feature branch
 └── fix/corregir-bug           ← fix branch
```

### Flujo de trabajo

1. Crear rama desde `main` con el prefijo adecuado
2. Desarrollar y hacer commits con formato Conventional Commits
3. Abrir Pull Request a `main`
4. Esperar que pase el CI (analyze + test + build)
5. Solicitar review (si aplica)
6. Merge a `main`

### Nombres de ramas

| Prefijo       | Uso                          | Ejemplo                     |
|---------------|------------------------------|-----------------------------|
| `feat/`       | Nueva funcionalidad          | `feat/bluetooth-scan`       |
| `fix/`        | Correccion de bugs           | `fix/login-crash`           |
| `refactor/`   | Refactorizacion sin cambio funcional | `refactor/auth-service` |
| `docs/`       | Documentacion                | `docs/readme-update`        |
| `chore/`      | Tareas de mantenimiento      | `chore/update-dependencies` |

## Conventional Commits

Cada commit debe seguir el formato:

```
<tipo>: <descripcion corta>

[cuerpo opcional]
```

### Tipos

- `feat:` nueva funcionalidad
- `fix:` correccion de bug
- `refactor:` cambio de codigo sin alterar comportamiento
- `docs:` cambios en documentacion
- `chore:` mantenimiento, dependencias, CI
- `test:` agregar o modificar tests
- `style:` formato, espacios, sin cambios de logica

### Ejemplos

```
feat: agregar escaneo BLE en pantalla principal
fix: corregir crash al desconectar dispositivo
chore: actualizar Flutter a 3.35.6
```

## CI/CD

### CI (automatico en PRs)

El workflow `ci.yml` se ejecuta en cada PR a `main` y en cada push a `main`:

- `flutter analyze` - analisis estatico
- `flutter test` - tests unitarios
- `flutter build apk --debug` - verificacion de compilacion

### Produccion (manual o por tag)

Los builds de produccion se disparan al crear un tag con formato `v*.*.*`:

```bash
git tag v1.1.0
git push origin v1.1.0
```

Esto ejecuta los workflows de build para Android (`build-production.yml`) e iOS (`build-production-ios.yml`).

## Releases y versionamiento

Usamos [Semantic Versioning](https://semver.org/):

- **MAJOR** (`v2.0.0`): cambios incompatibles
- **MINOR** (`v1.1.0`): nueva funcionalidad compatible
- **PATCH** (`v1.0.1`): correcciones de bugs

### Crear un release

1. Actualizar `CHANGELOG.md` con los cambios
2. Actualizar version en `pubspec.yaml`
3. Commit: `chore: release v1.x.x`
4. Crear tag: `git tag v1.x.x`
5. Push: `git push origin main --tags`

## Branch protection (configuracion en GitHub)

Configurar en **Settings > Branches > Branch protection rules** para `main`:

- [x] Require a pull request before merging
- [x] Require status checks to pass before merging
  - Seleccionar el check `Analyze, Test & Build`
- [x] Do not allow force pushes

## Setup local

```bash
# Clonar el repositorio
git clone <repo-url>
cd nebu-mobile

# Instalar dependencias
flutter pub get

# Crear archivo .env (no se commitea)
touch .env

# Verificar que todo funciona
flutter analyze
flutter test
flutter run
```
