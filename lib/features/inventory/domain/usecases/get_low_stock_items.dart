import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Caso de uso para obtener productos con stock bajo
class GetLowStockItemsUseCase {
  final InventoryRepository repository;

  GetLowStockItemsUseCase(this.repository);

  Future<List<InventoryItem>> call(String storeId) async {
    return await repository.getLowStockItems(storeId);
  }
}
