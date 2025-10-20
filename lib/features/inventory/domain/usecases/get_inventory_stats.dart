import '../repositories/inventory_repository.dart';

/// Caso de uso para obtener estadísticas de inventario
class GetInventoryStatsUseCase {
  final InventoryRepository repository;

  GetInventoryStatsUseCase(this.repository);

  Future<Map<String, dynamic>> call(String storeId) async {
    return await repository.getInventoryStats(storeId);
  }
}
