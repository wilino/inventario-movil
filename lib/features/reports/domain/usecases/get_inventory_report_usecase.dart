import '../../../../core/utils/result.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// UseCase para generar reporte de inventario
class GetInventoryReportUseCase {
  final ReportRepository repository;

  GetInventoryReportUseCase(this.repository);

  Future<Result<InventoryReport>> call({required String storeId}) async {
    return await repository.getInventoryReport(storeId: storeId);
  }
}
