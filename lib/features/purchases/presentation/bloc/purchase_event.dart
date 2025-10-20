import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/supplier.dart';

/// Eventos del Purchase BLoC
abstract class PurchaseEvent extends Equatable {
  const PurchaseEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar compras de una tienda
class LoadStorePurchases extends PurchaseEvent {
  final String storeId;

  const LoadStorePurchases(this.storeId);

  @override
  List<Object> get props => [storeId];
}

/// Cargar compras del día actual
class LoadTodayPurchases extends PurchaseEvent {
  final String storeId;

  const LoadTodayPurchases(this.storeId);

  @override
  List<Object> get props => [storeId];
}

/// Crear una nueva compra
class CreatePurchase extends PurchaseEvent {
  final Purchase purchase;

  const CreatePurchase(this.purchase);

  @override
  List<Object> get props => [purchase];
}

/// Cancelar una compra
class CancelPurchase extends PurchaseEvent {
  final String id;

  const CancelPurchase(this.id);

  @override
  List<Object> get props => [id];
}

/// Obtener detalle de una compra
class GetPurchaseDetail extends PurchaseEvent {
  final String id;

  const GetPurchaseDetail(this.id);

  @override
  List<Object> get props => [id];
}

/// Filtrar compras por rango de fechas
class FilterPurchasesByDateRange extends PurchaseEvent {
  final String storeId;
  final DateTime startDate;
  final DateTime endDate;

  const FilterPurchasesByDateRange(
    this.storeId,
    this.startDate,
    this.endDate,
  );

  @override
  List<Object> get props => [storeId, startDate, endDate];
}

/// Buscar compras por proveedor
class SearchPurchasesBySupplier extends PurchaseEvent {
  final String storeId;
  final String supplierId;

  const SearchPurchasesBySupplier(this.storeId, this.supplierId);

  @override
  List<Object> get props => [storeId, supplierId];
}

/// Buscar compras por factura
class SearchPurchasesByInvoice extends PurchaseEvent {
  final String storeId;
  final String query;

  const SearchPurchasesByInvoice(this.storeId, this.query);

  @override
  List<Object> get props => [storeId, query];
}

/// Cargar estadísticas de compras
class LoadPurchasesStats extends PurchaseEvent {
  final String storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadPurchasesStats(
    this.storeId, {
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Cargar proveedores activos
class LoadActiveSuppliers extends PurchaseEvent {
  const LoadActiveSuppliers();
}

/// Crear un proveedor
class CreateSupplier extends PurchaseEvent {
  final Supplier supplier;

  const CreateSupplier(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// Actualizar un proveedor
class UpdateSupplier extends PurchaseEvent {
  final Supplier supplier;

  const UpdateSupplier(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// Desactivar un proveedor
class DeactivateSupplier extends PurchaseEvent {
  final String id;

  const DeactivateSupplier(this.id);

  @override
  List<Object> get props => [id];
}

/// Sincronizar con el servidor
class SyncPurchases extends PurchaseEvent {
  final String storeId;

  const SyncPurchases(this.storeId);

  @override
  List<Object> get props => [storeId];
}
