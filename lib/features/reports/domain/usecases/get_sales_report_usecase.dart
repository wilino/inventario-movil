import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// UseCase para generar reporte de ventas
class GetSalesReportUseCase {
  final ReportRepository repository;

  GetSalesReportUseCase(this.repository);

  Future<Result<SalesReport>> call({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Validar fechas
    if (startDate.isAfter(endDate)) {
      return const Error(
        ValidationFailure(
          message: 'La fecha de inicio debe ser anterior a la fecha de fin',
        ),
      );
    }

    return await repository.getSalesReport(
      storeId: storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
