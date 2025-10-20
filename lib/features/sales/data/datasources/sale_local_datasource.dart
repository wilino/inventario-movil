import 'package:drift/drift.dart';
import '../../../../core/config/database.dart';
import '../../domain/entities/sale.dart' as domain;

/// Data source local para el manejo de ventas con Drift
class SaleLocalDataSource {
  final AppDatabase db;

  SaleLocalDataSource(this.db);

  /// Obtiene todas las ventas de una tienda
  Future<List<domain.Sale>> getStoreSales(String storeId) async {
    final sales =
        await (db.select(db.sales)
              ..where(
                (t) => t.storeId.equals(storeId) & t.isDeleted.equals(false),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(sales.map((sale) => _mapToEntity(sale)));
  }

  /// Obtiene ventas por rango de fechas
  Future<List<domain.Sale>> getSalesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final sales =
        await (db.select(db.sales)
              ..where(
                (t) =>
                    t.storeId.equals(storeId) &
                    t.isDeleted.equals(false) &
                    t.at.isBiggerOrEqualValue(startDate) &
                    t.at.isSmallerOrEqualValue(endDate),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(sales.map((sale) => _mapToEntity(sale)));
  }

  /// Obtiene una venta específica por ID
  Future<domain.Sale?> getSaleById(String id) async {
    final sale = await (db.select(
      db.sales,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    return sale != null ? await _mapToEntity(sale) : null;
  }

  /// Busca ventas por cliente
  Future<List<domain.Sale>> searchSalesByCustomer(
    String storeId,
    String query,
  ) async {
    final sales =
        await (db.select(db.sales)
              ..where(
                (t) =>
                    t.storeId.equals(storeId) &
                    t.isDeleted.equals(false) &
                    t.customer.contains(query),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.at)]))
            .get();

    return Future.wait(sales.map((sale) => _mapToEntity(sale)));
  }

  /// Crea una nueva venta
  Future<domain.Sale> createSale(domain.Sale sale) async {
    await db.transaction(() async {
      // Insertar el encabezado de la venta
      await db
          .into(db.sales)
          .insert(
            SalesCompanion.insert(
              id: sale.id,
              storeId: sale.storeId,
              authorUserId: Value(sale.authorUserId),
              subtotal: sale.subtotal,
              discount: Value(sale.discount),
              tax: Value(sale.tax),
              total: sale.total,
              customer: Value(sale.customer),
              notes: Value(sale.notes),
              at: sale.at,
              createdAt: sale.createdAt,
              updatedAt: sale.updatedAt,
              isDeleted: Value(sale.isDeleted),
            ),
          );

      // Insertar los items de la venta
      for (final item in sale.items) {
        await db
            .into(db.saleItems)
            .insert(
              SaleItemsCompanion.insert(
                id: '${sale.id}_${item.productId}',
                saleId: sale.id,
                productId: item.productId,
                variantId: Value(item.variantId),
                productName: item.productName,
                qty: item.qty,
                unitPrice: item.unitPrice,
                total: item.total,
              ),
            );

        // Actualizar el inventario
        await _updateInventory(
          sale.storeId,
          item.productId,
          item.variantId,
          -item.qty,
        );
      }
    });

    return sale;
  }

  /// Cancela una venta (soft delete)
  Future<void> cancelSale(String id) async {
    final sale = await getSaleById(id);
    if (sale == null) throw Exception('Venta no encontrada');

    await db.transaction(() async {
      // Marcar como eliminada
      await (db.update(db.sales)..where((t) => t.id.equals(id))).write(
        SalesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Revertir inventario
      for (final item in sale.items) {
        await _updateInventory(
          sale.storeId,
          item.productId,
          item.variantId,
          item.qty, // Devolver al inventario
        );
      }
    });
  }

  /// Obtiene estadísticas de ventas
  Future<Map<String, dynamic>> getSalesStats(
    String storeId,
    DateTime? startDate,
    DateTime? endDate,
  ) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    final sales = await getSalesByDateRange(storeId, start, end);

    final totalSales = sales.length;
    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.total);
    final averageTicket = totalSales > 0 ? totalRevenue / totalSales : 0;
    final totalItems = sales.fold<int>(
      0,
      (sum, sale) => sum + sale.itemCount.toInt(),
    );

    return {
      'totalSales': totalSales,
      'totalRevenue': totalRevenue,
      'averageTicket': averageTicket,
      'totalItems': totalItems,
    };
  }

  /// Obtiene las ventas del día actual
  Future<List<domain.Sale>> getTodaySales(String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getSalesByDateRange(storeId, startOfDay, endOfDay);
  }

  /// Obtiene el top de productos más vendidos
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String storeId,
    int limit,
  ) async {
    // Obtener todas las ventas de la tienda
    final sales = await getStoreSales(storeId);

    // Agrupar por producto y contar
    final Map<String, Map<String, dynamic>> productSales = {};

    for (final sale in sales) {
      for (final item in sale.items) {
        if (productSales.containsKey(item.productId)) {
          productSales[item.productId]!['qty'] += item.qty;
          productSales[item.productId]!['total'] += item.total;
        } else {
          productSales[item.productId] = {
            'productId': item.productId,
            'productName': item.productName,
            'qty': item.qty,
            'total': item.total,
          };
        }
      }
    }

    // Ordenar por cantidad vendida
    final sorted = productSales.values.toList()
      ..sort((a, b) => (b['qty'] as double).compareTo(a['qty'] as double));

    return sorted.take(limit).toList();
  }

  /// Actualiza el inventario después de una venta
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

  /// Obtiene los items de una venta
  Future<List<domain.SaleItem>> _getSaleItems(String saleId) async {
    final items = await (db.select(
      db.saleItems,
    )..where((t) => t.saleId.equals(saleId))).get();

    return items.map((item) {
      return domain.SaleItem(
        productId: item.productId,
        variantId: item.variantId,
        productName: item.productName,
        qty: item.qty,
        unitPrice: item.unitPrice,
        total: item.total,
      );
    }).toList();
  }

  /// Mapea de Drift a Entity
  Future<domain.Sale> _mapToEntity(Sale data) async {
    final items = await _getSaleItems(data.id);

    return domain.Sale(
      id: data.id,
      storeId: data.storeId,
      authorUserId: data.authorUserId,
      items: items,
      subtotal: data.subtotal,
      discount: data.discount,
      tax: data.tax,
      total: data.total,
      customer: data.customer,
      notes: data.notes,
      at: data.at,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isDeleted: data.isDeleted,
    );
  }
}
