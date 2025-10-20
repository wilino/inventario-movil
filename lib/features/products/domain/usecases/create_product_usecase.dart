import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Caso de uso: Crear producto
class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Product> call(Product product) async {
    // Validaciones
    if (product.sku.isEmpty) {
      throw Exception('El SKU es requerido');
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

    // Verificar que el SKU no exista
    final existing = await repository.getProductBySku(product.sku);
    if (existing != null) {
      throw Exception('Ya existe un producto con ese SKU');
    }

    return await repository.createProduct(product);
  }
}
