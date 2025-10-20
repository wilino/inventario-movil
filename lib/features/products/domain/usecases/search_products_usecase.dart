import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Caso de uso: Buscar productos
class SearchProductsUseCase {
  final ProductRepository repository;

  SearchProductsUseCase(this.repository);

  Future<List<Product>> call(String query) async {
    if (query.trim().isEmpty) {
      return await repository.getAllProducts();
    }
    return await repository.searchProducts(query.trim());
  }
}
