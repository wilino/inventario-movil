import 'package:equatable/equatable.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/supplier.dart';

/// Estados del Purchase BLoC
abstract class PurchaseState extends Equatable {
  const PurchaseState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PurchaseInitial extends PurchaseState {}

/// Cargando
class PurchaseLoading extends PurchaseState {}

/// Compras cargadas
class PurchasesLoaded extends PurchaseState {
  final List<Purchase> purchases;
  final Map<String, dynamic>? stats;

  const PurchasesLoaded(this.purchases, {this.stats});

  @override
  List<Object?> get props => [purchases, stats];
}

/// Compra creada exitosamente
class PurchaseCreated extends PurchaseState {
  final Purchase purchase;

  const PurchaseCreated(this.purchase);

  @override
  List<Object> get props => [purchase];
}

/// Compra cancelada exitosamente
class PurchaseCancelled extends PurchaseState {
  final String id;

  const PurchaseCancelled(this.id);

  @override
  List<Object> get props => [id];
}

/// Detalle de compra cargado
class PurchaseDetailLoaded extends PurchaseState {
  final Purchase purchase;

  const PurchaseDetailLoaded(this.purchase);

  @override
  List<Object> get props => [purchase];
}

/// Proveedores cargados
class SuppliersLoaded extends PurchaseState {
  final List<Supplier> suppliers;

  const SuppliersLoaded(this.suppliers);

  @override
  List<Object> get props => [suppliers];
}

/// Proveedor creado exitosamente
class SupplierCreated extends PurchaseState {
  final Supplier supplier;

  const SupplierCreated(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// Proveedor actualizado exitosamente
class SupplierUpdated extends PurchaseState {
  final Supplier supplier;

  const SupplierUpdated(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// Proveedor desactivado exitosamente
class SupplierDeactivated extends PurchaseState {
  final String id;

  const SupplierDeactivated(this.id);

  @override
  List<Object> get props => [id];
}

/// Sincronización completada
class PurchasesSynced extends PurchaseState {}

/// Error
class PurchaseError extends PurchaseState {
  final String message;

  const PurchaseError(this.message);

  @override
  List<Object> get props => [message];
}
