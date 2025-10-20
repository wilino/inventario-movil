import '../../../../core/utils/result.dart';
import '../entities/report.dart';

/// Repositorio para reportes y dashboard
abstract class ReportRepository {
  /// Obtiene el dashboard general
  Future<Result<DashboardData>> getDashboard({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Genera reporte de ventas
  Future<Result<SalesReport>> getSalesReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Genera reporte de compras
  Future<Result<PurchasesReport>> getPurchasesReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Genera reporte de inventario
  Future<Result<InventoryReport>> getInventoryReport({required String storeId});

  /// Genera reporte de transferencias
  Future<Result<TransfersReport>> getTransfersReport({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Exporta reporte a PDF
  Future<Result<String>> exportToPdf({
    required String reportType,
    required Map<String, dynamic> data,
  });

  /// Exporta reporte a Excel
  Future<Result<String>> exportToExcel({
    required String reportType,
    required Map<String, dynamic> data,
  });
}
