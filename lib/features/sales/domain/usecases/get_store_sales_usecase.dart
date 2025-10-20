import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

/// Caso de uso para obtener las ventas de una tienda
class GetStoreSalesUseCase {
  final SaleRepository repository;

  GetStoreSalesUseCase(this.repository);

  Future<List<Sale>> call(String storeId) async {
    return await repository.getStoreSales(storeId);
  }
}
