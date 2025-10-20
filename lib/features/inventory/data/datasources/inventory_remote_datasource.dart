import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_adjustment.dart';

/// Data source remoto para el manejo de inventario con Supabase
class InventoryRemoteDataSource {
  final SupabaseClient client = SupabaseConfig.client;

  /// Obtiene el inventario de una tienda
  Future<List<InventoryItem>> getStoreInventory(String storeId) async {
    final response = await client
        .from('inventory')
        .select()
        .eq('store_id', storeId);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene el inventario de un producto
  Future<List<InventoryItem>> getProductInventory(String productId) async {
    final response = await client
        .from('inventory')
        .select()
        .eq('product_id', productId);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene un ítem de inventario específico
  Future<InventoryItem?> getInventoryItem(
    String storeId,
    String productId,
  ) async {
    final response = await client
        .from('inventory')
        .select()
        .eq('store_id', storeId)
        .eq('product_id', productId)
        .maybeSingle();

    return response != null ? _mapToEntity(response) : null;
  }

  /// Obtiene productos con stock bajo
  Future<List<InventoryItem>> getLowStockItems(String storeId) async {
    final response = await client
        .from('inventory')
        .select()
        .eq('store_id', storeId)
        .filter('stock_qty', 'lte', 'min_qty');

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene productos agotados
  Future<List<InventoryItem>> getOutOfStockItems(String storeId) async {
    final response = await client
        .from('inventory')
        .select()
        .eq('store_id', storeId)
        .lte('stock_qty', 0);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Ajusta el inventario
  Future<InventoryItem> adjustInventory(
    String inventoryId,
    double newQty,
    String userId,
    String type,
    String? reason,
    String? notes,
  ) async {
    // Obtener el ítem actual
    final current = await client
        .from('inventory')
        .select()
        .eq('id', inventoryId)
        .single();

    final previousQty = (current['stock_qty'] as num).toDouble();
    final adjustmentQty = newQty - previousQty;

    // Actualizar el stock
    await client
        .from('inventory')
        .update({
          'stock_qty': newQty,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inventoryId);

    // Registrar el ajuste
    await client.from('inventory_adjustments').insert({
      'inventory_id': inventoryId,
      'user_id': userId,
      'type': type,
      'previous_qty': previousQty,
      'adjustment_qty': adjustmentQty,
      'new_qty': newQty,
      'reason': reason,
      'notes': notes,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Retornar el ítem actualizado
    final updated = await client
        .from('inventory')
        .select()
        .eq('id', inventoryId)
        .single();

    return _mapToEntity(updated);
  }

  /// Crea un nuevo registro de inventario
  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    await client.from('inventory').insert({
      'id': item.id,
      'store_id': item.storeId,
      'product_id': item.productId,
      'variant_id': item.variantId,
      'stock_qty': item.stockQty,
      'min_qty': item.minQty,
      'max_qty': item.maxQty,
      'updated_at': item.updatedAt.toIso8601String(),
    });

    return item;
  }

  /// Actualiza los límites de stock
  Future<InventoryItem> updateStockLimits(
    String inventoryId,
    double minQty,
    double maxQty,
  ) async {
    final response = await client
        .from('inventory')
        .update({
          'min_qty': minQty,
          'max_qty': maxQty,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', inventoryId)
        .select()
        .single();

    return _mapToEntity(response);
  }

  /// Obtiene el historial de ajustes
  Future<List<InventoryAdjustment>> getAdjustmentHistory(
    String inventoryId,
  ) async {
    final response = await client
        .from('inventory_adjustments')
        .select()
        .eq('inventory_id', inventoryId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => _mapAdjustmentToEntity(json))
        .toList();
  }

  /// Obtiene estadísticas de inventario
  Future<Map<String, dynamic>> getInventoryStats(String storeId) async {
    final items = await getStoreInventory(storeId);

    final totalProducts = items.length;
    final lowStockItems = items.where((i) => i.isLowStock).length;
    final outOfStockItems = items.where((i) => i.isOutOfStock).length;

    return {
      'totalProducts': totalProducts,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
    };
  }

  /// Mapea de JSON a Entity
  InventoryItem _mapToEntity(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      stockQty: (json['stock_qty'] as num).toDouble(),
      minQty: (json['min_qty'] as num).toDouble(),
      maxQty: (json['max_qty'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Mapea de JSON a InventoryAdjustment Entity
  InventoryAdjustment _mapAdjustmentToEntity(Map<String, dynamic> json) {
    return InventoryAdjustment(
      id: json['id'] as String,
      inventoryId: json['inventory_id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      previousQty: (json['previous_qty'] as num).toDouble(),
      adjustmentQty: (json['adjustment_qty'] as num).toDouble(),
      newQty: (json['new_qty'] as num).toDouble(),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
