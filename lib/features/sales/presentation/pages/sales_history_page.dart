import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../domain/entities/sale.dart';
import '../bloc/sale_bloc.dart';
import '../bloc/sale_event.dart';
import '../bloc/sale_state.dart';
import 'new_sale_page.dart';

/// Página del historial de ventas
class SalesHistoryPage extends StatelessWidget {
  final String storeId;

  const SalesHistoryPage({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SaleBloc>()..add(LoadStoreSales(storeId)),
      child: SalesHistoryView(storeId: storeId),
    );
  }
}

class SalesHistoryView extends StatefulWidget {
  final String storeId;

  const SalesHistoryView({super.key, required this.storeId});

  @override
  State<SalesHistoryView> createState() => _SalesHistoryViewState();
}

class _SalesHistoryViewState extends State<SalesHistoryView> {
  final _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<SaleBloc>().add(LoadStoreSales(widget.storeId));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsCard(),
          Expanded(child: _buildSalesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewSale(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por cliente...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SaleBloc>().add(LoadStoreSales(widget.storeId));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            context.read<SaleBloc>().add(
                  SearchSalesByCustomer(
                    storeId: widget.storeId,
                    query: value,
                  ),
                );
          }
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    return BlocBuilder<SaleBloc, SaleState>(
      builder: (context, state) {
        if (state is SalesLoaded && state.stats != null) {
          final stats = state.stats!;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Ventas',
                    stats['totalSales']?.toString() ?? '0',
                    Icons.shopping_cart,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Total',
                    '\$${NumberFormat('#,##0.00').format(stats['totalRevenue'] ?? 0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                  _buildStatItem(
                    'Promedio',
                    '\$${NumberFormat('#,##0.00').format(stats['averageTicket'] ?? 0)}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesList() {
    return BlocConsumer<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is SaleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is SaleCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Venta cancelada exitosamente')),
          );
          // Recargar la lista
          context.read<SaleBloc>().add(LoadStoreSales(widget.storeId));
        }
      },
      builder: (context, state) {
        if (state is SaleLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SalesLoaded) {
          if (state.sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ventas registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.sales.length,
            itemBuilder: (context, index) {
              final sale = state.sales[index];
              return _buildSaleCard(context, sale);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSaleCard(BuildContext context, Sale sale) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSaleDetail(context, sale),
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
                          sale.customer ?? 'Cliente general',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(sale.at),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${NumberFormat('#,##0.00').format(sale.total)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '${sale.itemCount} items',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (sale.discount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_offer, size: 14, color: Colors.orange[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Descuento: \$${NumberFormat('#,##0.00').format(sale.discount)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
              if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  sale.notes!,
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
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

  void _showSaleDetail(BuildContext context, Sale sale) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalle de Venta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDetailRow('Cliente', sale.customer ?? 'Cliente general'),
                  _buildDetailRow('Fecha', dateFormat.format(sale.at)),
                  const Divider(height: 32),
                  const Text(
                    'Productos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...sale.items.map((item) => _buildItemRow(item)),
                  const Divider(height: 32),
                  _buildDetailRow('Subtotal', '\$${NumberFormat('#,##0.00').format(sale.subtotal)}'),
                  if (sale.discount > 0)
                    _buildDetailRow('Descuento', '-\$${NumberFormat('#,##0.00').format(sale.discount)}',
                        valueColor: Colors.orange),
                  if (sale.tax > 0)
                    _buildDetailRow('Impuesto', '\$${NumberFormat('#,##0.00').format(sale.tax)}'),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Total',
                    '\$${NumberFormat('#,##0.00').format(sale.total)}',
                    isTotal: true,
                  ),
                  if (sale.notes != null && sale.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(sale.notes!),
                  ],
                  const SizedBox(height: 24),
                  if (!sale.isDeleted)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmCancelSale(context, sale.id);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar Venta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isTotal ? Colors.green : Colors.black87),
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
                  '${item.qty.toStringAsFixed(0)} x \$${NumberFormat('#,##0.00').format(item.unitPrice)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(item.total)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Ventas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Ventas de hoy'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SaleBloc>().add(LoadTodaySales(widget.storeId));
              },
            ),
            ListTile(
              title: const Text('Por rango de fechas'),
              onTap: () {
                Navigator.pop(dialogContext);
                _selectDateRange(context);
              },
            ),
            ListTile(
              title: const Text('Todas las ventas'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SaleBloc>().add(LoadStoreSales(widget.storeId));
              },
            ),
          ],
        ),
      ),
    );
  }

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
        context.read<SaleBloc>().add(
              FilterSalesByDateRange(
                storeId: widget.storeId,
                startDate: picked.start,
                endDate: picked.end,
              ),
            );
      }
    }
  }

  void _confirmCancelSale(BuildContext context, String saleId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Venta'),
        content: const Text(
          '¿Está seguro de que desea cancelar esta venta? '
          'Esta acción revertirá el inventario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SaleBloc>().add(CancelSale(saleId));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToNewSale(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewSalePage(storeId: widget.storeId),
      ),
    );

    if (result == true && mounted) {
      // Recargar la lista después de crear una venta
      context.read<SaleBloc>().add(LoadStoreSales(widget.storeId));
    }
  }
}
