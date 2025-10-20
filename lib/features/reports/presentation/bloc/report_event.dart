import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Reportes
abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar el dashboard
class LoadDashboard extends ReportEvent {
  final String storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadDashboard({
    required this.storeId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Evento para cargar reporte de ventas
class LoadSalesReport extends ReportEvent {
  final String storeId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadSalesReport({
    required this.storeId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Evento para cargar reporte de compras
class LoadPurchasesReport extends ReportEvent {
  final String storeId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadPurchasesReport({
    required this.storeId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Evento para cargar reporte de inventario
class LoadInventoryReport extends ReportEvent {
  final String storeId;

  const LoadInventoryReport({required this.storeId});

  @override
  List<Object?> get props => [storeId];
}

/// Evento para cargar reporte de traslados
class LoadTransfersReport extends ReportEvent {
  final String storeId;
  final DateTime startDate;
  final DateTime endDate;

  const LoadTransfersReport({
    required this.storeId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Evento para exportar reporte a PDF
class ExportToPdf extends ReportEvent {
  final String reportType;
  final Map<String, dynamic> data;

  const ExportToPdf({
    required this.reportType,
    required this.data,
  });

  @override
  List<Object?> get props => [reportType, data];
}

/// Evento para exportar reporte a Excel
class ExportToExcel extends ReportEvent {
  final String reportType;
  final Map<String, dynamic> data;

  const ExportToExcel({
    required this.reportType,
    required this.data,
  });

  @override
  List<Object?> get props => [reportType, data];
}
