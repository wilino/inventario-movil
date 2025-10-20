import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

/// Tabla de Tiendas/Almacenes
class Stores extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // "store" | "warehouse"
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Perfiles de Usuario
class UserProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get storeId => text()();
  TextColumn get fullName => text()();
  TextColumn get role => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Tabla de Productos
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get sku => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  RealColumn get costPrice => real().named('cost_price')();
  RealColumn get salePrice => real().named('sale_price')();
  TextColumn get unit => text()();
  BoolColumn get hasVariants => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Variantes de Productos
class ProductVariants extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get attrs => text()(); // JSON string
  TextColumn get sku => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Inventario
class Inventory extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  RealColumn get stockQty => real()();
  RealColumn get minQty => real().withDefault(const Constant(0))();
  RealColumn get maxQty => real().withDefault(const Constant(100))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Ajustes de Inventario (Historial)
class InventoryAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get inventoryId => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()(); // 'increment' | 'decrement' | 'set'
  RealColumn get previousQty => real()();
  RealColumn get adjustmentQty => real()();
  RealColumn get newQty => real()();
  TextColumn get reason => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Proveedores
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactName => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Compras (encabezado)
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get supplierId => text()();
  TextColumn get supplierName => text()();
  TextColumn get authorUserId => text()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get at => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Items de Compra (detalle)
class PurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  TextColumn get productName => text()();
  RealColumn get qty => real()();
  RealColumn get unitCost => real()();
  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Ventas (encabezado)
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get authorUserId => text()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get customer => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get at => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Items de Venta (detalle)
class SaleItems extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  TextColumn get productName => text()();
  RealColumn get qty => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Transferencias
class Transfers extends Table {
  TextColumn get id => text()();
  TextColumn get fromStoreId => text()();
  TextColumn get toStoreId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  IntColumn get qty => integer()();
  DateTimeColumn get at => dateTime()();
  TextColumn get authorUserId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Operaciones Pendientes para Sincronización
class PendingOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => text()(); // 'sales', 'purchases', 'inventory', etc.
  TextColumn get op => text()(); // 'insert' | 'update' | 'delete' | 'rpc'
  TextColumn get payload => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
}

/// Base de datos de la aplicación
@DriftDatabase(
  tables: [
    Stores,
    UserProfiles,
    Products,
    ProductVariants,
    Inventory,
    InventoryAdjustments,
    Suppliers,
    Purchases,
    PurchaseItems,
    Sales,
    SaleItems,
    Transfers,
    PendingOps,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(inventoryAdjustments);
      }
      if (from < 3) {
        // Migrar tabla Sales al nuevo formato y crear SaleItems
        await migrator.createTable(saleItems);
        // Nota: En producción deberías migrar los datos existentes
      }
      if (from < 4) {
        // Crear tabla de proveedores
        await migrator.createTable(suppliers);
        
        // Eliminar tabla antigua de Purchases
        await migrator.deleteTable('purchases');
        
        // Crear nuevas tablas de Purchases (encabezado + detalle)
        await migrator.createTable(purchases);
        await migrator.createTable(purchaseItems);
      }
    },
  );
}

/// Abre la conexión a la base de datos SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'inventario_db.sqlite'));
    return NativeDatabase(file);
  });
}
