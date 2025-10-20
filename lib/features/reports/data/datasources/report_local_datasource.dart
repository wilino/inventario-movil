import 'package:drift/drift.dart';
import '../../../../core/config/database.dart';
import '../../domain/entities/report.dart';

/// Data source local para reportes
class ReportLocalDataSource {
  final AppDatabase db;

  ReportLocalDataSource(this.db);

  /// Genera dashboard con datos consolidados
  Future<DashboardData> getDashboard({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    // Obtener ventas del período
    final sales =
        await (db.select(db.sales)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.at.isBiggerOrEqualValue(start) &
                  t.at.isSmallerOrEqualValue(end),
            ))
            .get();

    // Obtener compras del período
    final purchases =
        await (db.select(db.purchases)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.at.isBiggerOrEqualValue(start) &
                  t.at.isSmallerOrEqualValue(end),
            ))
            .get();

    // Obtener transferencias del período
    final transfers =
        await (db.select(db.transfers)..where(
              (t) =>
                  (t.fromStoreId.equals(storeId) |
                      t.toStoreId.equals(storeId)) &
                  t.createdAt.isBiggerOrEqualValue(start) &
                  t.createdAt.isSmallerOrEqualValue(end),
            ))
            .get();

    // Obtener alertas de stock bajo (comparar con minQty en memoria)
    final allInventory = await (db.select(
      db.inventory,
    )..where((t) => t.storeId.equals(storeId))).get();
    final lowStock = allInventory
        .where((item) => item.stockQty <= item.minQty)
        .toList();

    // Calcular métricas
    final totalRevenue = sales.fold<double>(0, (sum, sale) => sum + sale.total);
    final totalCosts = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.total,
    );
    final profit = totalRevenue - totalCosts;
    final profitMargin = totalRevenue > 0
        ? ((profit / totalRevenue) * 100).toDouble()
        : 0.0;

    // Ventas por día
    final revenueByDay = <String, double>{};
    for (final sale in sales) {
      final day = sale.at.toIso8601String().split('T')[0];
      revenueByDay[day] = (revenueByDay[day] ?? 0) + sale.total;
    }

    // Top productos
    final topProducts = await _getTopProducts(storeId, start, end);

    // Performance por tienda (mock - en producción obtener de múltiples tiendas)
    final storePerformance = {
      storeId: {'sales': totalRevenue, 'transactions': sales.length},
    };

    return DashboardData(
      generatedAt: DateTime.now(),
      totalRevenue: totalRevenue,
      totalCosts: totalCosts,
      profit: profit,
      profitMargin: profitMargin,
      totalSales: sales.length,
      totalPurchases: purchases.length,
      totalTransfers: transfers.length,
      lowStockAlerts: lowStock.length,
      revenueByDay: revenueByDay,
      topSellingProducts: topProducts,
      storePerformance: storePerformance,
    );
  }

  /// Genera reporte de ventas
  Future<SalesReport> getSalesReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final sales =
        await (db.select(db.sales)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.at.isBiggerOrEqualValue(startDate) &
                  t.at.isSmallerOrEqualValue(endDate),
            ))
            .get();

    final totalSales = sales.fold<double>(0, (sum, sale) => sum + sale.total);
    final avgTicket = sales.isNotEmpty
        ? (totalSales / sales.length).toDouble()
        : 0.0;

    // Ventas por día
    final salesByDay = <String, double>{};
    for (final sale in sales) {
      final day = sale.at.toIso8601String().split('T')[0];
      salesByDay[day] = (salesByDay[day] ?? 0) + sale.total;
    }

    // Top productos
    final topProducts = await _getTopProducts(storeId, startDate, endDate);

    // Ventas por tienda
    final salesByStore = {
      storeId: {'total': totalSales, 'transactions': sales.length},
    };

    return SalesReport(
      startDate: startDate,
      endDate: endDate,
      totalSales: totalSales,
      totalTransactions: sales.length,
      averageTicket: avgTicket,
      salesByDay: salesByDay,
      topProducts: topProducts,
      salesByStore: salesByStore,
    );
  }

  /// Genera reporte de compras
  Future<PurchasesReport> getPurchasesReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final purchases =
        await (db.select(db.purchases)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.at.isBiggerOrEqualValue(startDate) &
                  t.at.isSmallerOrEqualValue(endDate),
            ))
            .get();

    final totalPurchases = purchases.fold<double>(
      0,
      (sum, purchase) => sum + purchase.total,
    );
    final avgPurchase = purchases.isNotEmpty
        ? (totalPurchases / purchases.length).toDouble()
        : 0.0;

    // Compras por día
    final purchasesByDay = <String, double>{};
    for (final purchase in purchases) {
      final day = purchase.at.toIso8601String().split('T')[0];
      purchasesByDay[day] = (purchasesByDay[day] ?? 0) + purchase.total;
    }

    // Top proveedores
    final topSuppliers = await _getTopSuppliers(storeId, startDate, endDate);

    // Compras por tienda
    final purchasesByStore = {
      storeId: {'total': totalPurchases, 'transactions': purchases.length},
    };

    return PurchasesReport(
      startDate: startDate,
      endDate: endDate,
      totalPurchases: totalPurchases,
      totalTransactions: purchases.length,
      averagePurchase: avgPurchase,
      purchasesByDay: purchasesByDay,
      topSuppliers: topSuppliers,
      purchasesByStore: purchasesByStore,
    );
  }

  /// Genera reporte de inventario
  Future<InventoryReport> getInventoryReport({required String storeId}) async {
    final inventory = await (db.select(
      db.inventory,
    )..where((t) => t.storeId.equals(storeId))).get();

    final totalProducts = inventory.length;
    // Valor estimado usando precio promedio (en producción calcular desde productos)
    final avgPrice = 100.0; // Mock - debería venir de la tabla de productos
    final totalValue = inventory.fold<double>(
      0,
      (sum, item) => sum + (item.stockQty * avgPrice),
    );

    final lowStock = inventory
        .where((item) => item.stockQty <= item.minQty)
        .toList();
    final outOfStock = inventory.where((item) => item.stockQty == 0).toList();

    // Inventario por tienda
    final inventoryByStore = {
      storeId: {'products': totalProducts, 'value': totalValue},
    };

    // Productos por categoría (mock - requiere relación con productos)
    final productsByCategory = <String, int>{
      'Electrónica': (totalProducts * 0.4).round(),
      'Accesorios': (totalProducts * 0.3).round(),
      'Otros': (totalProducts * 0.3).round(),
    };

    // Items con stock bajo
    final lowStockItems = lowStock
        .map(
          (item) => {
            'productId': item.productId,
            'variantId': item.variantId,
            'currentStock': item.stockQty,
            'minQty': item.minQty,
          },
        )
        .toList();

    return InventoryReport(
      generatedAt: DateTime.now(),
      totalProducts: totalProducts,
      totalValue: totalValue,
      lowStockProducts: lowStock.length,
      outOfStockProducts: outOfStock.length,
      inventoryByStore: inventoryByStore,
      productsByCategory: productsByCategory,
      lowStockItems: lowStockItems,
    );
  }

  /// Genera reporte de transferencias
  Future<TransfersReport> getTransfersReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transfers =
        await (db.select(db.transfers)..where(
              (t) =>
                  (t.fromStoreId.equals(storeId) |
                      t.toStoreId.equals(storeId)) &
                  t.createdAt.isBiggerOrEqualValue(startDate) &
                  t.createdAt.isSmallerOrEqualValue(endDate),
            ))
            .get();

    final pending = transfers.where((t) => t.status == 'pending').length;
    final inTransit = transfers.where((t) => t.status == 'in_transit').length;
    final completed = transfers.where((t) => t.status == 'completed').length;
    final cancelled = transfers.where((t) => t.status == 'cancelled').length;

    // Transferencias por día
    final transfersByDay = <String, int>{};
    for (final transfer in transfers) {
      final day = transfer.createdAt.toIso8601String().split('T')[0];
      transfersByDay[day] = (transfersByDay[day] ?? 0) + 1;
    }

    // Transferencias por tienda
    final outgoing = transfers.where((t) => t.fromStoreId == storeId).length;
    final incoming = transfers.where((t) => t.toStoreId == storeId).length;

    final transfersByStore = {
      storeId: {
        'outgoing': outgoing,
        'incoming': incoming,
        'total': transfers.length,
      },
    };

    return TransfersReport(
      startDate: startDate,
      endDate: endDate,
      totalTransfers: transfers.length,
      pendingTransfers: pending,
      inTransitTransfers: inTransit,
      completedTransfers: completed,
      cancelledTransfers: cancelled,
      transfersByStore: transfersByStore,
      transfersByDay: transfersByDay,
    );
  }

  /// Obtiene los productos más vendidos
  Future<Map<String, dynamic>> _getTopProducts(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Obtener sale items agrupados por producto
    final saleItems = await (db.select(db.saleItems)..limit(100)).get();

    final products = <String, Map<String, dynamic>>{};
    for (final item in saleItems) {
      final key = item.productId;
      if (products.containsKey(key)) {
        products[key]!['quantity'] += item.qty;
        products[key]!['total'] += item.total;
      } else {
        products[key] = {
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.qty,
          'total': item.total,
        };
      }
    }

    return products;
  }

  /// Obtiene los proveedores con más compras
  Future<Map<String, dynamic>> _getTopSuppliers(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final purchases =
        await (db.select(db.purchases)..where(
              (t) =>
                  t.storeId.equals(storeId) &
                  t.at.isBiggerOrEqualValue(startDate) &
                  t.at.isSmallerOrEqualValue(endDate),
            ))
            .get();

    final suppliers = <String, Map<String, dynamic>>{};
    for (final purchase in purchases) {
      final key = purchase.supplierId;
      if (suppliers.containsKey(key)) {
        suppliers[key]!['count'] += 1;
        suppliers[key]!['total'] += purchase.total;
      } else {
        suppliers[key] = {
          'supplierId': key,
          'supplierName': purchase.supplierName,
          'count': 1,
          'total': purchase.total,
        };
      }
    }

    return suppliers;
  }
}
