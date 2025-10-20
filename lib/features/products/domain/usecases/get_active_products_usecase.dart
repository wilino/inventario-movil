import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Caso de uso: Obtener todos los productos activos
class GetActiveProductsUseCase {
  final ProductRepository repository;

  GetActiveProductsUseCase(this.repository);

  Future<List<Product>> call() async {
    return await repository.getActiveProducts();
  }
}
