import '../../../../core/utils/result.dart';
import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// Caso de uso para obtener las compras del día actual
class GetTodayPurchasesUseCase {
  final PurchaseRepository repository;

  GetTodayPurchasesUseCase(this.repository);

  Future<Result<List<Purchase>>> call(String storeId) async {
    return await repository.getTodayPurchases(storeId);
  }
}
