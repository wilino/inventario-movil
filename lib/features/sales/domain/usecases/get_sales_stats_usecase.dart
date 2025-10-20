import '../repositories/sale_repository.dart';

/// Caso de uso para obtener estadísticas de ventas
class GetSalesStatsUseCase {
  final SaleRepository repository;

  GetSalesStatsUseCase(this.repository);

  Future<Map<String, dynamic>> call(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getSalesStats(storeId, startDate, endDate);
  }
}
