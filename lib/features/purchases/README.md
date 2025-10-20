# Módulo de Compras (Purchases)

## 📋 Descripción
Módulo completo para la gestión de compras a proveedores con incremento automático de inventario, soporte offline-first y sincronización con Supabase.

## 🏗️ Arquitectura

### Domain Layer
- **Entities**: `Purchase`, `PurchaseItem`, `Supplier`
- **Repository Interface**: 15 métodos (10 para compras, 5 para proveedores)
- **Use Cases**: 
  - `CreatePurchaseUseCase` - Crear compra con validación
  - `GetStorePurchasesUseCase` - Obtener compras de una tienda
  - `GetTodayPurchasesUseCase` - Compras del día actual
  - `GetPurchasesStatsUseCase` - Estadísticas de compras
  - `GetActiveSuppliersUseCase` - Lista de proveedores activos

### Data Layer
- **Local DataSource** (Drift):
  - **INCREMENTA inventario** al crear compra
  - **DECREMENTA inventario** al cancelar compra
  - Búsqueda por proveedor y número de factura
  - Estadísticas y filtros por fecha
  
- **Remote DataSource** (Supabase):
  - Sincronización bidireccional
  - Gestión de proveedores en la nube
  - Operaciones CRUD completas

- **Repository Implementation**:
  - Patrón Offline-First
  - Sincronización en segundo plano
  - Manejo robusto de errores

### Presentation Layer
- **BLoC**: 14 eventos, 10 estados
- **Pages**:
  - `PurchasesHistoryPage` - Lista con búsqueda y filtros
  - `NewPurchasePage` - Formulario de creación
  - `SuppliersPage` - Gestión de proveedores

## 🗄️ Base de Datos (Schema v4)

### Tabla: `suppliers`
```sql
CREATE TABLE suppliers (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  contact_name TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  notes TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

### Tabla: `purchases` (Encabezado)
```sql
CREATE TABLE purchases (
  id TEXT PRIMARY KEY,
  store_id TEXT NOT NULL,
  supplier_id TEXT NOT NULL,
  supplier_name TEXT NOT NULL,
  author_user_id TEXT NOT NULL,
  subtotal REAL NOT NULL,
  discount REAL DEFAULT 0,
  tax REAL DEFAULT 0,
  total REAL NOT NULL,
  invoice_number TEXT,
  notes TEXT,
  at TIMESTAMP NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  is_deleted BOOLEAN DEFAULT FALSE
);
```

### Tabla: `purchase_items` (Detalle)
```sql
CREATE TABLE purchase_items (
  id TEXT PRIMARY KEY,
  purchase_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  variant_id TEXT,
  product_name TEXT NOT NULL,
  qty REAL NOT NULL,
  unit_cost REAL NOT NULL,
  total REAL NOT NULL
);
```

## 🚀 Uso

### Crear una Compra
```dart
final purchase = Purchase(
  id: uuid.v4(),
  storeId: 'store-id',
  supplierId: 'supplier-id',
  supplierName: 'Proveedor ABC',
  authorUserId: 'user-id',
  items: [
    PurchaseItem(
      productId: 'product-1',
      productName: 'Producto X',
      qty: 10,
      unitCost: 50.0,
      total: 500.0,
    ),
  ],
  subtotal: 500.0,
  discount: 0,
  tax: 16,
  total: 580.0,
  at: DateTime.now(),
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

// Usar el BLoC
context.read<PurchaseBloc>().add(CreatePurchase(purchase));
```

### Buscar Compras por Proveedor
```dart
context.read<PurchaseBloc>().add(
  SearchPurchasesBySupplier('store-id', 'supplier-id'),
);
```

### Filtrar por Rango de Fechas
```dart
context.read<PurchaseBloc>().add(
  FilterPurchasesByDateRange(
    'store-id',
    DateTime(2025, 1, 1),
    DateTime(2025, 12, 31),
  ),
);
```

### Gestionar Proveedores
```dart
// Crear proveedor
final supplier = Supplier(
  id: uuid.v4(),
  name: 'Proveedor ABC',
  contactName: 'Juan Pérez',
  email: 'juan@proveedor.com',
  phone: '+1234567890',
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

context.read<PurchaseBloc>().add(CreateSupplier(supplier));

// Listar proveedores activos
context.read<PurchaseBloc>().add(const LoadActiveSuppliers());
```

## 📊 Características

### ✅ Gestión de Compras
- [x] Crear compras con múltiples items
- [x] Cancelar compras (reversa inventario)
- [x] Búsqueda por número de factura
- [x] Filtros por proveedor
- [x] Filtros por rango de fechas
- [x] Visualización de detalles completos
- [x] Soporte para descuentos e IVA
- [x] Notas opcionales

### ✅ Gestión de Inventario
- [x] **Incremento automático** al crear compra
- [x] **Decremento automático** al cancelar
- [x] Sincronización con tabla `inventory`
- [x] Validación de productos existentes

### ✅ Gestión de Proveedores
- [x] CRUD completo (Create, Read, Update, Deactivate)
- [x] Información de contacto (nombre, email, teléfono, dirección)
- [x] Búsqueda por nombre, email o teléfono
- [x] Proveedores activos/inactivos
- [x] Notas personalizadas

### ✅ Estadísticas
- [x] Total de compras
- [x] Costo total
- [x] Costo promedio
- [x] Total de items comprados
- [x] Filtros por periodo

### ✅ Offline-First
- [x] Base de datos local como fuente de verdad
- [x] Sincronización automática en segundo plano
- [x] Funciona sin conexión a internet
- [x] Cola de operaciones pendientes

## 🎨 UI Components

### PurchasesHistoryPage
- Tarjetas de estadísticas (3 métricas)
- Barra de búsqueda con filtro en tiempo real
- Lista de compras con información resumida
- Modal de detalle con información completa
- Opciones de filtrado (hoy, rango de fechas, todos)
- Botón de sincronización manual
- FAB para nueva compra

### NewPurchasePage
- Selector de proveedor (dropdown)
- Campo de número de factura
- Gestión dinámica de items (agregar/eliminar)
- Cálculo automático de totales
- Campos de descuento e IVA
- Área de notas
- Validación de formulario
- Preview de totales en tarjeta

### SuppliersPage
- Barra de búsqueda multi-campo
- Tarjetas de proveedores con información clave
- Modal de detalle completo
- Diálogo de creación/edición con validación
- Opciones de editar y desactivar
- Confirmación para acciones críticas

## 🔄 Flujo de Datos

```
UI (Pages) 
  ↓ dispatch events
BLoC (PurchaseBloc)
  ↓ call use cases
Use Cases
  ↓ call repository
Repository Implementation (Offline-First)
  ↓ write/read
Local DataSource (Drift)
  ↓ sync in background
Remote DataSource (Supabase)
```

## 📝 Próximas Mejoras

### Corto Plazo
- [ ] Integración con búsqueda de productos existentes
- [ ] Validación de duplicados de factura
- [ ] Reportes de compras por proveedor
- [ ] Exportación a PDF/Excel

### Mediano Plazo
- [ ] Historial de precios por producto
- [ ] Alertas de reorden automático
- [ ] Comparativa de precios entre proveedores
- [ ] Integración con contabilidad

### Largo Plazo
- [ ] Predicción de demanda con ML
- [ ] Optimización de órdenes de compra
- [ ] Portal para proveedores
- [ ] Cotizaciones electrónicas

## 🧪 Testing

### Casos de Prueba Implementados
- Validación de items no vacíos
- Validación de total mayor a 0
- Validación de proveedor requerido
- Cálculo correcto de totales
- Incremento correcto de inventario
- Reversión correcta al cancelar

### Pendientes de Testing
- [ ] Tests unitarios para UseCases
- [ ] Tests de integración para Repository
- [ ] Tests de widgets para UI
- [ ] Tests E2E del flujo completo

## 📄 Licencia
Este módulo es parte del proyecto de Inventario Móvil - Maestría CATO 2025
