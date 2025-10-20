import 'package:equatable/equatable.dart';
import 'package:inventario_app/core/error/failures.dart';
import 'package:inventario_app/features/reports/domain/entities/report.dart';

/// Estados del BLoC de Reportes
abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ReportInitial extends ReportState {}

/// Estado de carga
class ReportLoading extends ReportState {}

/// Estado cuando el dashboard está cargado
class DashboardLoaded extends ReportState {
  final DashboardData dashboard;

  const DashboardLoaded(this.dashboard);

  @override
  List<Object?> get props => [dashboard];
}

/// Estado cuando el reporte de ventas está cargado
class SalesReportLoaded extends ReportState {
  final SalesReport report;

  const SalesReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Estado cuando el reporte de compras está cargado
class PurchasesReportLoaded extends ReportState {
  final PurchasesReport report;

  const PurchasesReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Estado cuando el reporte de inventario está cargado
class InventoryReportLoaded extends ReportState {
  final InventoryReport report;

  const InventoryReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Estado cuando el reporte de traslados está cargado
class TransfersReportLoaded extends ReportState {
  final TransfersReport report;

  const TransfersReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Estado cuando se exportó exitosamente
class ReportExported extends ReportState {
  final String filePath;
  final String format; // 'pdf' o 'excel'

  const ReportExported({
    required this.filePath,
    required this.format,
  });

  @override
  List<Object?> get props => [filePath, format];
}

/// Estado de error
class ReportError extends ReportState {
  final Failure failure;

  const ReportError(this.failure);

  @override
  List<Object?> get props => [failure];
}
