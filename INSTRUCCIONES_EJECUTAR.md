# 📋 Instrucciones para Ejecutar y Ver Todas las Funcionalidades

## 🎯 Objetivo
Configurar la app para que la **Tienda Central** muestre:
- ✅ **Ventas** (2 ventas existentes)
- ✅ **Compras** (2 compras nuevas que acabamos de agregar)
- ✅ **Traslados** (múltiples traslados)

## 📝 Pasos a Seguir

### 1️⃣ Ejecutar Script Actualizado en Supabase

1. Abre tu proyecto en **Supabase Dashboard**
2. Ve a **SQL Editor**
3. Ejecuta el script actualizado:
   ```bash
   scripts/datos_decoracion_construccion.sql
   ```

**Contenido importante agregado:**

#### Nuevas Compras para Tienda Central:
```sql
-- Compra 4: Reposición de pisos (Bs 12,750.00)
- 100 unidades Piso Flotante Roble Natural @ Bs 85
- 50 unidades Cerámica Española Beige @ Bs 85
- Proveedor: Importadora MegaPisos S.R.L.
- Factura: FAC-2025-5001

-- Compra 5: Alfombras exhibición (Bs 8,600.00)
- 30 unidades Alfombra Moderna 1.5x2m @ Bs 180
- 8 unidades Alfombra Persa 2x3m @ Bs 400
- Proveedor: Alfombras del Sur
- Factura: FAC-SC-6789
```

### 2️⃣ Verificar Datos en Supabase

Ejecuta este query de verificación:
```sql
-- Ver compras de Tienda Central
SELECT 
  p.id,
  p.supplier_name,
  p.total_amount,
  p.invoice_number,
  COUNT(pi.id) as items_count
FROM purchases p
LEFT JOIN purchase_items pi ON pi.purchase_id = p.id
WHERE p.store_id = '11111111-1111-1111-1111-111111111111'
GROUP BY p.id, p.supplier_name, p.total_amount, p.invoice_number
ORDER BY p.created_at DESC;
```

**Deberías ver:**
- 2 compras
- Totales: Bs 12,750.00 y Bs 8,600.00

### 3️⃣ Reiniciar la Aplicación Flutter

```bash
# En la terminal donde corre la app, presiona:
r  # Hot reload (rápido)

# O si es necesario:
R  # Hot restart (reinicia el estado)

# O cierra y vuelve a ejecutar:
flutter run -d macos
```

### 4️⃣ Forzar Sincronización

En la app:
1. Ve al **Dashboard**
2. Busca el botón de **Sincronizar** (ícono de refresh/sync)
3. Presiona para forzar descarga de datos desde Supabase

Deberías ver en consola:
```
flutter: 🛒 Descargando 5 compras...
flutter: ✅ Sincronización completa: 11 productos, 5 ventas, 5 compras, 13 transferencias
```

### 5️⃣ Verificar en la App

#### Dashboard:
- **Ventas hoy**: 2
- **Compras**: 2 (nuevas)
- **Traslados pendientes**: varios

#### Pestaña Ventas:
- ✅ Debe mostrar 2 ventas:
  1. Constructora Los Andes (Bs 25,200.00)
  2. Hotel Plaza del Estudiante (Bs 12,600.00)

#### Pestaña Compras:
- ✅ Debe mostrar 2 compras:
  1. Importadora MegaPisos (Bs 12,750.00)
  2. Alfombras del Sur (Bs 8,600.00)

#### Pestaña Traslados:
- ✅ Debe mostrar múltiples traslados
- Algunos como origen (FROM)
- Algunos como destino (TO)

## 🔍 Troubleshooting

### Si no ves las compras:

1. **Verifica el storeId en main.dart:**
   ```dart
   // Línea ~115 en lib/main.dart
   storeId: '11111111-1111-1111-1111-111111111111', // Tienda Central
   ```

2. **Revisa logs en consola:**
   ```
   flutter: 🔍 [PurchaseRepo] Buscando compras para storeId: 11111111...
   flutter: 📦 [PurchaseRepo] Encontradas 2 compras en local
   ```

3. **Verifica en base de datos local:**
   - En macOS, la DB está en:
   ```
   ~/Library/Application Support/com.example.inventario_offline/inventario.db
   ```

### Si la sincronización falla:

1. Verifica conexión a Supabase
2. Revisa credenciales en `lib/core/config/supabase_config.dart`
3. Mira logs de errores:
   ```
   flutter: ❌ [Sync] Error: ...
   ```

## 📊 Resumen de Datos por Tienda

Después de ejecutar todo:

| Tienda | Ventas | Compras | Inventario |
|--------|--------|---------|------------|
| **Tienda Central** | 2 | 2 | Varios |
| Sucursal El Alto | 3 | 0 | Varios |
| Almacén Principal | 0 | 3 | Varios |
| Sucursal Santa Cruz | 0 | 0 | Varios |

## ✅ Checklist Final

- [ ] Script ejecutado en Supabase
- [ ] Verificación SQL correcta (2 compras visibles)
- [ ] App reiniciada
- [ ] Sincronización forzada
- [ ] Dashboard muestra números correctos
- [ ] Pestaña Ventas funciona (2 ventas)
- [ ] Pestaña Compras funciona (2 compras)
- [ ] Pestaña Traslados funciona (13 traslados)

## 🎉 Resultado Esperado

La **Tienda Central La Paz** ahora es tu tienda demo completa que muestra:
- ✅ Gestión de ventas
- ✅ Gestión de compras
- ✅ Gestión de traslados
- ✅ Control de inventario
- ✅ Estadísticas en dashboard

¡Todo funcionando con sincronización offline-first!
