import 'package:equatable/equatable.dart';
import '../../domain/entities/sale.dart';

/// Estados del BLoC de Ventas
abstract class SaleState extends Equatable {
  const SaleState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class SaleInitial extends SaleState {}

/// Estado de carga
class SaleLoading extends SaleState {}

/// Estado cuando las ventas se han cargado exitosamente
class SalesLoaded extends SaleState {
  final List<Sale> sales;
  final Map<String, dynamic>? stats;

  const SalesLoaded({
    required this.sales,
    this.stats,
  });

  @override
  List<Object?> get props => [sales, stats];

  SalesLoaded copyWith({
    List<Sale>? sales,
    Map<String, dynamic>? stats,
  }) {
    return SalesLoaded(
      sales: sales ?? this.sales,
      stats: stats ?? this.stats,
    );
  }
}

/// Estado cuando se ha creado una venta exitosamente
class SaleCreated extends SaleState {
  final Sale sale;

  const SaleCreated(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Estado cuando se ha cancelado una venta exitosamente
class SaleCancelled extends SaleState {
  final String saleId;

  const SaleCancelled(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

/// Estado cuando se carga el detalle de una venta
class SaleDetailLoaded extends SaleState {
  final Sale sale;

  const SaleDetailLoaded(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Estado de error
class SaleError extends SaleState {
  final String message;

  const SaleError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado cuando las estadísticas se han cargado
class SalesStatsLoaded extends SaleState {
  final Map<String, dynamic> stats;

  const SalesStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}
