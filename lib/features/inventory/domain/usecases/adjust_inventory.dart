import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

/// Parámetros para el ajuste de inventario
class AdjustInventoryParams {
  final String inventoryId;
  final double newQty;
  final String userId;
  final String type; // 'increment', 'decrement', 'set'
  final String? reason;
  final String? notes;

  const AdjustInventoryParams({
    required this.inventoryId,
    required this.newQty,
    required this.userId,
    required this.type,
    this.reason,
    this.notes,
  });
}

/// Caso de uso para ajustar el inventario
class AdjustInventoryUseCase {
  final InventoryRepository repository;

  AdjustInventoryUseCase(this.repository);

  Future<InventoryItem> call(AdjustInventoryParams params) async {
    // Validación
    if (params.newQty < 0) {
      throw Exception('La cantidad no puede ser negativa');
    }

    if (params.type != 'increment' &&
        params.type != 'decrement' &&
        params.type != 'set') {
      throw Exception(
        'Tipo de ajuste inválido. Use: increment, decrement o set',
      );
    }

    return await repository.adjustInventory(
      params.inventoryId,
      params.newQty,
      params.userId,
      params.type,
      params.reason,
      params.notes,
    );
  }
}
