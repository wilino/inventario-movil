import '../repositories/product_repository.dart';

/// Caso de uso: Eliminar producto
class DeleteProductUseCase {
  final ProductRepository repository;

  DeleteProductUseCase(this.repository);

  Future<void> call(int productId) async {
    if (productId <= 0) {
      throw Exception('ID de producto inválido');
    }

    await repository.deleteProduct(productId);
  }
}
