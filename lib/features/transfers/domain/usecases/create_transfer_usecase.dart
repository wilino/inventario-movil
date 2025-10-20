import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/transfer.dart';
import '../repositories/transfer_repository.dart';

/// UseCase para crear una transferencia
class CreateTransferUseCase {
  final TransferRepository repository;

  CreateTransferUseCase(this.repository);

  Future<Result<Transfer>> call(Transfer transfer) async {
    // Validaciones
    if (transfer.qty <= 0) {
      return Error(
        ValidationFailure(message: 'La cantidad debe ser mayor a 0'),
      );
    }

    if (transfer.fromStoreId == transfer.toStoreId) {
      return Error(
        ValidationFailure(message: 'No se puede transferir a la misma tienda'),
      );
    }

    if (transfer.fromStoreId.isEmpty) {
      return Error(
        ValidationFailure(message: 'Debe especificar tienda de origen'),
      );
    }

    if (transfer.toStoreId.isEmpty) {
      return Error(
        ValidationFailure(message: 'Debe especificar tienda de destino'),
      );
    }

    if (transfer.productId.isEmpty) {
      return Error(ValidationFailure(message: 'Debe especificar un producto'));
    }

    // Crear transferencia
    return await repository.createTransfer(transfer);
  }
}
