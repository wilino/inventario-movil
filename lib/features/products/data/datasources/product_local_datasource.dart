import 'package:drift/drift.dart';
import '../../../../core/config/database.dart';
import '../../domain/entities/product.dart' as domain;

/// Data source local para productos usando Drift
class ProductLocalDataSource {
  final AppDatabase database;

  ProductLocalDataSource(this.database);

  /// Obtener todos los productos
  Future<List<domain.Product>> getAllProducts() async {
    final query = database.select(database.products);
    final results = await query.get();
    return results.map(_mapToEntity).toList();
  }

  /// Obtener productos activos
  Future<List<domain.Product>> getActiveProducts() async {
    final query = database.select(database.products)
      ..where((tbl) => tbl.isActive.equals(true) & tbl.deletedAt.isNull());
    final results = await query.get();
    return results.map(_mapToEntity).toList();
  }

  /// Obtener producto por ID
  Future<domain.Product?> getProductById(String id) async {
    final query = database.select(database.products)
      ..where((tbl) => tbl.id.equals(id));
    final result = await query.getSingleOrNull();
    return result != null ? _mapToEntity(result) : null;
  }

  /// Obtener producto por SKU
  Future<domain.Product?> getProductBySku(String sku) async {
    final query = database.select(database.products)
      ..where((tbl) => tbl.sku.equals(sku) & tbl.deletedAt.isNull());
    final result = await query.getSingleOrNull();
    return result != null ? _mapToEntity(result) : null;
  }

  /// Buscar productos
  Future<List<domain.Product>> searchProducts(String query) async {
    final searchQuery = '%${query.toLowerCase()}%';
    final results =
        await (database.select(database.products)..where(
              (tbl) =>
                  (tbl.name.lower().like(searchQuery) |
                      tbl.sku.lower().like(searchQuery)) &
                  tbl.deletedAt.isNull(),
            ))
            .get();
    return results.map(_mapToEntity).toList();
  }

  /// Obtener productos por categoría
  Future<List<domain.Product>> getProductsByCategory(String category) async {
    final query = database.select(database.products)
      ..where((tbl) => tbl.category.equals(category) & tbl.deletedAt.isNull());
    final results = await query.get();
    return results.map(_mapToEntity).toList();
  }

  /// Crear producto
  Future<domain.Product> createProduct(domain.Product product) async {
    final now = DateTime.now();
    final companion = ProductsCompanion.insert(
      id: product.id,
      sku: product.sku,
      name: product.name,
      description: Value(product.description),
      category: product.category,
      costPrice: product.costPrice,
      salePrice: product.salePrice,
      unit: product.unit,
      hasVariants: Value(product.hasVariants),
      isActive: Value(product.isActive),
      createdAt: now,
      updatedAt: now,
    );

    await database.into(database.products).insert(companion);
    return product.copyWith(createdAt: now, updatedAt: now);
  }

  /// Actualizar producto
  Future<domain.Product> updateProduct(domain.Product product) async {
    final companion = ProductsCompanion(
      id: Value(product.id),
      sku: Value(product.sku),
      name: Value(product.name),
      description: Value(product.description),
      category: Value(product.category),
      costPrice: Value(product.costPrice),
      salePrice: Value(product.salePrice),
      unit: Value(product.unit),
      hasVariants: Value(product.hasVariants),
      isActive: Value(product.isActive),
      updatedAt: Value(DateTime.now()),
    );

    await database.update(database.products).replace(companion);
    return product.copyWith(updatedAt: DateTime.now());
  }

  /// Eliminar producto (soft delete)
  Future<void> deleteProduct(String id) async {
    await (database.update(database.products)
          ..where((tbl) => tbl.id.equals(id)))
        .write(ProductsCompanion(deletedAt: Value(DateTime.now())));
  }

  /// Obtener categorías únicas
  Future<List<String>> getCategories() async {
    final query = database.selectOnly(database.products, distinct: true)
      ..addColumns([database.products.category])
      ..where(database.products.deletedAt.isNull());

    final results = await query.get();
    return results
        .map((row) => row.read(database.products.category))
        .where((cat) => cat != null)
        .map((cat) => cat!)
        .toList();
  }

  /// Mapear de Drift a entidad de dominio
  domain.Product _mapToEntity(Product row) {
    return domain.Product(
      id: row.id,
      sku: row.sku,
      name: row.name,
      description: row.description,
      category: row.category,
      costPrice: row.costPrice,
      salePrice: row.salePrice,
      unit: row.unit,
      hasVariants: row.hasVariants,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.deletedAt != null,
    );
  }
}
