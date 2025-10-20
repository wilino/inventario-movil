import '../entities/sale.dart';

/// Repositorio abstracto para el manejo de ventas
abstract class SaleRepository {
  /// Obtiene todas las ventas de una tienda
  Future<List<Sale>> getStoreSales(String storeId);

  /// Obtiene ventas por rango de fechas
  Future<List<Sale>> getSalesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Obtiene una venta específica por ID
  Future<Sale?> getSaleById(String id);

  /// Busca ventas por cliente
  Future<List<Sale>> searchSalesByCustomer(String storeId, String query);

  /// Crea una nueva venta
  Future<Sale> createSale(Sale sale);

  /// Cancela una venta (soft delete)
  Future<void> cancelSale(String id);

  /// Obtiene estadísticas de ventas
  Future<Map<String, dynamic>> getSalesStats(
    String storeId,
    DateTime? startDate,
    DateTime? endDate,
  );

  /// Obtiene las ventas del día actual
  Future<List<Sale>> getTodaySales(String storeId);

  /// Obtiene el top de productos más vendidos
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    String storeId,
    int limit,
  );
}
