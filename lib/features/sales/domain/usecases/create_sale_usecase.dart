import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/sale.dart';
import '../repositories/sale_repository.dart';

/// Caso de uso para crear una venta
class CreateSaleUseCase {
  final SaleRepository repository;

  CreateSaleUseCase(this.repository);

  Future<Result<Sale>> call(Sale sale) async {
    // Validaciones
    if (sale.items.isEmpty) {
      return const Error(
        ValidationFailure(message: 'La venta debe tener al menos un producto'),
      );
    }

    if (sale.total <= 0) {
      return const Error(
        ValidationFailure(
          message: 'El total de la venta debe ser mayor a cero',
        ),
      );
    }

    return await repository.createSale(sale);
  }
}
