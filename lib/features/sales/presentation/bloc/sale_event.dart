import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';

/// Eventos del BLoC de Ventas
abstract class SaleEvent extends Equatable {
  const SaleEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar las ventas de una tienda
class LoadStoreSales extends SaleEvent {
  final String storeId;

  const LoadStoreSales(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Evento para cargar las ventas del día
class LoadTodaySales extends SaleEvent {
  final String storeId;

  const LoadTodaySales(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Evento para crear una nueva venta
class CreateSale extends SaleEvent {
  final Sale sale;

  const CreateSale(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Evento para cancelar una venta
class CancelSale extends SaleEvent {
  final String saleId;

  const CancelSale(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Evento para filtrar ventas por rango de fechas
class FilterSalesByDateRange extends SaleEvent {
  final String storeId;
  final DateTime startDate;
  final DateTime endDate;

  const FilterSalesByDateRange({
    required this.storeId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Evento para buscar ventas por cliente
class SearchSalesByCustomer extends SaleEvent {
  final String storeId;
  final String query;

  const SearchSalesByCustomer({required this.storeId, required this.query});

  @override
  List<Object?> get props => [storeId, query];
}

/// Evento para cargar estadísticas de ventas
class LoadSalesStats extends SaleEvent {
  final String storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadSalesStats({required this.storeId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Evento para obtener el detalle de una venta
class LoadSaleDetail extends SaleEvent {
  final String saleId;

  const LoadSaleDetail(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Evento para limpiar los filtros
class ClearFilters extends SaleEvent {
  final String storeId;

  const ClearFilters(this.storeId);

  @override
  List<Object?> get props => [storeId];
}
