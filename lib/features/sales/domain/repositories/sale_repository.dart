import '../../../../core/utils/result.dart';
import '../entities/sale.dart';

/// Repositorio abstracto para el manejo de ventas
abstract class SaleRepository {
  /// Obtiene todas las ventas de una tienda
  Future<Result<List<Sale>>> getStoreSales(String storeId);

  /// Obtiene ventas por rango de fechas
  Future<Result<List<Sale>>> getSalesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Obtiene una venta específica por ID
  Future<Result<Sale>> getSaleById(String id);

  /// Busca ventas por cliente
  Future<Result<List<Sale>>> searchSalesByCustomer(
    String storeId,
    String query,
  );

  /// Crea una nueva venta
  Future<Result<Sale>> createSale(Sale sale);

  /// Cancela una venta (soft delete)
  Future<Result<void>> cancelSale(String id);

  /// Obtiene estadísticas de ventas
  Future<Result<Map<String, dynamic>>> getSalesStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene las ventas del día actual
  Future<Result<List<Sale>>> getTodaySales(String storeId);

  /// Obtiene el top de productos más vendidos
  Future<Result<List<Map<String, dynamic>>>> getTopSellingProducts(
    String storeId,
    int limit,
  );

  /// Sincroniza las ventas locales con el servidor remoto
  Future<Result<void>> syncWithRemote(String storeId);
}
