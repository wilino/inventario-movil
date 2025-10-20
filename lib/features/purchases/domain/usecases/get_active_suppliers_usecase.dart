import '../../../../core/utils/result.dart';
import '../entities/supplier.dart';
import '../repositories/purchase_repository.dart';

/// Caso de uso para obtener proveedores activos
class GetActiveSuppliersUseCase {
  final PurchaseRepository repository;

  GetActiveSuppliersUseCase(this.repository);

  Future<Result<List<Supplier>>> call() async {
    return await repository.getActiveSuppliers();
  }
}
