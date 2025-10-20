import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart' as result;
import '../../domain/usecases/get_dashboard_usecase.dart';
import '../../domain/usecases/get_inventory_report_usecase.dart';
import '../../domain/usecases/get_purchases_report_usecase.dart';
import '../../domain/usecases/get_sales_report_usecase.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

/// BLoC para gestión de reportes
///
/// Coordina la generación de diferentes tipos de reportes:
/// - Dashboard con métricas generales
/// - Reportes específicos (ventas, compras, inventario, traslados)
/// - Exportación a PDF/Excel
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final GetDashboardUseCase _getDashboardUseCase;
  final GetSalesReportUseCase _getSalesReportUseCase;
  final GetPurchasesReportUseCase _getPurchasesReportUseCase;
  final GetInventoryReportUseCase _getInventoryReportUseCase;
  final ReportRepository _reportRepository;

  ReportBloc({
    required GetDashboardUseCase getDashboardUseCase,
    required GetSalesReportUseCase getSalesReportUseCase,
    required GetPurchasesReportUseCase getPurchasesReportUseCase,
    required GetInventoryReportUseCase getInventoryReportUseCase,
    required ReportRepository reportRepository,
  }) : _getDashboardUseCase = getDashboardUseCase,
       _getSalesReportUseCase = getSalesReportUseCase,
       _getPurchasesReportUseCase = getPurchasesReportUseCase,
       _getInventoryReportUseCase = getInventoryReportUseCase,
       _reportRepository = reportRepository,
       super(ReportInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<LoadSalesReport>(_onLoadSalesReport);
    on<LoadPurchasesReport>(_onLoadPurchasesReport);
    on<LoadInventoryReport>(_onLoadInventoryReport);
    on<LoadTransfersReport>(_onLoadTransfersReport);
    on<ExportToPdf>(_onExportToPdf);
    on<ExportToExcel>(_onExportToExcel);
  }

  /// Cargar dashboard con métricas generales
  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    final res = await _getDashboardUseCase(
      storeId: event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (res) {
      case result.Success(:final value):
        emit(DashboardLoaded(value));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }

  /// Cargar reporte de ventas
  Future<void> _onLoadSalesReport(
    LoadSalesReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    final res = await _getSalesReportUseCase(
      storeId: event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (res) {
      case result.Success(:final value):
        emit(SalesReportLoaded(value));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }

  /// Cargar reporte de compras
  Future<void> _onLoadPurchasesReport(
    LoadPurchasesReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    final res = await _getPurchasesReportUseCase(
      storeId: event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (res) {
      case result.Success(:final value):
        emit(PurchasesReportLoaded(value));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }

  /// Cargar reporte de inventario
  Future<void> _onLoadInventoryReport(
    LoadInventoryReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    final res = await _getInventoryReportUseCase(storeId: event.storeId);

    switch (res) {
      case result.Success(:final value):
        emit(InventoryReportLoaded(value));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }

  /// Cargar reporte de traslados
  Future<void> _onLoadTransfersReport(
    LoadTransfersReport event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());

    final res = await _reportRepository.getTransfersReport(
      storeId: event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    switch (res) {
      case result.Success(:final value):
        emit(TransfersReportLoaded(value));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }

  /// Exportar reporte a PDF
  Future<void> _onExportToPdf(
    ExportToPdf event,
    Emitter<ReportState> emit,
  ) async {
    final res = await _reportRepository.exportToPdf(
      reportType: event.reportType,
      data: event.data,
    );

    switch (res) {
      case result.Success(:final value):
        emit(ReportExported(filePath: value, format: 'pdf'));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }

  /// Exportar reporte a Excel
  Future<void> _onExportToExcel(
    ExportToExcel event,
    Emitter<ReportState> emit,
  ) async {
    final res = await _reportRepository.exportToExcel(
      reportType: event.reportType,
      data: event.data,
    );

    switch (res) {
      case result.Success(:final value):
        emit(ReportExported(filePath: value, format: 'excel'));
      case result.Error(:final failure):
        emit(ReportError(failure));
    }
  }
}
