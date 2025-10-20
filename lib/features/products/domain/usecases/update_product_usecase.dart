import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Caso de uso: Actualizar producto
class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Product> call(Product product) async {
    if (product.id.isEmpty) {
      throw Exception('ID de producto es requerido para actualizar');
    }

    if (product.name.isEmpty) {
      throw Exception('El nombre es requerido');
    }

    if (product.costPrice < 0) {
      throw Exception('El precio de costo no puede ser negativo');
    }

    if (product.salePrice < 0) {
      throw Exception('El precio de venta no puede ser negativo');
    }

    return await repository.updateProduct(product);
  }
}
