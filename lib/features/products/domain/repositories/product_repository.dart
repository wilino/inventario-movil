import '../entities/product.dart';

/// Interfaz del repositorio de productos
abstract class ProductRepository {
  /// Obtener todos los productos
  Future<List<Product>> getAllProducts();

  /// Obtener productos activos
  Future<List<Product>> getActiveProducts();

  /// Obtener producto por ID
  Future<Product?> getProductById(int id);

  /// Obtener producto por SKU
  Future<Product?> getProductBySku(String sku);

  /// Buscar productos por nombre o SKU
  Future<List<Product>> searchProducts(String query);

  /// Filtrar productos por categoría
  Future<List<Product>> getProductsByCategory(String category);

  /// Crear producto
  Future<Product> createProduct(Product product);

  /// Actualizar producto
  Future<Product> updateProduct(Product product);

  /// Eliminar producto (soft delete)
  Future<void> deleteProduct(int id);

  /// Obtener categorías únicas
  Future<List<String>> getCategories();
}
