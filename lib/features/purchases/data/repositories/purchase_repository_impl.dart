import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_local_datasource.dart';
import '../datasources/purchase_remote_datasource.dart';

/// Implementación del repositorio de compras (Offline-First)
class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseLocalDataSource local;
  final PurchaseRemoteDataSource remote;

  PurchaseRepositoryImpl({required this.local, required this.remote});

  @override
  Future<Result<List<Purchase>>> getStorePurchases(String storeId) async {
    try {
      // Offline-First: retornar datos locales
      final purchases = await local.getStorePurchases(storeId);

      // Intentar sincronizar en segundo plano (sin esperar)
      _syncPurchasesInBackground(storeId);

      return Success(purchases);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al obtener compras locales'));
    }
  }

  @override
  Future<Result<List<Purchase>>> getPurchasesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final purchases = await local.getPurchasesByDateRange(
        storeId,
        startDate,
        endDate,
      );
      return Success(purchases);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al filtrar compras por fecha'));
    }
  }

  @override
  Future<Result<Purchase>> getPurchaseById(String id) async {
    try {
      final purchase = await local.getPurchaseById(id);
      if (purchase == null) {
        return Error(NotFoundFailure());
      }
      return Success(purchase);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al obtener compra'));
    }
  }

  @override
  Future<Result<List<Purchase>>> searchPurchasesBySupplier(
    String storeId,
    String supplierId,
  ) async {
    try {
      final purchases = await local.searchPurchasesBySupplier(
        storeId,
        supplierId,
      );
      return Success(purchases);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al buscar compras por proveedor'),
      );
    }
  }

  @override
  Future<Result<List<Purchase>>> searchPurchasesByInvoice(
    String storeId,
    String query,
  ) async {
    try {
      final purchases = await local.searchPurchasesByInvoice(storeId, query);
      return Success(purchases);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al buscar compras por factura'),
      );
    }
  }

  @override
  Future<Result<Purchase>> createPurchase(Purchase purchase) async {
    try {
      // Guardar localmente primero
      final created = await local.createPurchase(purchase);

      // Intentar subir a Supabase en segundo plano
      _uploadPurchaseInBackground(purchase);

      return Success(created);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al crear compra'));
    }
  }

  @override
  Future<Result<void>> cancelPurchase(String id) async {
    try {
      // Cancelar localmente primero
      await local.cancelPurchase(id);

      // Intentar cancelar en Supabase en segundo plano
      _cancelPurchaseInBackground(id);

      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al cancelar compra'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getPurchasesStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await local.getPurchasesStats(storeId, startDate, endDate);
      return Success(stats);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al obtener estadísticas'));
    }
  }

  @override
  Future<Result<List<Purchase>>> getTodayPurchases(String storeId) async {
    try {
      final purchases = await local.getTodayPurchases(storeId);
      return Success(purchases);
    } catch (e) {
      return Error(CacheFailure(message: 'Error al obtener compras del día'));
    }
  }

  @override
  Future<Result<List<Supplier>>> getActiveSuppliers() async {
    try {
      // Intentar obtener de Supabase primero
      final suppliers = await remote.getActiveSuppliers();
      return Success(suppliers);
    } catch (e) {
      // Si falla, retornar lista vacía (podríamos cachear localmente)
      return Error(ServerFailure(message: 'Error al obtener proveedores'));
    }
  }

  @override
  Future<Result<Supplier>> getSupplierById(String id) async {
    try {
      final suppliers = await remote.getActiveSuppliers();
      final supplier = suppliers.firstWhere((s) => s.id == id);
      return Success(supplier);
    } catch (e) {
      return Error(NotFoundFailure());
    }
  }

  @override
  Future<Result<Supplier>> createSupplier(Supplier supplier) async {
    try {
      await remote.uploadSupplier(supplier);
      return Success(supplier);
    } catch (e) {
      return Error(ServerFailure(message: 'Error al crear proveedor'));
    }
  }

  @override
  Future<Result<Supplier>> updateSupplier(Supplier supplier) async {
    try {
      await remote.uploadSupplier(supplier);
      return Success(supplier);
    } catch (e) {
      return Error(ServerFailure(message: 'Error al actualizar proveedor'));
    }
  }

  @override
  Future<Result<void>> deactivateSupplier(String id) async {
    try {
      final result = await getSupplierById(id);
      if (result.isError) {
        return Error(NotFoundFailure());
      }

      final supplier = result.valueOrNull!;
      final deactivated = supplier.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      await remote.uploadSupplier(deactivated);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Error al desactivar proveedor'));
    }
  }

  @override
  Future<Result<void>> syncWithRemote(String storeId) async {
    try {
      // Obtener compras remotas para mantener cache
      await remote.getStorePurchases(storeId);

      // Aquí se podría implementar lógica de merge
      // Por ahora solo retornamos éxito
      return const Success(null);
    } catch (e) {
      return Error(
        ServerFailure(message: 'Error al sincronizar con el servidor'),
      );
    }
  }

  // ======================= Background Sync =======================

  void _syncPurchasesInBackground(String storeId) {
    // No esperar, ejecutar en segundo plano
    remote
        .getStorePurchases(storeId)
        .then((remotePurchases) {
          // Aquí se podría implementar lógica de merge o actualización
          // Por ahora solo obtiene para mantener cache actualizado
        })
        .catchError((error) {
          // Silenciar errores de sincronización en segundo plano
        });
  }

  void _uploadPurchaseInBackground(Purchase purchase) {
    remote.uploadPurchase(purchase).catchError((error) {
      // TODO: Agregar a cola de operaciones pendientes
    });
  }

  void _cancelPurchaseInBackground(String id) {
    remote.cancelPurchase(id).catchError((error) {
      // TODO: Agregar a cola de operaciones pendientes
    });
  }
}
