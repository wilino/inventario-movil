# Sistema de Inventario Offline-First# inventario_offline



[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-02569B?logo=flutter)](https://flutter.dev)A new Flutter project.

[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)

[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)## Getting Started



Sistema móvil de gestión de inventarios con arquitectura offline-first para empresas de productos de decoración. Desarrollado con Flutter, Supabase y patrón BLoC.This project is a starting point for a Flutter application.



## 🎯 Características PrincipalesA few resources to get you started if this is your first Flutter project:



- **📱 Offline-First**: Funciona completamente sin conexión a internet- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

- **🔄 Sincronización Automática**: Sincroniza automáticamente al reconectar- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

- **🏪 Multi-tienda**: Gestión de múltiples tiendas y almacenes

- **📦 Gestión de Productos**: CRUD completo con soporte para variantesFor help getting started with Flutter development, view the

- **📊 Control de Inventario**: Seguimiento en tiempo real por ubicación[online documentation](https://docs.flutter.dev/), which offers tutorials,

- **💰 Ventas y Compras**: Registro de transacciones con actualización automática de stocksamples, guidance on mobile development, and a full API reference.

- **🔄 Transferencias**: Movimientos entre tiendas/almacenes con transacciones atómicas
- **📈 Reportes**: Estadísticas y análisis de ventas/compras/transferencias
- **🔐 Autenticación**: Login seguro con Supabase Auth
- **🎨 UI Moderna**: Material Design 3 con animaciones fluidas

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture** con separación por capas:

- **Presentation**: UI + BLoC/Cubit para gestión de estado
- **Domain**: Entidades de negocio, casos de uso, interfaces de repositorios
- **Data**: Implementación de repositorios, data sources (local y remoto)

### Stack Tecnológico

- **Framework**: Flutter 3.x
- **Lenguaje**: Dart 3.9.2
- **Backend**: Supabase (Auth, PostgreSQL, Realtime, Storage)
- **Base de Datos Local**: Drift (SQLite)
- **Gestión de Estado**: BLoC Pattern
- **Conectividad**: connectivity_plus
- **Inyección de Dependencias**: GetIt

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── config/           # Configuración (Supabase, DB, DI)
│   ├── services/         # Servicios (Conectividad, Sincronización)
│   ├── utils/            # Utilidades y helpers
│   └── widgets/          # Widgets reutilizables
├── features/
│   ├── auth/             # Autenticación
│   ├── products/         # Gestión de productos
│   ├── inventory/        # Control de inventario
│   ├── sales/            # Registro de ventas
│   ├── purchases/        # Registro de compras
│   ├── transfers/        # Transferencias entre tiendas
│   └── reports/          # Reportes y estadísticas
└── main.dart
```

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK 3.x o superior
- Dart 3.9.2 o superior
- Xcode (para iOS) o Android Studio (para Android)
- Cuenta de Supabase (opcional para modo offline)

### Pasos de Instalación

1. **Clonar el repositorio:**
```bash
git clone https://github.com/tu-usuario/inventario-offline-first.git
cd inventario-offline-first
```

2. **Instalar dependencias:**
```bash
flutter pub get
```

3. **Generar código de Drift:**
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. **Ejecutar la aplicación:**
```bash
flutter run
```

## 🔧 Configuración de Supabase

Para habilitar la sincronización en la nube, consulta [SUPABASE_SETUP.md](SUPABASE_SETUP.md).

## 📊 Base de Datos

### Tablas Principales

- **stores**: Tiendas y almacenes
- **user_profiles**: Perfiles de usuario
- **products**: Catálogo de productos
- **product_variants**: Variantes de productos
- **inventory**: Inventario por ubicación
- **purchases**: Registro de compras
- **sales**: Registro de ventas
- **transfers**: Transferencias entre ubicaciones
- **pending_ops**: Cola de sincronización

## 🔄 Sincronización Offline-First

El sistema implementa una estrategia de sincronización robusta:

1. **Escritura Local Primero**: Todas las operaciones se escriben primero en la DB local
2. **Cola de Operaciones**: Se encolan para sincronización posterior
3. **Sincronización Automática**: Al detectar conexión, sincroniza automáticamente
4. **Resolución de Conflictos**: Estrategia Last-Write-Wins por timestamp
5. **Reintentos**: Sistema de reintentos con backoff exponencial

## 📦 Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

## 📝 Roadmap

- [x] Setup inicial del proyecto
- [x] Arquitectura Clean + BLoC
- [x] Base de datos local con Drift
- [x] Sistema de sincronización
- [x] Monitoreo de conectividad
- [ ] Módulo de autenticación
- [ ] CRUD de productos completo
- [ ] Gestión de inventario
- [ ] Registro de ventas
- [ ] Registro de compras
- [ ] Transferencias entre tiendas
- [ ] Reportes y estadísticas

## 📄 Licencia

Proyecto académico - Universidad Católica Boliviana

---

**Desarrollado con ❤️ usando Flutter**
