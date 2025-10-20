# Comandos Útiles para el Proyecto

## 🚀 Ejecutar la Aplicación

### Modo Local (sin Supabase)
```bash
./run.sh local
# o simplemente
flutter run
```

### Con Supabase
```bash
export SUPABASE_URL="https://tu-proyecto.supabase.co"
export SUPABASE_ANON_KEY="tu_anon_key"
./run.sh supabase

# O en una sola línea:
SUPABASE_URL="xxx" SUPABASE_ANON_KEY="xxx" flutter run \
  --dart-define=SUPABASE_URL="xxx" \
  --dart-define=SUPABASE_ANON_KEY="xxx"
```

## 🔧 Desarrollo

### Generar código de Drift (después de cambios en database.dart)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Generar código en watch mode (se regenera automáticamente)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Ver estructura de carpetas
```bash
tree lib -L 3 -I '*.g.dart'
```

### Actualizar dependencias
```bash
flutter pub upgrade
```

### Ver dependencias desactualizadas
```bash
flutter pub outdated
```

## 📊 Análisis y Calidad

### Análisis estático
```bash
flutter analyze
```

### Ver solo errores
```bash
flutter analyze | grep error
```

### Formatear código
```bash
dart format lib/ -l 100
```

### Limpiar proyecto
```bash
flutter clean
flutter pub get
```

## 🧪 Testing

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests con coverage
```bash
flutter test --coverage
```

### Ver coverage en HTML
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📱 Dispositivos y Emuladores

### Ver dispositivos conectados
```bash
flutter devices
```

### Listar emuladores disponibles
```bash
flutter emulators
```

### Lanzar un emulador
```bash
flutter emulators --launch <emulator_id>
```

### Ejecutar en dispositivo específico
```bash
flutter run -d <device_id>
```

## 🏗️ Build

### Android APK (debug)
```bash
flutter build apk --debug
```

### Android APK (release)
```bash
flutter build apk --release
```

### Android APK con Supabase
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL="xxx" \
  --dart-define=SUPABASE_ANON_KEY="xxx"
```

### Android App Bundle (para Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Ubicación del APK generado
```
build/app/outputs/flutter-apk/app-release.apk
```

## 🐛 Debug

### Ver logs en tiempo real
```bash
flutter logs
```

### Hot reload (en la app en ejecución, presiona)
```
r - hot reload
R - hot restart
```

### Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## 📦 Base de Datos

### Ver la base de datos local (en el dispositivo/emulador)
```bash
# Android
adb shell
run-as com.decoracion.inventario_offline
cd app_flutter
cd databases
cat inventario_db.sqlite | sqlite3

# O usar herramientas GUI:
# - DB Browser for SQLite
# - TablePlus
# - DBeaver
```

### Limpiar base de datos local
```bash
# Android
adb shell pm clear com.decoracion.inventario_offline

# iOS
# Desinstalar y reinstalar la app desde Xcode o el dispositivo
```

## 🔄 Git

### Inicializar repositorio
```bash
git init
git add .
git commit -m "Initial commit: Sistema de Inventario Offline-First"
```

### Crear .gitignore (ya existe pero verificar)
```bash
# Verificar que incluya:
# *.g.dart
# .dart_tool/
# build/
# .env
```

## 📊 Performance

### Profile build
```bash
flutter run --profile
```

### Analizar tamaño del build
```bash
flutter build apk --analyze-size
```

## 🌐 Web (opcional, requiere configuración)

### Ejecutar en web
```bash
flutter run -d chrome
```

### Build para web
```bash
flutter build web
```

## 💾 Backups

### Backup de la base de datos de un dispositivo Android
```bash
adb exec-out run-as com.decoracion.inventario_offline cat app_flutter/databases/inventario_db.sqlite > backup.sqlite
```

### Restaurar base de datos en dispositivo Android
```bash
adb push backup.sqlite /data/local/tmp/
adb shell
run-as com.decoracion.inventario_offline
cp /data/local/tmp/backup.sqlite app_flutter/databases/inventario_db.sqlite
```

## 🔐 Seguridad

### Ofuscar código en release
```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

## 📝 Documentación

### Generar documentación del código
```bash
dart doc .
```

## 🎯 Shortcuts útiles en Flutter

- `hot reload`: Guarda el archivo o presiona `r`
- `hot restart`: Presiona `R`
- `quit`: Presiona `q`
- `screenshot`: Presiona `s`
- `widget inspector`: Presiona `w`
- `performance overlay`: Presiona `p`

## 🚨 Solución de Problemas Comunes

### Error: "Gradle sync failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Error: "CocoaPods not installed" (iOS)
```bash
sudo gem install cocoapods
cd ios
pod install
```

### Error de generación de código
```bash
flutter clean
rm -rf .dart_tool
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### App no se actualiza
```bash
flutter clean
flutter pub get
flutter run
```

## 📱 Emuladores Recomendados

### Android
- Pixel 6 Pro (API 33)
- Pixel 4a (API 30) - para testing de dispositivos más antiguos

### iOS
- iPhone 14 Pro (iOS 16)
- iPhone SE (iOS 15) - para testing de pantallas pequeñas

## 🎓 Tips de Desarrollo

1. **Usar el hot reload** constantemente durante desarrollo
2. **Ejecutar `flutter analyze`** antes de hacer commits
3. **Probar en ambos modos**: online y offline
4. **Verificar logs** cuando algo no funciona como esperas
5. **Usar DevTools** para inspeccionar el widget tree y performance

---

**Tip Pro**: Crea alias en tu `~/.zshrc` para comandos frecuentes:

```bash
# Agregar en ~/.zshrc
alias fr="flutter run"
alias frc="flutter clean && flutter pub get && flutter run"
alias fa="flutter analyze"
alias fb="dart run build_runner build --delete-conflicting-outputs"
alias fbw="dart run build_runner watch --delete-conflicting-outputs"
```

Luego recarga:
```bash
source ~/.zshrc
```
