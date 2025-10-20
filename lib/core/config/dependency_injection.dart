import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/database.dart';
import '../config/data_seeder.dart';
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

// Transfers
import '../../features/transfers/data/datasources/transfer_local_datasource.dart';
import '../../features/transfers/data/datasources/transfer_remote_datasource.dart';
import '../../features/transfers/data/repositories/transfer_repository_impl.dart';
import '../../features/transfers/domain/repositories/transfer_repository.dart';
import '../../features/transfers/domain/usecases/create_transfer_usecase.dart';
import '../../features/transfers/domain/usecases/get_pending_transfers_usecase.dart';
import '../../features/transfers/domain/usecases/get_store_transfers_usecase.dart';
import '../../features/transfers/domain/usecases/get_transfers_stats_usecase.dart';
import '../../features/transfers/presentation/bloc/transfer_bloc.dart';

// Inventory
import '../../features/inventory/data/datasources/inventory_local_datasource.dart';
import '../../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/repositories/inventory_repository.dart';
import '../../features/inventory/domain/usecases/adjust_inventory.dart';
import '../../features/inventory/domain/usecases/get_adjustment_history.dart';
import '../../features/inventory/domain/usecases/get_inventory_stats.dart';
import '../../features/inventory/domain/usecases/get_low_stock_items.dart';
import '../../features/inventory/domain/usecases/get_store_inventory.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';

// Reports
import '../../features/reports/data/datasources/report_local_datasource.dart';
import '../../features/reports/data/datasources/report_remote_datasource.dart';
import '../../features/reports/data/repositories/report_repository_impl.dart';
import '../../features/reports/domain/repositories/report_repository.dart';
import '../../features/reports/domain/usecases/get_dashboard_usecase.dart';
import '../../features/reports/domain/usecases/get_sales_report_usecase.dart';
import '../../features/reports/domain/usecases/get_purchases_report_usecase.dart';
import '../../features/reports/domain/usecases/get_inventory_report_usecase.dart';
import '../../features/reports/presentation/bloc/report_bloc.dart';

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

  // Transfers Module
  _setupTransfersModule();

  // Inventory Module
  _setupInventoryModule();

  // Inicializar datos de ejemplo si la DB está vacía
  final seeder = DataSeeder(database);

  // TEMPORAL: Limpiar datos viejos y forzar sincronización desde Supabase
  final hasOldData = await seeder.hasData();
  if (hasOldData) {
    print('🔄 Limpiando datos locales para sincronizar desde Supabase...');
    await seeder.clearAllData();
  }

  // Forzar sincronización inicial desde Supabase
  print('🔄 Iniciando sincronización desde Supabase...');
  await syncService.syncPendingOps();
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

/// Configura el módulo de Transferencias
void _setupTransfersModule() {
  // Data Sources
  getIt.registerLazySingleton<TransferLocalDataSource>(
    () => TransferLocalDataSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<TransferRemoteDataSource>(
    () => TransferRemoteDataSource(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<TransferRepository>(
    () => TransferRepositoryImpl(
      localDataSource: getIt<TransferLocalDataSource>(),
      remoteDataSource: getIt<TransferRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => CreateTransferUseCase(getIt<TransferRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetStoreTransfersUseCase(getIt<TransferRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetPendingTransfersUseCase(getIt<TransferRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetTransfersStatsUseCase(getIt<TransferRepository>()),
  );

  // BLoC - Factory para crear nueva instancia cada vez que se necesite
  getIt.registerFactory(
    () => TransferBloc(
      repository: getIt<TransferRepository>(),
      createTransferUseCase: getIt<CreateTransferUseCase>(),
      getStoreTransfersUseCase: getIt<GetStoreTransfersUseCase>(),
      getPendingTransfersUseCase: getIt<GetPendingTransfersUseCase>(),
      getTransfersStatsUseCase: getIt<GetTransfersStatsUseCase>(),
    ),
  );

  // === REPORTS MODULE ===

  // Data sources
  getIt.registerLazySingleton<ReportLocalDataSource>(
    () => ReportLocalDataSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSource(getIt<SupabaseClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ReportRepository>(
    () =>
        ReportRepositoryImpl(
              getIt<ReportLocalDataSource>(),
              getIt<ReportRemoteDataSource>(),
            )
            as ReportRepository,
  );

  // Use cases
  getIt.registerLazySingleton(
    () => GetDashboardUseCase(getIt<ReportRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetSalesReportUseCase(getIt<ReportRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetPurchasesReportUseCase(getIt<ReportRepository>()),
  );

  getIt.registerLazySingleton(
    () => GetInventoryReportUseCase(getIt<ReportRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => ReportBloc(
      getDashboardUseCase: getIt<GetDashboardUseCase>(),
      getSalesReportUseCase: getIt<GetSalesReportUseCase>(),
      getPurchasesReportUseCase: getIt<GetPurchasesReportUseCase>(),
      getInventoryReportUseCase: getIt<GetInventoryReportUseCase>(),
      reportRepository: getIt<ReportRepository>(),
    ),
  );
}

/// Configura el módulo de Inventario
void _setupInventoryModule() {
  // Data Sources
  getIt.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSource(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSource(),
  );

  // Repository
  getIt.registerLazySingleton<InventoryRepository>(
    () => InventoryRepositoryImpl(
      localDataSource: getIt<InventoryLocalDataSource>(),
      remoteDataSource: getIt<InventoryRemoteDataSource>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
    () => GetStoreInventoryUseCase(getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetLowStockItemsUseCase(getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetInventoryStatsUseCase(getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => AdjustInventoryUseCase(getIt<InventoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => GetAdjustmentHistoryUseCase(getIt<InventoryRepository>()),
  );

  // BLoC - Factory para crear nueva instancia cada vez que se necesite
  getIt.registerFactory(
    () => InventoryBloc(
      getStoreInventoryUseCase: getIt<GetStoreInventoryUseCase>(),
      getLowStockItemsUseCase: getIt<GetLowStockItemsUseCase>(),
      getInventoryStatsUseCase: getIt<GetInventoryStatsUseCase>(),
      adjustInventoryUseCase: getIt<AdjustInventoryUseCase>(),
      getAdjustmentHistoryUseCase: getIt<GetAdjustmentHistoryUseCase>(),
    ),
  );
}
