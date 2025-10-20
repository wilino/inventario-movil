import '../../../../core/utils/result.dart';
import '../entities/report.dart';
import '../repositories/report_repository.dart';

/// UseCase para obtener el dashboard general
class GetDashboardUseCase {
  final ReportRepository repository;

  GetDashboardUseCase(this.repository);

  Future<Result<DashboardData>> call({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getDashboard(
      storeId: storeId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
