import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';
import '../datasources/sale_local_datasource.dart';
import '../datasources/sale_remote_datasource.dart';

/// Implementación del repositorio de ventas con estrategia offline-first
class SaleRepositoryImpl implements SaleRepository {
  final SaleLocalDataSource localDataSource;
  final SaleRemoteDataSource remoteDataSource;

  SaleRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<Sale>>> getStoreSales(String storeId) async {
    try {
      // Obtener de local primero (offline-first)
      final localSales = await localDataSource.getStoreSales(storeId);

      // Intentar sincronizar en segundo plano
      _syncInBackground(() async {
        final remoteSales = await remoteDataSource.getStoreSales(storeId);
        // Aquí podrías implementar lógica de merge si es necesario
      });

      return Success(localSales);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Sale>>> getSalesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final sales = await localDataSource.getSalesByDateRange(
        storeId,
        startDate,
        endDate,
      );
      return Success(sales);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Sale>> getSaleById(String id) async {
    try {
      final sale = await localDataSource.getSaleById(id);
      if (sale == null) {
        return const Error(CacheFailure(message: 'Venta no encontrada'));
      }
      return Success(sale);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Sale>>> searchSalesByCustomer(
    String storeId,
    String query,
  ) async {
    try {
      final sales = await localDataSource.searchSalesByCustomer(storeId, query);
      return Success(sales);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Sale>> createSale(Sale sale) async {
    try {
      // Guardar en local primero (offline-first)
      final createdSale = await localDataSource.createSale(sale);

      // Sincronizar con Supabase en segundo plano
      _syncInBackground(() async {
        await remoteDataSource.createSale(sale);
      });

      return Success(createdSale);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> cancelSale(String id) async {
    try {
      // Cancelar en local primero
      await localDataSource.cancelSale(id);

      // Sincronizar con Supabase en segundo plano
      _syncInBackground(() async {
        await remoteDataSource.cancelSale(id);
      });

      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Sale>>> getTodaySales(String storeId) async {
    try {
      final sales = await localDataSource.getTodaySales(storeId);
      return Success(sales);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getTopSellingProducts(
    String storeId,
    int limit,
  ) async {
    try {
      final products = await localDataSource.getTopSellingProducts(
        storeId,
        limit,
      );
      return Success(products);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getSalesStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await localDataSource.getSalesStats(
        storeId,
        startDate,
        endDate,
      );
      return Success(stats);
    } catch (e) {
      return Error(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> syncWithRemote(String storeId) async {
    try {
      // Obtener ventas remotas
      final remoteSales = await remoteDataSource.getStoreSales(storeId);

      // Aquí podrías implementar lógica de merge más sofisticada
      // Por ahora, solo las guardamos en local si no existen
      for (final remoteSale in remoteSales) {
        final localSale = await localDataSource.getSaleById(remoteSale.id);
        if (localSale == null) {
          await localDataSource.createSale(remoteSale);
        }
      }

      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: e.toString()));
    }
  }

  /// Ejecuta una operación de sincronización en segundo plano
  /// sin bloquear la operación principal
  void _syncInBackground(Future<void> Function() operation) {
    operation().catchError((error) {
      // Log del error pero no lanzamos excepción
      print('Error en sincronización en segundo plano: $error');
    });
  }
}
