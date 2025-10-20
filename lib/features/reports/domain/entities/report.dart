import 'package:equatable/equatable.dart';

/// Entity que representa un reporte de ventas
class SalesReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final double totalSales;
  final int totalTransactions;
  final double averageTicket;
  final Map<String, dynamic> salesByDay;
  final Map<String, dynamic> topProducts;
  final Map<String, dynamic> salesByStore;

  const SalesReport({
    required this.startDate,
    required this.endDate,
    required this.totalSales,
    required this.totalTransactions,
    required this.averageTicket,
    required this.salesByDay,
    required this.topProducts,
    required this.salesByStore,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalSales,
        totalTransactions,
        averageTicket,
        salesByDay,
        topProducts,
        salesByStore,
      ];
}

/// Entity que representa un reporte de compras
class PurchasesReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final double totalPurchases;
  final int totalTransactions;
  final double averagePurchase;
  final Map<String, dynamic> purchasesByDay;
  final Map<String, dynamic> topSuppliers;
  final Map<String, dynamic> purchasesByStore;

  const PurchasesReport({
    required this.startDate,
    required this.endDate,
    required this.totalPurchases,
    required this.totalTransactions,
    required this.averagePurchase,
    required this.purchasesByDay,
    required this.topSuppliers,
    required this.purchasesByStore,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalPurchases,
        totalTransactions,
        averagePurchase,
        purchasesByDay,
        topSuppliers,
        purchasesByStore,
      ];
}

/// Entity que representa un reporte de inventario
class InventoryReport extends Equatable {
  final DateTime generatedAt;
  final int totalProducts;
  final double totalValue;
  final int lowStockProducts;
  final int outOfStockProducts;
  final Map<String, dynamic> inventoryByStore;
  final Map<String, dynamic> productsByCategory;
  final List<Map<String, dynamic>> lowStockItems;

  const InventoryReport({
    required this.generatedAt,
    required this.totalProducts,
    required this.totalValue,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.inventoryByStore,
    required this.productsByCategory,
    required this.lowStockItems,
  });

  @override
  List<Object?> get props => [
        generatedAt,
        totalProducts,
        totalValue,
        lowStockProducts,
        outOfStockProducts,
        inventoryByStore,
        productsByCategory,
        lowStockItems,
      ];
}

/// Entity que representa un reporte de transferencias
class TransfersReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransfers;
  final int pendingTransfers;
  final int inTransitTransfers;
  final int completedTransfers;
  final int cancelledTransfers;
  final Map<String, dynamic> transfersByStore;
  final Map<String, dynamic> transfersByDay;

  const TransfersReport({
    required this.startDate,
    required this.endDate,
    required this.totalTransfers,
    required this.pendingTransfers,
    required this.inTransitTransfers,
    required this.completedTransfers,
    required this.cancelledTransfers,
    required this.transfersByStore,
    required this.transfersByDay,
  });

  @override
  List<Object?> get props => [
        startDate,
        endDate,
        totalTransfers,
        pendingTransfers,
        inTransitTransfers,
        completedTransfers,
        cancelledTransfers,
        transfersByStore,
        transfersByDay,
      ];
}

/// Entity que representa el dashboard general
class DashboardData extends Equatable {
  final DateTime generatedAt;
  final double totalRevenue;
  final double totalCosts;
  final double profit;
  final double profitMargin;
  final int totalSales;
  final int totalPurchases;
  final int totalTransfers;
  final int lowStockAlerts;
  final Map<String, dynamic> revenueByDay;
  final Map<String, dynamic> topSellingProducts;
  final Map<String, dynamic> storePerformance;

  const DashboardData({
    required this.generatedAt,
    required this.totalRevenue,
    required this.totalCosts,
    required this.profit,
    required this.profitMargin,
    required this.totalSales,
    required this.totalPurchases,
    required this.totalTransfers,
    required this.lowStockAlerts,
    required this.revenueByDay,
    required this.topSellingProducts,
    required this.storePerformance,
  });

  @override
  List<Object?> get props => [
        generatedAt,
        totalRevenue,
        totalCosts,
        profit,
        profitMargin,
        totalSales,
        totalPurchases,
        totalTransfers,
        lowStockAlerts,
        revenueByDay,
        topSellingProducts,
        storePerformance,
      ];
}
