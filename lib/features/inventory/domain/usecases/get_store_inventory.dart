import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Caso de uso para obtener el inventario de una tienda
class GetStoreInventoryUseCase {
  final InventoryRepository repository;

  GetStoreInventoryUseCase(this.repository);

  Future<List<InventoryItem>> call(String storeId) async {
    return await repository.getStoreInventory(storeId);
  }
}
