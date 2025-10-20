import '../../../../core/utils/result.dart';
import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// Caso de uso para obtener las compras de una tienda
class GetStorePurchasesUseCase {
  final PurchaseRepository repository;

  GetStorePurchasesUseCase(this.repository);

  Future<Result<List<Purchase>>> call(String storeId) async {
    return await repository.getStorePurchases(storeId);
  }
}
