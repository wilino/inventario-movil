import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/dependency_injection.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../../domain/entities/report.dart';

/// Página de reporte de inventario
class InventoryReportPage extends StatelessWidget {
  final String storeId;

  const InventoryReportPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReportBloc>()..add(LoadInventoryReport(storeId: storeId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reporte de Inventario'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ReportBloc>().add(
                  LoadInventoryReport(storeId: storeId),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ReportBloc, ReportState>(
          builder: (context, state) {
            if (state is ReportLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReportError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar reporte',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportBloc>().add(
                          LoadInventoryReport(storeId: storeId),
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is InventoryReportLoaded) {
              return _buildReport(context, state.report);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context, InventoryReport report) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'Bs ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportBloc>().add(LoadInventoryReport(storeId: storeId));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Fecha de generación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    dateFormat.format(report.generatedAt),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resumen general
          Text(
            'Resumen General',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Total Productos',
                  '${report.totalProducts}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Valor Total',
                  currencyFormat.format(report.totalValue),
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Alertas
          Text(
            'Alertas de Inventario',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAlertCard(
                  context,
                  'Stock Bajo',
                  '${report.lowStockProducts}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAlertCard(
                  context,
                  'Sin Stock',
                  '${report.outOfStockProducts}',
                  Icons.error,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Productos con stock bajo
          if (report.lowStockItems.isNotEmpty) ...[
            Text(
              'Productos con Stock Bajo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildLowStockList(context, report.lowStockItems),
            const SizedBox(height: 24),
          ],

          // Inventario por tienda
          Text(
            'Inventario por Tienda',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStoresList(context, report.inventoryByStore),

          const SizedBox(height: 24),

          // Productos por categoría
          Text(
            'Productos por Categoría',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCategoriesList(context, report.productsByCategory),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockList(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final currentStock = item['currentStock'] ?? 0;
          final minQty = item['minQty'] ?? 0;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(Icons.warning, color: Colors.orange.shade700),
            ),
            title: Text('Producto ID: ${item['productId']}'),
            subtitle: Text('Mínimo requerido: $minQty'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Stock: $currentStock',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoresList(BuildContext context, Map<String, dynamic> stores) {
    if (stores.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de tiendas'),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: 'Bs ',
      decimalDigits: 2,
    );

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stores.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = stores.entries.elementAt(index);
          final storeData = entry.value as Map<String, dynamic>;

          return ListTile(
            leading: const Icon(Icons.store, color: Colors.blue),
            title: Text('Tienda ${index + 1}'),
            subtitle: Text('Productos: ${storeData['products']}'),
            trailing: Text(
              currencyFormat.format(storeData['value']),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    Map<String, dynamic> categories,
  ) {
    if (categories.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de categorías'),
        ),
      );
    }

    final total = categories.values.fold<int>(
      0,
      (sum, count) => sum + (count as int),
    );

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = categories.entries.elementAt(index);
          final count = entry.value as int;
          final percentage = total > 0
              ? ((count / total) * 100).toStringAsFixed(1)
              : '0.0';

          return ListTile(
            leading: const Icon(Icons.category, color: Colors.purple),
            title: Text(entry.key),
            subtitle: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
