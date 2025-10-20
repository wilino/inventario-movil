import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_local_datasource.dart';
import '../datasources/inventory_remote_datasource.dart';

/// Implementación del repositorio de inventario con estrategia offline-first
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryLocalDataSource localDataSource;
  final InventoryRemoteDataSource remoteDataSource;

  InventoryRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<InventoryItem>> getStoreInventory(String storeId) async {
    try {
      // Offline-first: Intentar local primero
      final local = await localDataSource.getStoreInventory(storeId);
      
      // Intentar sincronizar en segundo plano
      _syncInBackground(() async {
        final remote = await remoteDataSource.getStoreInventory(storeId);
        // Aquí podrías actualizar la base de datos local si es necesario
      });

      return local;
    } catch (e) {
      print('Error al obtener inventario: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryItem>> getProductInventory(String productId) async {
    try {
      final local = await localDataSource.getProductInventory(productId);
      
      _syncInBackground(() async {
        await remoteDataSource.getProductInventory(productId);
      });

      return local;
    } catch (e) {
      print('Error al obtener inventario del producto: $e');
      rethrow;
    }
  }

  @override
  Future<InventoryItem?> getInventoryItem(
    String storeId,
    String productId,
  ) async {
    try {
      final local = await localDataSource.getInventoryItem(storeId, productId);
      
      _syncInBackground(() async {
        await remoteDataSource.getInventoryItem(storeId, productId);
      });

      return local;
    } catch (e) {
      print('Error al obtener ítem de inventario: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryItem>> getLowStockItems(String storeId) async {
    try {
      final local = await localDataSource.getLowStockItems(storeId);
      
      _syncInBackground(() async {
        await remoteDataSource.getLowStockItems(storeId);
      });

      return local;
    } catch (e) {
      print('Error al obtener productos con stock bajo: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryItem>> getOutOfStockItems(String storeId) async {
    try {
      final local = await localDataSource.getOutOfStockItems(storeId);
      
      _syncInBackground(() async {
        await remoteDataSource.getOutOfStockItems(storeId);
      });

      return local;
    } catch (e) {
      print('Error al obtener productos agotados: $e');
      rethrow;
    }
  }

  @override
  Future<InventoryItem> adjustInventory(
    String inventoryId,
    double newQty,
    String userId,
    String type,
    String? reason,
    String? notes,
  ) async {
    try {
      // Actualizar local primero
      final updated = await localDataSource.adjustInventory(
        inventoryId,
        newQty,
        userId,
        type,
        reason,
        notes,
      );

      // Intentar sincronizar con remoto
      _syncInBackground(() async {
        await remoteDataSource.adjustInventory(
          inventoryId,
          newQty,
          userId,
          type,
          reason,
          notes,
        );
      });

      return updated;
    } catch (e) {
      print('Error al ajustar inventario: $e');
      rethrow;
    }
  }

  @override
  Future<InventoryItem> createInventoryItem(InventoryItem item) async {
    try {
      // Crear local primero
      final created = await localDataSource.createInventoryItem(item);

      // Intentar sincronizar con remoto
      _syncInBackground(() async {
        await remoteDataSource.createInventoryItem(item);
      });

      return created;
    } catch (e) {
      print('Error al crear ítem de inventario: $e');
      rethrow;
    }
  }

  @override
  Future<InventoryItem> updateStockLimits(
    String inventoryId,
    double minQty,
    double maxQty,
  ) async {
    try {
      // Actualizar local primero
      final updated = await localDataSource.updateStockLimits(
        inventoryId,
        minQty,
        maxQty,
      );

      // Intentar sincronizar con remoto
      _syncInBackground(() async {
        await remoteDataSource.updateStockLimits(
          inventoryId,
          minQty,
          maxQty,
        );
      });

      return updated;
    } catch (e) {
      print('Error al actualizar límites de stock: $e');
      rethrow;
    }
  }

  @override
  Future<List<InventoryAdjustment>> getAdjustmentHistory(
    String inventoryId,
  ) async {
    try {
      final local = await localDataSource.getAdjustmentHistory(inventoryId);
      
      _syncInBackground(() async {
        await remoteDataSource.getAdjustmentHistory(inventoryId);
      });

      return local;
    } catch (e) {
      print('Error al obtener historial de ajustes: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryStats(String storeId) async {
    try {
      final local = await localDataSource.getInventoryStats(storeId);
      
      _syncInBackground(() async {
        await remoteDataSource.getInventoryStats(storeId);
      });

      return local;
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      rethrow;
    }
  }

  /// Ejecuta una operación en segundo plano sin bloquear
  void _syncInBackground(Future<void> Function() operation) {
    operation().catchError((e) {
      print('Error en sincronización en segundo plano: $e');
    });
  }
}
