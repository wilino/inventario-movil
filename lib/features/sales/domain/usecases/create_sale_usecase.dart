import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

/// Caso de uso para crear una venta
class CreateSaleUseCase {
  final SaleRepository repository;

  CreateSaleUseCase(this.repository);

  Future<Sale> call(Sale sale) async {
    // Validaciones
    if (sale.items.isEmpty) {
      throw Exception('La venta debe tener al menos un producto');
    }

    if (sale.total <= 0) {
      throw Exception('El total de la venta debe ser mayor a cero');
    }

    return await repository.createSale(sale);
  }
}
