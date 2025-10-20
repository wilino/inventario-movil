import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

/// Implementación del repositorio de productos
/// Usa local-first con sincronización remota
class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Product>> getAllProducts() async {
    // Intentar obtener de la base de datos local primero
    try {
      return await localDataSource.getAllProducts();
    } catch (e) {
      // Si falla, intentar remoto
      try {
        final remoteProducts = await remoteDataSource.getAllProducts();
        // Sincronizar local con remoto
        for (final product in remoteProducts) {
          try {
            await localDataSource.createProduct(product);
          } catch (_) {
            // Ignorar errores de duplicados
          }
        }
        return remoteProducts;
      } catch (_) {
        rethrow;
      }
    }
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    return await localDataSource.getActiveProducts();
  }

  @override
  Future<Product?> getProductById(int id) async {
    return await localDataSource.getProductById(id);
  }

  @override
  Future<Product?> getProductBySku(String sku) async {
    return await localDataSource.getProductBySku(sku);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return await localDataSource.searchProducts(query);
  }

  @override
  Future<List<Product>> getProductsByCategory(String category) async {
    return await localDataSource.getProductsByCategory(category);
  }

  @override
  Future<Product> createProduct(Product product) async {
    // Crear en local primero
    final localProduct = await localDataSource.createProduct(product);

    // Intentar sincronizar con remoto
    try {
      final remoteProduct = await remoteDataSource.createProduct(localProduct);
      // Actualizar ID remoto si es diferente
      if (remoteProduct.id != localProduct.id) {
        return await localDataSource.updateProduct(remoteProduct);
      }
      return remoteProduct;
    } catch (e) {
      // Si falla la sincronización, agregar a pending_ops
      // El SyncService se encargará de sincronizar después
      return localProduct;
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final updatedProduct = await localDataSource.updateProduct(product);

    // Intentar sincronizar con remoto
    try {
      await remoteDataSource.updateProduct(updatedProduct);
    } catch (e) {
      // Si falla, el SyncService sincronizará después
    }

    return updatedProduct;
  }

  @override
  Future<void> deleteProduct(int id) async {
    await localDataSource.deleteProduct(id);

    // Intentar sincronizar con remoto
    try {
      await remoteDataSource.deleteProduct(id);
    } catch (e) {
      // Si falla, el SyncService sincronizará después
    }
  }

  @override
  Future<List<String>> getCategories() async {
    return await localDataSource.getCategories();
  }
}
