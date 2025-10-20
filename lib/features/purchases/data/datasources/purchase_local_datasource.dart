import 'package:drift/drift.dart';
import '../../../../core/config/database.dart';
import '../../domain/entities/purchase.dart' as domain;

/// Data source local para el manejo de compras con Drift
class PurchaseLocalDataSource {
  final AppDatabase db;

  PurchaseLocalDataSource(this.db);

  /// Obtiene todas las compras de una tienda
  Future<List<domain.Purchase>> getStorePurchases(String storeId) async {
    final purchases =
        await (db.select(db.purchases)
              ..where(
                (t) => t.storeId.equals(storeId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(purchases.map((purchase) => _mapToEntity(purchase)));
  }

  /// Obtiene compras por rango de fechas
  Future<List<domain.Purchase>> getPurchasesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final purchases =
        await (db.select(db.purchases)
              ..where(
                (t) =>
                    t.storeId.equals(storeId) &
                    t.isDeleted.equals(false) &
                    t.at.isBiggerOrEqualValue(startDate) &
                    t.at.isSmallerOrEqualValue(endDate),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(purchases.map((purchase) => _mapToEntity(purchase)));
  }

  /// Obtiene una compra específica por ID
  Future<domain.Purchase?> getPurchaseById(String id) async {
    final purchase = await (db.select(
      db.purchases,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    return purchase != null ? await _mapToEntity(purchase) : null;
  }

  /// Busca compras por proveedor
  Future<List<domain.Purchase>> searchPurchasesBySupplier(
    String storeId,
    String supplierId,
  ) async {
    final purchases =
        await (db.select(db.purchases)
              ..where(
                (t) =>
                    t.storeId.equals(storeId) &
                    t.isDeleted.equals(false) &
                    t.supplierId.equals(supplierId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(purchases.map((purchase) => _mapToEntity(purchase)));
  }

  /// Busca compras por número de factura
  Future<List<domain.Purchase>> searchPurchasesByInvoice(
    String storeId,
    String query,
  ) async {
    final purchases =
        await (db.select(db.purchases)
              ..where(
                (t) =>
                    t.storeId.equals(storeId) &
                    t.isDeleted.equals(false) &
                    t.invoiceNumber.contains(query),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(purchases.map((purchase) => _mapToEntity(purchase)));
  }

  /// Crea una nueva compra
  Future<domain.Purchase> createPurchase(domain.Purchase purchase) async {
    await db.transaction(() async {
      // Insertar el encabezado de la compra
      await db
          .into(db.purchases)
          .insert(
            PurchasesCompanion.insert(
              id: purchase.id,
              storeId: purchase.storeId,
              supplierId: purchase.supplierId,
              supplierName: purchase.supplierName,
              authorUserId: purchase.authorUserId,
              subtotal: purchase.subtotal,
              discount: Value(purchase.discount),
              tax: Value(purchase.tax),
              total: purchase.total,
              invoiceNumber: Value(purchase.invoiceNumber),
              notes: Value(purchase.notes),
              at: purchase.at,
              createdAt: purchase.createdAt,
              updatedAt: purchase.updatedAt,
              isDeleted: Value(purchase.isDeleted),
            ),
          );

      // Insertar los items de la compra
      for (final item in purchase.items) {
        await db
            .into(db.purchaseItems)
            .insert(
              PurchaseItemsCompanion.insert(
                id: '${purchase.id}_${item.productId}',
                purchaseId: purchase.id,
                productId: item.productId,
                variantId: Value(item.variantId),
                productName: item.productName,
                qty: item.qty,
                unitCost: item.unitCost,
                total: item.total,
              ),
            );

        // Actualizar el inventario (INCREMENTAR en compras)
        await _updateInventory(
          purchase.storeId,
          item.productId,
          item.variantId,
          item.qty, // Positivo para incrementar
        );
      }
    });

    return purchase;
  }

  /// Cancela una compra (soft delete)
  Future<void> cancelPurchase(String id) async {
    final purchase = await getPurchaseById(id);
    if (purchase == null) throw Exception('Compra no encontrada');

    await db.transaction(() async {
      // Marcar como eliminada
      await (db.update(db.purchases)..where((t) => t.id.equals(id))).write(
        PurchasesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Revertir inventario (DECREMENTAR para cancelar compra)
      for (final item in purchase.items) {
        await _updateInventory(
          purchase.storeId,
          item.productId,
          item.variantId,
          -item.qty, // Negativo para revertir
        );
      }
    });
  }

  /// Obtiene estadísticas de compras
  Future<Map<String, dynamic>> getPurchasesStats(
    String storeId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final purchases = await getPurchasesByDateRange(storeId, start, end);

    final totalPurchases = purchases.length;
    final totalCost = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.total,
    );
    final averageCost = totalPurchases > 0 ? totalCost / totalPurchases : 0;
    final totalItems = purchases.fold<int>(
      0,
      (sum, purchase) => sum + purchase.itemCount.toInt(),
    );

    return {
      'totalPurchases': totalPurchases,
      'totalCost': totalCost,
      'averageCost': averageCost,
      'totalItems': totalItems,
    };
  }

  /// Obtiene las compras del día actual
  Future<List<domain.Purchase>> getTodayPurchases(String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getPurchasesByDateRange(storeId, startOfDay, endOfDay);
  }

  /// Actualiza el inventario después de una compra
  Future<void> _updateInventory(
    String storeId,
    String productId,
    String? variantId,
    double qtyChange,
  ) async {
    final inventory =
        await (db.select(db.inventory)..where(
              (t) => t.storeId.equals(storeId) & t.productId.equals(productId),
            ))
            .getSingleOrNull();

    if (inventory != null) {
      final newQty = inventory.stockQty + qtyChange;
      await (db.update(
        db.inventory,
      )..where((t) => t.id.equals(inventory.id))).write(
        InventoryCompanion(
          stockQty: Value(newQty),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Obtiene los items de una compra
  Future<List<domain.PurchaseItem>> _getPurchaseItems(String purchaseId) async {
    final items = await (db.select(
      db.purchaseItems,
    )..where((t) => t.purchaseId.equals(purchaseId))).get();

    return items.map((item) {
      return domain.PurchaseItem(
        productId: item.productId,
        variantId: item.variantId,
        productName: item.productName,
        qty: item.qty,
        unitCost: item.unitCost,
        total: item.total,
      );
    }).toList();
  }

  /// Mapea de Drift a Entity
  Future<domain.Purchase> _mapToEntity(Purchase data) async {
    final items = await _getPurchaseItems(data.id);

    return domain.Purchase(
      id: data.id,
      storeId: data.storeId,
      supplierId: data.supplierId,
      supplierName: data.supplierName,
      authorUserId: data.authorUserId,
      items: items,
      subtotal: data.subtotal,
      discount: data.discount,
      tax: data.tax,
      total: data.total,
      invoiceNumber: data.invoiceNumber,
      notes: data.notes,
      at: data.at,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isDeleted: data.isDeleted,
    );
  }
}
