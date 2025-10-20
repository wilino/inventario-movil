import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/database.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

// Sales
import '../../features/sales/data/datasources/sale_local_datasource.dart';
import '../../features/sales/data/datasources/sale_remote_datasource.dart';
import '../../features/sales/data/repositories/sale_repository_impl.dart';
import '../../features/sales/domain/repositories/sale_repository.dart';
import '../../features/sales/domain/usecases/create_sale_usecase.dart';
import '../../features/sales/domain/usecases/get_sales_stats_usecase.dart';
import '../../features/sales/domain/usecases/get_store_sales_usecase.dart';
import '../../features/sales/domain/usecases/get_today_sales_usecase.dart';

final GetIt getIt = GetIt.instance;

/// Configura las dependencias de la aplicación
Future<void> setupDependencies() async {
  // Database
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // Supabase Client
  final supabase = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabase);

  // Services
  final connectivityService = ConnectivityService();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  final syncService = SyncService(
    db: database,
    connectivityService: connectivityService,
  );
  getIt.registerSingleton<SyncService>(syncService);

  // Sales Module
  _setupSalesModule();
}

/// Configura el módulo de Ventas
void _setupSalesModule() {
  // Data Sources
  getIt.registerLazySingleton<SaleLocalDataSource>(
    () => SaleLocalDataSource(getIt<AppDatabase>()),
  );
  
  getIt.registerLazySingleton<SaleRemoteDataSource>(
    () => SaleRemoteDataSource(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<SaleRepository>(
    () => SaleRepositoryImpl(
      localDataSource: getIt<SaleLocalDataSource>(),
      remoteDataSource: getIt<SaleRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => CreateSaleUseCase(getIt<SaleRepository>()));
  getIt.registerLazySingleton(() => GetStoreSalesUseCase(getIt<SaleRepository>()));
  getIt.registerLazySingleton(() => GetTodaySalesUseCase(getIt<SaleRepository>()));
  getIt.registerLazySingleton(() => GetSalesStatsUseCase(getIt<SaleRepository>()));
  
  // BLoC se registrará cuando se implemente la capa de presentación
}

