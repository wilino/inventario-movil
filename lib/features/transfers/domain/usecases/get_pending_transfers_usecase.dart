import '../../../../core/utils/result.dart';
import '../entities/transfer.dart';
import '../repositories/transfer_repository.dart';

/// UseCase para obtener transferencias pendientes
class GetPendingTransfersUseCase {
  final TransferRepository repository;

  GetPendingTransfersUseCase(this.repository);

  Future<Result<List<Transfer>>> call(String storeId) async {
    return await repository.getPendingTransfers(storeId);
  }
}
