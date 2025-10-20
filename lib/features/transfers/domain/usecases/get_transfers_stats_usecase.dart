import '../../../../core/utils/result.dart';
import '../repositories/transfer_repository.dart';

/// UseCase para obtener estadísticas de transferencias
class GetTransfersStatsUseCase {
  final TransferRepository repository;

  GetTransfersStatsUseCase(this.repository);

  Future<Result<Map<String, dynamic>>> call(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getTransfersStats(
      storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
