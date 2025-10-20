import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/dependency_injection.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../../features/reports/presentation/pages/dashboard_page.dart';
import '../../features/sales/presentation/pages/sales_history_page.dart';
import '../../features/sales/presentation/pages/new_sale_page.dart';
import '../../features/sales/presentation/bloc/sale_bloc.dart';
import '../../features/purchases/presentation/pages/purchases_history_page.dart';
import '../../features/purchases/presentation/pages/new_purchase_page.dart';
import '../../features/purchases/presentation/bloc/purchase_bloc.dart';
import '../../features/inventory/presentation/pages/inventory_dashboard_page.dart';
import '../../features/inventory/presentation/bloc/inventory_bloc.dart';
import '../../features/transfers/presentation/pages/transfers_history_page.dart';

/// Navegación principal de la aplicación con BottomNavigationBar
class MainNavigation extends StatefulWidget {
  final String storeId;

  const MainNavigation({super.key, required this.storeId});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();
  final SyncService _syncService = getIt<SyncService>();
  bool _isOnline = false;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Inicializar páginas con storeId
    _pages = [
      DashboardPage(storeId: widget.storeId),
      SalesHistoryPage(storeId: widget.storeId),
      PurchasesHistoryPage(storeId: widget.storeId),
      BlocProvider(
        create: (_) => getIt<InventoryBloc>(),
        child: InventoryDashboardPage(storeId: widget.storeId),
      ),
      TransfersHistoryPage(storeId: widget.storeId),
    ];

    // Escuchar cambios de conectividad
    _connectivityService.connectionStatus.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });

        // Sincronizar automáticamente cuando se conecta
        if (isOnline) {
          _syncService.syncPendingOps();
        }
      }
    });

    // Verificar estado inicial
    _connectivityService.checkConnection().then((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Ventas',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Compras',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Inventario',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_outlined),
            selectedIcon: Icon(Icons.swap_horiz),
            label: 'Traslados',
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    // Mostrar FAB según la sección actual
    IconData icon;
    String tooltip;
    VoidCallback onPressed;

    switch (_currentIndex) {
      case 0: // Dashboard
        if (!_isOnline)
          return null; // No mostrar FAB si no hay conexión para sync
        icon = Icons.sync;
        tooltip = 'Sincronizar';
        onPressed = () async {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('🔄 Sincronizando...')));
          await _syncService.forceSyncNow();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Sincronización completada'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        };
        break;

      case 1: // Ventas
        icon = Icons.add_shopping_cart;
        tooltip = 'Nueva Venta';
        onPressed = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => getIt<SaleBloc>(),
                child: NewSalePage(storeId: widget.storeId),
              ),
            ),
          ).then((result) {
            if (result == true) {
              // Refrescar la lista de ventas
              setState(() {});
            }
          });
        };
        break;

      case 2: // Compras
        icon = Icons.add_shopping_cart;
        tooltip = 'Nueva Compra';
        onPressed = () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => getIt<PurchaseBloc>(),
                child: NewPurchasePage(storeId: widget.storeId),
              ),
            ),
          ).then((result) {
            if (result == true) {
              // Refrescar la lista de compras
              setState(() {});
            }
          });
        };
        break;

      case 3: // Inventario
        icon = Icons.add;
        tooltip = 'Ajustar Inventario';
        onPressed = () {
          // TODO: Implementar página de ajuste de inventario
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ajuste de inventario - próximamente')),
          );
        };
        break;

      case 4: // Traslados
        icon = Icons.add;
        tooltip = 'Nuevo Traslado';
        onPressed = () {
          // TODO: Navegar a NewTransferPage
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nuevo traslado - próximamente')),
          );
        };
        break;

      default:
        return null;
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
