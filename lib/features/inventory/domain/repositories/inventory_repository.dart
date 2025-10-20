import '../entities/inventory_item.dart';
import '../entities/inventory_adjustment.dart';

/// Repositorio abstracto para el manejo de inventario
abstract class InventoryRepository {
  /// Obtiene el inventario de una tienda específica
  Future<List<InventoryItem>> getStoreInventory(String storeId);

  /// Obtiene el inventario de un producto específico en todas las tiendas
  Future<List<InventoryItem>> getProductInventory(String productId);

  /// Obtiene un ítem de inventario específico
  Future<InventoryItem?> getInventoryItem(
    String storeId,
    String productId,
  );

  /// Obtiene productos con stock bajo
  Future<List<InventoryItem>> getLowStockItems(String storeId);

  /// Obtiene productos agotados
  Future<List<InventoryItem>> getOutOfStockItems(String storeId);

  /// Ajusta el inventario de un producto
  Future<InventoryItem> adjustInventory(
    String inventoryId,
    double newQty,
    String userId,
    String type,
    String? reason,
    String? notes,
  );

  /// Crea un nuevo registro de inventario
  Future<InventoryItem> createInventoryItem(InventoryItem item);

  /// Actualiza los límites de stock (min/max)
  Future<InventoryItem> updateStockLimits(
    String inventoryId,
    double minQty,
    double maxQty,
  );

  /// Obtiene el historial de ajustes de un ítem de inventario
  Future<List<InventoryAdjustment>> getAdjustmentHistory(
    String inventoryId,
  );

  /// Obtiene estadísticas de inventario para una tienda
  Future<Map<String, dynamic>> getInventoryStats(String storeId);
}
