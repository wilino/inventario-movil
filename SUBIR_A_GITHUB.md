# 📤 Guía para Subir el Proyecto a GitHub

## ✅ Estado Actual

Ya tienes:
- ✅ Git inicializado
- ✅ Commit inicial creado (141 archivos)
- ✅ .gitignore configurado (excluye documentos personales)
- ✅ Usuario y email configurados

## 🚀 Pasos para Crear el Repositorio en GitHub

### Opción 1: Usando la Web de GitHub (Recomendado)

1. **Ve a GitHub:**
   - Abre: https://github.com/new
   - O ve a https://github.com/wilino y haz clic en "New repository"

2. **Configurar el repositorio:**
   ```
   Repository name: inventario-offline-flutter
   Description: Sistema de Inventario Offline-First con Flutter, Supabase y BLoC - Proyecto Final Maestría
   
   ✅ Public (o Private si prefieres)
   ❌ NO marcar "Initialize this repository with a README"
   ❌ NO agregar .gitignore
   ❌ NO agregar license
   ```

3. **Crear el repositorio:**
   - Haz clic en "Create repository"

4. **Copiar la URL que aparece**, algo como:
   ```
   https://github.com/wilino/inventario-offline-flutter.git
   ```

### Opción 2: Usando GitHub CLI (Si la instalas)

```bash
# Instalar GitHub CLI
brew install gh

# Autenticarte
gh auth login

# Crear y subir el repositorio
cd /Users/willy-mac/Maestria\ Cato/Dev-App-Adv/Proyecto-Final/inventario_app
gh repo create inventario-offline-flutter --public --source=. --push
```

## 📤 Subir el Código a GitHub

Una vez que tengas la URL del repositorio, ejecuta estos comandos:

```bash
# Ir al directorio del proyecto
cd /Users/willy-mac/Maestria\ Cato/Dev-App-Adv/Proyecto-Final/inventario_app

# Agregar el repositorio remoto (usa la URL de TU repositorio)
git remote add origin https://github.com/wilino/inventario-offline-flutter.git

# Verificar que se agregó correctamente
git remote -v

# Subir el código
git push -u origin main
```

## 🔐 Si Git te pide Autenticación

GitHub ya no permite usar contraseñas. Tienes dos opciones:

### Opción A: Personal Access Token (Recomendado)

1. Ve a: https://github.com/settings/tokens
2. Click en "Generate new token" > "Generate new token (classic)"
3. Configurar:
   - Note: "Inventario Flutter App"
   - Expiration: 90 days (o lo que prefieras)
   - Scopes: Marca "repo" (todos los checkboxes debajo)
4. Click "Generate token"
5. **COPIA EL TOKEN** (solo se muestra una vez)
6. Cuando hagas `git push`, usa el token como contraseña

### Opción B: SSH (Más permanente)

```bash
# Generar clave SSH si no tienes una
ssh-keygen -t ed25519 -C "wilino50@gmail.com"

# Copiar la clave pública
cat ~/.ssh/id_ed25519.pub | pbcopy

# Agregar a GitHub:
# 1. Ve a https://github.com/settings/keys
# 2. Click "New SSH key"
# 3. Pega la clave y dale un nombre
# 4. Click "Add SSH key"

# Cambiar la URL del remoto a SSH
git remote set-url origin git@github.com:wilino/inventario-offline-flutter.git

# Ahora puedes hacer push sin contraseña
git push -u origin main
```

## 📋 Comandos Resumidos

```bash
# 1. Crear repositorio en GitHub (usando la web)
# https://github.com/new

# 2. Agregar el remoto y subir
cd /Users/willy-mac/Maestria\ Cato/Dev-App-Adv/Proyecto-Final/inventario_app
git remote add origin https://github.com/wilino/inventario-offline-flutter.git
git push -u origin main
```

## 🎯 Verificar que se Subió Correctamente

Una vez que hagas push, ve a:
```
https://github.com/wilino/inventario-offline-flutter
```

Deberías ver:
- ✅ README.md con la descripción del proyecto
- ✅ Estructura de carpetas de Flutter
- ✅ SUPABASE_SETUP.md con las instrucciones SQL
- ✅ 141 archivos subidos
- ❌ Los archivos .md personales NO deberían estar (están en .gitignore)

## 📝 Para Futuros Cambios

```bash
# Ver estado
git status

# Agregar cambios
git add .

# Hacer commit
git commit -m "Descripción del cambio"

# Subir a GitHub
git push
```

## 🏷️ Agregar Tags (Versiones)

```bash
# Crear un tag para la versión inicial
git tag -a v1.0.0 -m "Versión inicial: Estructura base con BLoC y Drift"

# Subir el tag
git push origin v1.0.0

# Ver todos los tags
git tag
```

## 🌟 Mejorar el Repositorio

### Agregar un Badge de Estado

Edita el README.md y agrega al inicio:

```markdown
# Sistema de Inventario Offline-First

[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-blue.svg)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

...resto del contenido...
```

### Agregar GitHub Actions (CI/CD)

Crear `.github/workflows/flutter.yml`:

```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.3'
    - run: flutter pub get
    - run: flutter analyze
    - run: flutter test
```

## 🎓 Tips

1. **Commits frecuentes**: Haz commits pequeños y descriptivos
2. **Branches**: Usa branches para features nuevas
3. **Issues**: Usa GitHub Issues para trackear tareas
4. **Projects**: Usa GitHub Projects para organizar el desarrollo
5. **Wiki**: Documenta decisiones técnicas en la Wiki

---

## ✅ Checklist Final

- [ ] Repositorio creado en GitHub
- [ ] Remote agregado localmente
- [ ] Código subido con `git push`
- [ ] README.md visible en GitHub
- [ ] Archivos personales (.md) NO visibles en GitHub
- [ ] URL del repo compartida con el equipo

**¡Tu proyecto estará en GitHub listo para colaborar y compartir!** 🚀
