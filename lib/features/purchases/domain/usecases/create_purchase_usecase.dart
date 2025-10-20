import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/purchase.dart';
import '../repositories/purchase_repository.dart';

/// Caso de uso para crear una compra
class CreatePurchaseUseCase {
  final PurchaseRepository repository;

  CreatePurchaseUseCase(this.repository);

  Future<Result<Purchase>> call(Purchase purchase) async {
    // Validaciones
    if (purchase.items.isEmpty) {
      return const Error(
        ValidationFailure(message: 'La compra debe tener al menos un producto'),
      );
    }

    if (purchase.total <= 0) {
      return const Error(
        ValidationFailure(
          message: 'El total de la compra debe ser mayor a cero',
        ),
      );
    }

    if (purchase.supplierName.trim().isEmpty) {
      return const Error(
        ValidationFailure(message: 'Debe especificar un proveedor'),
      );
    }

    return await repository.createPurchase(purchase);
  }
}
