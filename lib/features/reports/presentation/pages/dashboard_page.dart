import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:inventario_app/core/config/dependency_injection.dart';
import 'package:inventario_app/features/reports/presentation/bloc/report_bloc.dart';
import 'package:inventario_app/features/reports/presentation/bloc/report_event.dart';
import 'package:inventario_app/features/reports/presentation/bloc/report_state.dart';
import 'package:inventario_app/features/reports/domain/entities/report.dart';

/// Página principal del Dashboard con métricas generales
class DashboardPage extends StatelessWidget {
  final String storeId;

  const DashboardPage({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportBloc>()
        ..add(LoadDashboard(
          storeId: storeId,
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        )),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ReportBloc>().add(LoadDashboard(
                      storeId: storeId,
                      startDate: DateTime.now().subtract(const Duration(days: 30)),
                      endDate: DateTime.now(),
                    ));
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
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar dashboard',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReportBloc>().add(LoadDashboard(
                              storeId: storeId,
                              startDate: DateTime.now().subtract(const Duration(days: 30)),
                              endDate: DateTime.now(),
                            ));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              return _buildDashboard(context, state.dashboard);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardData dashboard) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final percentFormat = NumberFormat.percentPattern();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportBloc>().add(LoadDashboard(
              storeId: storeId,
              startDate: DateTime.now().subtract(const Duration(days: 30)),
              endDate: DateTime.now(),
            ));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Fecha de generación
          Text(
            'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(dashboard.generatedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Sección de finanzas
          _buildSectionTitle(context, 'Resumen Financiero'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Ingresos',
                  currencyFormat.format(dashboard.totalRevenue),
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Costos',
                  currencyFormat.format(dashboard.totalCosts),
                  Icons.trending_down,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Ganancia',
                  currencyFormat.format(dashboard.profit),
                  Icons.account_balance_wallet,
                  dashboard.profit >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Margen',
                  '${dashboard.profitMargin.toStringAsFixed(1)}%',
                  Icons.percent,
                  dashboard.profitMargin >= 0 ? Colors.blue : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Sección de operaciones
          _buildSectionTitle(context, 'Operaciones'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCountCard(
                  context,
                  'Ventas',
                  dashboard.totalSales,
                  Icons.point_of_sale,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountCard(
                  context,
                  'Compras',
                  dashboard.totalPurchases,
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountCard(
                  context,
                  'Traslados',
                  dashboard.totalTransfers,
                  Icons.swap_horiz,
                  Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Alertas de inventario
          if (dashboard.lowStockAlerts > 0) ...[
            _buildAlertCard(
              context,
              'Alertas de Stock Bajo',
              '${dashboard.lowStockAlerts} productos con stock bajo',
              Icons.warning,
              Colors.orange,
            ),
            const SizedBox(height: 16),
          ],

          // Top productos vendidos
          _buildSectionTitle(context, 'Productos Más Vendidos'),
          const SizedBox(height: 12),
          _buildTopProductsList(context, dashboard.topSellingProducts),

          const SizedBox(height: 24),

          // Botones de navegación a reportes específicos
          _buildSectionTitle(context, 'Reportes Detallados'),
          const SizedBox(height: 12),
          _buildReportButton(
            context,
            'Reporte de Ventas',
            'Análisis detallado de ventas por período',
            Icons.assessment,
            Colors.green,
            () {
              // TODO: Navegar a SalesReportPage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte de ventas próximamente')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildReportButton(
            context,
            'Reporte de Compras',
            'Análisis de compras y proveedores',
            Icons.shopping_bag,
            Colors.orange,
            () {
              // TODO: Navegar a PurchasesReportPage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte de compras próximamente')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildReportButton(
            context,
            'Reporte de Inventario',
            'Estado actual del inventario',
            Icons.inventory,
            Colors.blue,
            () {
              // TODO: Navegar a InventoryReportPage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte de inventario próximamente')),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildReportButton(
            context,
            'Reporte de Traslados',
            'Análisis de traslados entre tiendas',
            Icons.local_shipping,
            Colors.purple,
            () {
              // TODO: Navegar a TransfersReportPage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reporte de traslados próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
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

  Widget _buildCountCard(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              '$count',
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

  Widget _buildAlertCard(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsList(BuildContext context, Map<String, dynamic> products) {
    if (products.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de productos'),
        ),
      );
    }

    final productList = products.values.take(5).toList();
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: productList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = productList[index] as Map<String, dynamic>;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.shade100,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(product['productName'] ?? 'Producto ${index + 1}'),
            subtitle: Text('Cantidad: ${product['quantity']}'),
            trailing: Text(
              currencyFormat.format(product['total']),
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

  Widget _buildReportButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
        onTap: onTap,
      ),
    );
  }
}
