import 'package:drift/drift.dart';
import '../../../../core/config/database.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_adjustment.dart' as domain;

/// Data source local para el manejo de inventario con Drift
class InventoryLocalDataSource {
  final AppDatabase db;

  InventoryLocalDataSource(this.db);

  /// Obtiene el inventario de una tienda
  Future<List<InventoryItem>> getStoreInventory(String storeId) async {
    final results = await (db.select(
      db.inventory,
    )..where((t) => t.storeId.equals(storeId))).get();

    return results.map(_mapToEntity).toList();
  }

  /// Obtiene el inventario de un producto en todas las tiendas
  Future<List<InventoryItem>> getProductInventory(String productId) async {
    final results = await (db.select(
      db.inventory,
    )..where((t) => t.productId.equals(productId))).get();

    return results.map(_mapToEntity).toList();
  }

  /// Obtiene un ítem de inventario específico
  Future<InventoryItem?> getInventoryItem(
    String storeId,
    String productId,
  ) async {
    final result =
        await (db.select(db.inventory)..where(
              (t) => t.storeId.equals(storeId) & t.productId.equals(productId),
            ))
            .getSingleOrNull();

    return result != null ? _mapToEntity(result) : null;
  }

  /// Obtiene productos con stock bajo
  Future<List<InventoryItem>> getLowStockItems(String storeId) async {
    final results =
        await (db.select(db.inventory)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  (db.inventory.stockQty.isSmallerOrEqual(db.inventory.minQty)),
            ))
            .get();

    return results.map(_mapToEntity).toList();
  }

  /// Obtiene productos agotados
  Future<List<InventoryItem>> getOutOfStockItems(String storeId) async {
    final results =
        await (db.select(db.inventory)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.stockQty.isSmallerOrEqualValue(0),
            ))
            .get();

    return results.map(_mapToEntity).toList();
  }

  /// Ajusta el inventario y registra el ajuste
  Future<InventoryItem> adjustInventory(
    String inventoryId,
    double newQty,
    String userId,
    String type,
    String? reason,
    String? notes,
  ) async {
    // Obtener el ítem actual
    final current = await (db.select(
      db.inventory,
    )..where((t) => t.id.equals(inventoryId))).getSingle();

    final previousQty = current.stockQty;
    final adjustmentQty = newQty - previousQty;

    // Actualizar el stock
    await (db.update(
      db.inventory,
    )..where((t) => t.id.equals(inventoryId))).write(
      InventoryCompanion(
        stockQty: Value(newQty),
        updatedAt: Value(DateTime.now()),
      ),
    );

    // Registrar el ajuste en el historial
    final adjustmentId = DateTime.now().millisecondsSinceEpoch.toString();
    await db
        .into(db.inventoryAdjustments)
        .insert(
          InventoryAdjustmentsCompanion.insert(
            id: adjustmentId,
            inventoryId: inventoryId,
            userId: userId,
            type: type,
            previousQty: previousQty,
            adjustmentQty: adjustmentQty,
            newQty: newQty,
            reason: Value(reason),
            notes: Value(notes),
            createdAt: DateTime.now(),
          ),
        );

    // Retornar el ítem actualizado
    final updated = await (db.select(
      db.inventory,
    )..where((t) => t.id.equals(inventoryId))).getSingle();

    return _mapToEntity(updated);
  }

  /// Crea un nuevo registro de inventario
  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    await db
        .into(db.inventory)
        .insert(
          InventoryCompanion.insert(
            id: item.id,
            storeId: item.storeId,
            productId: item.productId,
            variantId: Value(item.variantId),
            stockQty: item.stockQty,
            minQty: Value(item.minQty),
            maxQty: Value(item.maxQty),
            updatedAt: item.updatedAt,
          ),
        );

    return item;
  }

  /// Actualiza los límites de stock
  Future<InventoryItem> updateStockLimits(
    String inventoryId,
    double minQty,
    double maxQty,
  ) async {
    await (db.update(
      db.inventory,
    )..where((t) => t.id.equals(inventoryId))).write(
      InventoryCompanion(
        minQty: Value(minQty),
        maxQty: Value(maxQty),
        updatedAt: Value(DateTime.now()),
      ),
    );

    final updated = await (db.select(
      db.inventory,
    )..where((t) => t.id.equals(inventoryId))).getSingle();

    return _mapToEntity(updated);
  }

  /// Obtiene el historial de ajustes
  Future<List<domain.InventoryAdjustment>> getAdjustmentHistory(
    String inventoryId,
  ) async {
    final results =
        await (db.select(db.inventoryAdjustments)
              ..where((t) => t.inventoryId.equals(inventoryId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return results.map(_mapAdjustmentToEntity).toList();
  }

  /// Obtiene estadísticas de inventario
  Future<Map<String, dynamic>> getInventoryStats(String storeId) async {
    final items = await getStoreInventory(storeId);

    final totalProducts = items.length;
    final lowStockItems = items.where((i) => i.isLowStock).length;
    final outOfStockItems = items.where((i) => i.isOutOfStock).length;
    final totalValue = items.fold<double>(
      0,
      (sum, item) =>
          sum + (item.stockQty * 0), // Necesitaría el costo del producto
    );

    return {
      'totalProducts': totalProducts,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'totalValue': totalValue,
    };
  }

  /// Mapea de Drift a Entity
  InventoryItem _mapToEntity(InventoryData data) {
    return InventoryItem(
      id: data.id,
      storeId: data.storeId,
      productId: data.productId,
      variantId: data.variantId,
      stockQty: data.stockQty,
      minQty: data.minQty,
      maxQty: data.maxQty,
      updatedAt: data.updatedAt,
    );
  }

  /// Mapea de Drift a InventoryAdjustment Entity
  domain.InventoryAdjustment _mapAdjustmentToEntity(InventoryAdjustment data) {
    return domain.InventoryAdjustment(
      id: data.id,
      inventoryId: data.inventoryId,
      userId: data.userId,
      type: data.type,
      previousQty: data.previousQty,
      adjustmentQty: data.adjustmentQty,
      newQty: data.newQty,
      reason: data.reason,
      notes: data.notes,
      createdAt: data.createdAt,
    );
  }
}
