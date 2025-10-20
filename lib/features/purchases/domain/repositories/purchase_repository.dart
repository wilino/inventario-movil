import '../../../../core/utils/result.dart';
import '../entities/purchase.dart';
import '../entities/supplier.dart';

/// Repositorio abstracto para el manejo de compras
abstract class PurchaseRepository {
  /// Obtiene todas las compras de una tienda
  Future<Result<List<Purchase>>> getStorePurchases(String storeId);

  /// Obtiene compras por rango de fechas
  Future<Result<List<Purchase>>> getPurchasesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Obtiene una compra específica por ID
  Future<Result<Purchase>> getPurchaseById(String id);

  /// Busca compras por proveedor
  Future<Result<List<Purchase>>> searchPurchasesBySupplier(
    String storeId,
    String supplierId,
  );

  /// Busca compras por número de factura
  Future<Result<List<Purchase>>> searchPurchasesByInvoice(
    String storeId,
    String invoiceNumber,
  );

  /// Crea una nueva compra
  Future<Result<Purchase>> createPurchase(Purchase purchase);

  /// Cancela una compra (soft delete)
  Future<Result<void>> cancelPurchase(String id);

  /// Obtiene estadísticas de compras
  Future<Result<Map<String, dynamic>>> getPurchasesStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Obtiene las compras del día actual
  Future<Result<List<Purchase>>> getTodayPurchases(String storeId);

  /// Sincroniza las compras locales con el servidor remoto
  Future<Result<void>> syncWithRemote(String storeId);

  // Métodos para proveedores

  /// Obtiene todos los proveedores activos
  Future<Result<List<Supplier>>> getActiveSuppliers();

  /// Obtiene un proveedor por ID
  Future<Result<Supplier>> getSupplierById(String id);

  /// Crea un nuevo proveedor
  Future<Result<Supplier>> createSupplier(Supplier supplier);

  /// Actualiza un proveedor
  Future<Result<Supplier>> updateSupplier(Supplier supplier);

  /// Desactiva un proveedor
  Future<Result<void>> deactivateSupplier(String id);
}
