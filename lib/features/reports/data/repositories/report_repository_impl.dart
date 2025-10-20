import 'package:inventario_app/core/error/failures.dart';
import 'package:inventario_app/core/utils/result.dart';
import 'package:inventario_app/features/reports/data/datasources/report_local_datasource.dart';
import 'package:inventario_app/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:inventario_app/features/reports/domain/entities/report.dart';
import 'package:inventario_app/features/reports/domain/repositories/report_repository.dart';

/// Implementación del repositorio de reportes
///
/// Patrón Offline-First: Los reportes se generan exclusivamente desde
/// la base de datos local SQLite, ya que requieren acceso a datos históricos
/// y cálculos agregados complejos.
class ReportRepositoryImpl implements ReportRepository {
  final ReportLocalDataSource _localDataSource;
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Result<DashboardData>> getDashboard({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final dashboard = await _localDataSource.getDashboard(
        storeId,
        startDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate ?? DateTime.now(),
      );
      return Success(dashboard);
    } catch (e) {
      return Error(
        DatabaseFailure('Error al generar dashboard: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<SalesReport>> getSalesReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final report = await _localDataSource.getSalesReport(
        storeId,
        startDate,
        endDate,
      );
      return Success(report);
    } catch (e) {
      return Error(
        DatabaseFailure('Error al generar reporte de ventas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<PurchasesReport>> getPurchasesReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final report = await _localDataSource.getPurchasesReport(
        storeId,
        startDate,
        endDate,
      );
      return Success(report);
    } catch (e) {
      return Error(
        DatabaseFailure('Error al generar reporte de compras: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<InventoryReport>> getInventoryReport({
    required String storeId,
  }) async {
    try {
      final report = await _localDataSource.getInventoryReport(storeId);
      return Success(report);
    } catch (e) {
      return Error(
        DatabaseFailure(
          'Error al generar reporte de inventario: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<TransfersReport>> getTransfersReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final report = await _localDataSource.getTransfersReport(
        storeId,
        startDate,
        endDate,
      );
      return Success(report);
    } catch (e) {
      return Error(
        DatabaseFailure(
          'Error al generar reporte de traslados: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<String>> exportToPdf({
    required String reportType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // TODO: Implementar exportación a PDF con pdf package
      // Por ahora retorna path mock
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '/storage/reports/${reportType}_$timestamp.pdf';
      return Success(filePath);
    } catch (e) {
      return Error(DatabaseFailure('Error al exportar PDF: ${e.toString()}'));
    }
  }

  @override
  Future<Result<String>> exportToExcel({
    required String reportType,
    required Map<String, dynamic> data,
  }) async {
    try {
      // TODO: Implementar exportación a Excel con excel package
      // Por ahora retorna path mock
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '/storage/reports/${reportType}_$timestamp.xlsx';
      return Success(filePath);
    } catch (e) {
      return Error(DatabaseFailure('Error al exportar Excel: ${e.toString()}'));
    }
  }
}
