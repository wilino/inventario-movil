import '../entities/inventory_adjustment.dart';
import '../repositories/inventory_repository.dart';

/// Caso de uso para obtener el historial de ajustes
class GetAdjustmentHistoryUseCase {
  final InventoryRepository repository;

  GetAdjustmentHistoryUseCase(this.repository);

  Future<List<InventoryAdjustment>> call(String inventoryId) async {
    return await repository.getAdjustmentHistory(inventoryId);
  }
}
