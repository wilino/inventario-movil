import '../../../../core/utils/result.dart';
import '../repositories/purchase_repository.dart';

/// Caso de uso para obtener estadísticas de compras
class GetPurchasesStatsUseCase {
  final PurchaseRepository repository;

  GetPurchasesStatsUseCase(this.repository);

  Future<Result<Map<String, dynamic>>> call(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getPurchasesStats(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
