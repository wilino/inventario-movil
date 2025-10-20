# 📦 Sistema de Inventario Offline-First# Sistema de Inventario Offline-First# inventario_offline



> Aplicación móvil de gestión de inventario multi-tienda con arquitectura Clean + BLoC y sincronización en tiempo real



[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)[![Flutter](https://img.shields.io/badge/Flutter-3.35.3-02569B?logo=flutter)](https://flutter.dev)A new Flutter project.

[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)

[![Supabase](https://img.shields.io/badge/Supabase-2.0.0-3ECF8E?logo=supabase)](https://supabase.com)[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)

[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)## Getting Started

## 🚀 Características Principales



### ✨ Funcionalidades de Negocio

- 📊 **Dashboard con métricas en tiempo real**: Ingresos, costos, ganancia, margen de utilidadSistema móvil de gestión de inventarios con arquitectura offline-first para empresas de productos de decoración. Desarrollado con Flutter, Supabase y patrón BLoC.This project is a starting point for a Flutter application.

- 💰 **Gestión de Ventas**: Registro, historial y estadísticas

- 🛒 **Gestión de Compras**: Control de proveedores y órdenes de compra

- 📦 **Control de Inventario**: Seguimiento multi-tienda con alertas de stock

- 🔄 **Traslados entre Tiendas**: Workflow completo (Pendiente → En tránsito → Completado)## 🎯 Características PrincipalesA few resources to get you started if this is your first Flutter project:

- 📈 **Reportes y Analytics**: Agregaciones complejas y top productos



### 🏗️ Características Técnicas

- **Offline-First**: Funciona sin conexión, sincroniza automáticamente- **📱 Offline-First**: Funciona completamente sin conexión a internet- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

- **Clean Architecture**: Separación clara de responsabilidades

- **BLoC Pattern**: State management robusto y reactivo- **🔄 Sincronización Automática**: Sincroniza automáticamente al reconectar- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

- **Type-Safe Database**: Drift ORM con code generation

- **Real-time Sync**: Supabase para sincronización en tiempo real- **🏪 Multi-tienda**: Gestión de múltiples tiendas y almacenes

- **Material Design 3**: UI moderna y consistente

- **📦 Gestión de Productos**: CRUD completo con soporte para variantesFor help getting started with Flutter development, view the

---

- **📊 Control de Inventario**: Seguimiento en tiempo real por ubicación[online documentation](https://docs.flutter.dev/), which offers tutorials,

## 🛠️ Stack Tecnológico

- **💰 Ventas y Compras**: Registro de transacciones con actualización automática de stocksamples, guidance on mobile development, and a full API reference.

### Frontend

- **Flutter** 3.9.2 - Framework multiplataforma- **🔄 Transferencias**: Movimientos entre tiendas/almacenes con transacciones atómicas

- **Dart** 3.9.2 - Lenguaje de programación- **📈 Reportes**: Estadísticas y análisis de ventas/compras/transferencias

- **BLoC** 8.1.0 - State management- **🔐 Autenticación**: Login seguro con Supabase Auth

- **GetIt** 7.6.0 - Dependency injection- **🎨 UI Moderna**: Material Design 3 con animaciones fluidas



### Database## 🏗️ Arquitectura

- **Drift** 2.16.0 - Type-safe SQLite ORM

- **SQLite** - Base de datos localEl proyecto implementa **Clean Architecture** con separación por capas:



### Backend- **Presentation**: UI + BLoC/Cubit para gestión de estado

- **Supabase** 2.0.0 - Backend as a Service- **Domain**: Entidades de negocio, casos de uso, interfaces de repositorios

- **PostgreSQL** - Base de datos remota- **Data**: Implementación de repositorios, data sources (local y remoto)

- **Real-time** - Sincronización en tiempo real

### Stack Tecnológico

---

- **Framework**: Flutter 3.x

## 📋 Prerequisitos- **Lenguaje**: Dart 3.9.2

- **Backend**: Supabase (Auth, PostgreSQL, Realtime, Storage)

- Flutter SDK >= 3.9.0- **Base de Datos Local**: Drift (SQLite)

- Dart SDK >= 3.9.0- **Gestión de Estado**: BLoC Pattern

- Android Studio / Xcode- **Conectividad**: connectivity_plus

- Cuenta de Supabase (opcional, funciona 100% offline)- **Inyección de Dependencias**: GetIt



---## 📁 Estructura del Proyecto



## 🔧 Instalación```

lib/

### 1. Clonar el repositorio├── core/

```bash│   ├── config/           # Configuración (Supabase, DB, DI)

git clone https://github.com/wilino/inventario-movil.git│   ├── services/         # Servicios (Conectividad, Sincronización)

cd inventario-movil/inventario_app│   ├── utils/            # Utilidades y helpers

```│   └── widgets/          # Widgets reutilizables

├── features/

### 2. Instalar dependencias│   ├── auth/             # Autenticación

```bash│   ├── products/         # Gestión de productos

flutter pub get│   ├── inventory/        # Control de inventario

```│   ├── sales/            # Registro de ventas

│   ├── purchases/        # Registro de compras

### 3. Generar código (Drift, Freezed, JSON)│   ├── transfers/        # Transferencias entre tiendas

```bash│   └── reports/          # Reportes y estadísticas

dart run build_runner build --delete-conflicting-outputs└── main.dart

``````



### 4. Configurar Supabase (opcional)## 🚀 Instalación

Editar `lib/core/config/supabase_config.dart` con tus credenciales.

### Requisitos Previos

### 5. Ejecutar la aplicación

```bash- Flutter SDK 3.x o superior

flutter run- Dart 3.9.2 o superior

```- Xcode (para iOS) o Android Studio (para Android)

- Cuenta de Supabase (opcional para modo offline)

---

### Pasos de Instalación

## 🏛️ Arquitectura

1. **Clonar el repositorio:**

### Clean Architecture Layers```bash

git clone https://github.com/tu-usuario/inventario-offline-first.git

```cd inventario-offline-first

lib/```

├── core/                          # Configuración global

│   ├── config/                    # Database, DI, Supabase2. **Instalar dependencias:**

│   ├── services/                  # Connectivity, Sync```bash

│   ├── error/                     # Failuresflutter pub get

│   └── utils/                     # Result<T>```

│

└── features/                      # Módulos de negocio3. **Generar código de Drift:**

    ├── auth/                      # Autenticación```bash

    ├── products/                  # Catálogo de productosdart run build_runner build --delete-conflicting-outputs

    ├── inventory/                 # Control de stock```

    ├── sales/                     # Ventas

    ├── purchases/                 # Compras4. **Ejecutar la aplicación:**

    ├── transfers/                 # Traslados```bash

    └── reports/                   # Dashboard y reportesflutter run

        ├── domain/                # Entidades, UseCases```

        ├── data/                  # DataSources, Repositories

        └── presentation/          # BLoC, Pages## 🔧 Configuración de Supabase

```

Para habilitar la sincronización en la nube, consulta [SUPABASE_SETUP.md](SUPABASE_SETUP.md).

### Patrón Offline-First

## 📊 Base de Datos

1. **Escritura**: Siempre a SQLite (inmediato)

2. **Background Sync**: Cola de operaciones pendientes### Tablas Principales

3. **Lectura**: Siempre desde SQLite

4. **Conflict Resolution**: Last-write-wins- **stores**: Tiendas y almacenes

- **user_profiles**: Perfiles de usuario

---- **products**: Catálogo de productos

- **product_variants**: Variantes de productos

## 🗄️ Schema de Base de Datos- **inventory**: Inventario por ubicación

- **purchases**: Registro de compras

### Tablas Principales (9)- **sales**: Registro de ventas

- **transfers**: Transferencias entre ubicaciones

| Tabla | Descripción | Campos Clave |- **pending_ops**: Cola de sincronización

|-------|-------------|--------------|

| `products` | Catálogo base | sku, name, description |## 🔄 Sincronización Offline-First

| `variants` | Variantes (talla, color) | productId, sku, name |

| `inventory` | Stock por tienda | storeId, productId, stockQty |El sistema implementa una estrategia de sincronización robusta:

| `sales` | Transacciones de venta | total, at, storeId |

| `sale_items` | Líneas de venta | saleId, productId, qty |1. **Escritura Local Primero**: Todas las operaciones se escriben primero en la DB local

| `purchases` | Órdenes de compra | supplierId, total |2. **Cola de Operaciones**: Se encolan para sincronización posterior

| `purchase_items` | Líneas de compra | purchaseId, qty |3. **Sincronización Automática**: Al detectar conexión, sincroniza automáticamente

| `transfers` | Traslados | fromStore, toStore, status |4. **Resolución de Conflictos**: Estrategia Last-Write-Wins por timestamp

| `suppliers` | Proveedores | name, email, phone |5. **Reintentos**: Sistema de reintentos con backoff exponencial



---## 📦 Build



## 📊 Módulos Implementados```bash

# Android APK

### 1. Dashboard (Reports) 📊flutter build apk --release

- Métricas financieras en tiempo real

- Top productos vendidos# iOS

- Alertas de inventarioflutter build ios --release

- Navegación a reportes detallados```



### 2. Ventas 💰## 📝 Roadmap

- Registro de ventas con múltiples items

- Historial con filtros- [x] Setup inicial del proyecto

- Estadísticas y métricas- [x] Arquitectura Clean + BLoC

- [x] Base de datos local con Drift

### 3. Compras 🛒- [x] Sistema de sincronización

- Órdenes de compra- [x] Monitoreo de conectividad

- Gestión de proveedores- [ ] Módulo de autenticación

- Actualización automática de inventario- [ ] CRUD de productos completo

- [ ] Gestión de inventario

### 4. Inventario 📦- [ ] Registro de ventas

- Vista multi-tienda- [ ] Registro de compras

- Alertas de stock bajo- [ ] Transferencias entre tiendas

- Ajustes manuales- [ ] Reportes y estadísticas



### 5. Traslados 🔄## 📄 Licencia

- Workflow de estados

- Actualización automática de inventario origen/destinoProyecto académico - Universidad Católica Boliviana

- Historial completo

---

---

**Desarrollado con ❤️ usando Flutter**

## 🎯 Comandos Útiles

### Desarrollo
```bash
# Watch mode (regenera automáticamente)
dart run build_runner watch

# Análisis de código
flutter analyze

# Formateo de código
dart format .
```

### Build
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📈 Estado del Proyecto

**Completado: 98%** ✅

- ✅ 7 módulos implementados
- ✅ ~15,000+ líneas de código
- ✅ Arquitectura Clean + BLoC
- ✅ Drift ORM con 9 tablas
- ✅ Navegación principal
- ✅ Dashboard funcional
- ✅ Offline-First completo

Ver [PROYECTO_ESTADO_FINAL.md](PROYECTO_ESTADO_FINAL.md) para detalles completos.

---

## 👨‍💻 Autor

**Wilfredo**
- GitHub: [@wilino](https://github.com/wilino)
- Proyecto: Maestría en Desarrollo de Aplicaciones Avanzadas

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

---

<div align="center">

**Hecho con ❤️ usando Flutter**

</div>
