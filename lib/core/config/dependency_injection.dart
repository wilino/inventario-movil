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
import '../../features/sales/presentation/bloc/sale_bloc.dart';

// Purchases
import '../../features/purchases/data/datasources/purchase_local_datasource.dart';
import '../../features/purchases/data/datasources/purchase_remote_datasource.dart';
import '../../features/purchases/data/repositories/purchase_repository_impl.dart';
import '../../features/purchases/domain/repositories/purchase_repository.dart';
import '../../features/purchases/domain/usecases/create_purchase_usecase.dart';
import '../../features/purchases/domain/usecases/get_active_suppliers_usecase.dart';
import '../../features/purchases/domain/usecases/get_purchases_stats_usecase.dart';
import '../../features/purchases/domain/usecases/get_store_purchases_usecase.dart';
import '../../features/purchases/domain/usecases/get_today_purchases_usecase.dart';
import '../../features/purchases/presentation/bloc/purchase_bloc.dart';

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
  
  // Purchases Module
  _setupPurchasesModule();
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
  getIt.registerLazySingleton(
    () => GetStoreSalesUseCase(getIt<SaleRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTodaySalesUseCase(getIt<SaleRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetSalesStatsUseCase(getIt<SaleRepository>()),
  );

  // BLoC - Factory para crear nueva instancia cada vez que se necesite
  getIt.registerFactory(
    () => SaleBloc(
      createSaleUseCase: getIt<CreateSaleUseCase>(),
      getStoreSalesUseCase: getIt<GetStoreSalesUseCase>(),
      getTodaySalesUseCase: getIt<GetTodaySalesUseCase>(),
      getSalesStatsUseCase: getIt<GetSalesStatsUseCase>(),
      repository: getIt<SaleRepository>(),
    ),
  );
}

/// Configura el módulo de Compras
void _setupPurchasesModule() {
  // Data Sources
  getIt.registerLazySingleton<PurchaseLocalDataSource>(
    () => PurchaseLocalDataSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<PurchaseRemoteDataSource>(
    () => PurchaseRemoteDataSource(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<PurchaseRepository>(
    () => PurchaseRepositoryImpl(
      local: getIt<PurchaseLocalDataSource>(),
      remote: getIt<PurchaseRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => CreatePurchaseUseCase(getIt<PurchaseRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetStorePurchasesUseCase(getIt<PurchaseRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTodayPurchasesUseCase(getIt<PurchaseRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPurchasesStatsUseCase(getIt<PurchaseRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetActiveSuppliersUseCase(getIt<PurchaseRepository>()),
  );

  // BLoC - Factory para crear nueva instancia cada vez que se necesite
  getIt.registerFactory(
    () => PurchaseBloc(
      createPurchaseUseCase: getIt<CreatePurchaseUseCase>(),
      getStorePurchasesUseCase: getIt<GetStorePurchasesUseCase>(),
      getTodayPurchasesUseCase: getIt<GetTodayPurchasesUseCase>(),
      getPurchasesStatsUseCase: getIt<GetPurchasesStatsUseCase>(),
      getActiveSuppliersUseCase: getIt<GetActiveSuppliersUseCase>(),
      repository: getIt<PurchaseRepository>(),
    ),
  );
}
