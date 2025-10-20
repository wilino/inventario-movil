import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

/// Caso de uso para obtener las ventas del día
class GetTodaySalesUseCase {
  final SaleRepository repository;

  GetTodaySalesUseCase(this.repository);

  Future<List<Sale>> call(String storeId) async {
    return await repository.getTodaySales(storeId);
  }
}
