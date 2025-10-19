import 'package:get_it/get_it.dart';
import '../config/database.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

final GetIt getIt = GetIt.instance;

/// Configura las dependencias de la aplicación
Future<void> setupDependencies() async {
  // Database
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // Services
  final connectivityService = ConnectivityService();
  getIt.registerSingleton<ConnectivityService>(connectivityService);

  final syncService = SyncService(
    db: database,
    connectivityService: connectivityService,
  );
  getIt.registerSingleton<SyncService>(syncService);

  // TODO: Registrar repositorios y BLoCs aquí
}
