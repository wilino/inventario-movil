import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../domain/entities/purchase.dart';
import '../bloc/purchase_bloc.dart';
import '../bloc/purchase_event.dart';
import '../bloc/purchase_state.dart';
import 'new_purchase_page.dart';

/// Página de historial de compras
class PurchasesHistoryPage extends StatefulWidget {
  final String storeId;

  const PurchasesHistoryPage({super.key, required this.storeId});

  @override
  State<PurchasesHistoryPage> createState() => _PurchasesHistoryPageState();
}

class _PurchasesHistoryPageState extends State<PurchasesHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PurchaseBloc>()..add(LoadPurchasesStats(widget.storeId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Compras'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                context.read<PurchaseBloc>().add(SyncPurchases(widget.storeId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronizando...')),
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStatsCards(),
            Expanded(child: _buildPurchasesList()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToNewPurchase(context),
          icon: const Icon(Icons.add),
          label: const Text('Nueva Compra'),
        ),
      ),
    );
  }

  /// Barra de búsqueda
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por factura...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<PurchaseBloc>().add(
                      LoadStorePurchases(widget.storeId),
                    );
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (query) {
          if (query.length >= 3) {
            context.read<PurchaseBloc>().add(
              SearchPurchasesByInvoice(widget.storeId, query),
            );
          } else if (query.isEmpty) {
            context.read<PurchaseBloc>().add(
              LoadStorePurchases(widget.storeId),
            );
          }
        },
      ),
    );
  }

  /// Tarjetas de estadísticas
  Widget _buildStatsCards() {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, state) {
        if (state is PurchasesLoaded && state.stats != null) {
          return Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Compras',
                    state.stats!['totalPurchases'].toString(),
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Costo Total',
                    '\$${NumberFormat('#,##0.00').format(state.stats!['totalCost'])}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Promedio',
                    '\$${NumberFormat('#,##0.00').format(state.stats!['averageCost'])}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Tarjeta individual de estadística
  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Lista de compras
  Widget _buildPurchasesList() {
    return BlocConsumer<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is PurchaseCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Compra cancelada exitosamente')),
          );
          context.read<PurchaseBloc>().add(LoadPurchasesStats(widget.storeId));
        }
      },
      builder: (context, state) {
        if (state is PurchaseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PurchasesLoaded) {
          if (state.purchases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay compras registradas',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: state.purchases.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final purchase = state.purchases[index];
              return _buildPurchaseCard(context, purchase);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Tarjeta de compra individual
  Widget _buildPurchaseCard(BuildContext context, Purchase purchase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showPurchaseDetail(context, purchase),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          purchase.supplierName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (purchase.invoiceNumber != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Factura: ${purchase.invoiceNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(purchase.total)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.inventory_2, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${purchase.itemCount} items',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(purchase.at),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  purchase.notes!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar detalle de compra en modal
  void _showPurchaseDetail(BuildContext context, Purchase purchase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detalle de Compra',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          _confirmCancelPurchase(context, purchase.id);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Proveedor', purchase.supplierName),
                  if (purchase.invoiceNumber != null)
                    _buildDetailRow('Factura', purchase.invoiceNumber!),
                  _buildDetailRow(
                    'Fecha',
                    DateFormat('dd/MM/yyyy HH:mm').format(purchase.at),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...purchase.items.map((item) => _buildItemRow(item)),
                  const Divider(height: 32),
                  _buildDetailRow(
                    'Subtotal',
                    '\$${NumberFormat('#,##0.00').format(purchase.subtotal)}',
                  ),
                  if (purchase.discount > 0)
                    _buildDetailRow(
                      'Descuento',
                      '\$${NumberFormat('#,##0.00').format(purchase.discount)}',
                      color: Colors.red,
                    ),
                  if (purchase.tax > 0)
                    _buildDetailRow(
                      'IVA (${purchase.tax}%)',
                      '\$${NumberFormat('#,##0.00').format(purchase.subtotal * purchase.tax / 100)}',
                    ),
                  const Divider(),
                  _buildDetailRow(
                    'Total',
                    '\$${NumberFormat('#,##0.00').format(purchase.total)}',
                    isBold: true,
                    fontSize: 20,
                  ),
                  if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(purchase.notes!),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.grey[600],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${item.qty} x \$${NumberFormat('#,##0.00').format(item.unitCost)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(item.total)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Confirmar cancelación de compra
  void _confirmCancelPurchase(BuildContext parentContext, String purchaseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Compra'),
        content: const Text(
          '¿Está seguro de que desea cancelar esta compra? '
          'El inventario será decrementado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(parentContext); // Cerrar modal
              parentContext.read<PurchaseBloc>().add(
                CancelPurchase(purchaseId),
              );
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de filtros
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Compras'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Compras de Hoy'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<PurchaseBloc>().add(
                  LoadTodayPurchases(widget.storeId),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Rango de Fechas'),
              onTap: () async {
                Navigator.pop(dialogContext);
                await _selectDateRange(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Todas las Compras'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<PurchaseBloc>().add(
                  LoadPurchasesStats(widget.storeId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Seleccionar rango de fechas
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      if (mounted) {
        context.read<PurchaseBloc>().add(
          FilterPurchasesByDateRange(widget.storeId, picked.start, picked.end),
        );
      }
    }
  }

  /// Navegar a nueva compra
  Future<void> _navigateToNewPurchase(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewPurchasePage(storeId: widget.storeId),
      ),
    );

    if (result == true && mounted) {
      context.read<PurchaseBloc>().add(LoadPurchasesStats(widget.storeId));
    }
  }
}
