import '../../../../core/utils/result.dart';
import '../entities/transfer.dart';
import '../repositories/transfer_repository.dart';

/// UseCase para obtener transferencias de una tienda
class GetStoreTransfersUseCase {
  final TransferRepository repository;

  GetStoreTransfersUseCase(this.repository);

  Future<Result<List<Transfer>>> call(String storeId) async {
    return await repository.getStoreTransfers(storeId);
  }
}
