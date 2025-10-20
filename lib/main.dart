import 'package:flutter/material.dart';
import 'core/config/supabase_config.dart';
import 'core/config/dependency_injection.dart';
import 'core/presentation/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  try {
    await SupabaseConfig.initialize();
    print('✅ Supabase inicializado correctamente');
  } catch (e) {
    print('⚠️ Error al inicializar Supabase: $e');
    print('⚠️ La app funcionará en modo solo-local');
  }

  // Configurar dependencias
  await setupDependencies();
  print('✅ Dependencias configuradas');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario Offline-First',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainNavigation(
        storeId:
            '11111111-1111-1111-1111-111111111111', // Tienda Central - La Paz (tiene ventas y transferencias)
      ),
    );
  }
}

/* HomePage original - Reemplazada por MainNavigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();
  final SyncService _syncService = getIt<SyncService>();
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();

    // Escuchar cambios de conectividad
    _connectivityService.connectionStatus.listen((isOnline) {
      setState(() {
        _isOnline = isOnline;
      });

      // Sincronizar automáticamente cuando se conecta
      if (isOnline) {
        _syncService.syncPendingOps();
      }
    });

    // Verificar estado inicial
    _connectivityService.checkConnection().then((isOnline) {
      setState(() {
        _isOnline = isOnline;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sistema de Inventario'),
        actions: [
          // Indicador de conectividad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: _isOnline ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: _isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'Sistema de Inventario Offline-First',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter + Supabase + BLoC',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      title: const Text('Base de datos local (Drift)'),
                      subtitle: const Text('Configurada y lista'),
                    ),
                    ListTile(
                      leading: Icon(
                        _isOnline ? Icons.check_circle : Icons.pending,
                        color: _isOnline ? Colors.green : Colors.orange,
                      ),
                      title: const Text('Supabase'),
                      subtitle: Text(_isOnline ? 'Conectado' : 'Sin conexión'),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.architecture,
                        color: Colors.blue,
                      ),
                      title: const Text('Arquitectura Clean + BLoC'),
                      subtitle: const Text('Implementada'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isOnline
                  ? () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🔄 Sincronizando...')),
                      );
                      await _syncService.forceSyncNow();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Sincronización completada'),
                          ),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar ahora'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar a funcionalidades principales
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Funcionalidades en desarrollo...')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
*/
