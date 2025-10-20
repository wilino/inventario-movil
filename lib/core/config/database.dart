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
  IntColumn get stockQty => integer()();
  IntColumn get minQty => integer().nullable()();
  IntColumn get maxQty => integer().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Compras
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  IntColumn get qty => integer()();
  RealColumn get unitCost => real().nullable()();
  DateTimeColumn get at => dateTime()();
  TextColumn get authorUserId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Tabla de Ventas
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get productId => text()();
  TextColumn get variantId => text().nullable()();
  IntColumn get qty => integer()();
  RealColumn get unitPrice => real().nullable()();
  DateTimeColumn get at => dateTime()();
  TextColumn get customer => text().nullable()();
  TextColumn get authorUserId => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

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
    Purchases,
    Sales,
    Transfers,
    PendingOps,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

/// Abre la conexión a la base de datos SQLite
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'inventario_db.sqlite'));
    return NativeDatabase(file);
  });
}
