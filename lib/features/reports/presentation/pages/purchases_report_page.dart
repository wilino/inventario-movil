import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/dependency_injection.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../../domain/entities/report.dart';

/// Página de reporte detallado de compras
class PurchasesReportPage extends StatefulWidget {
  final String storeId;

  const PurchasesReportPage({super.key, required this.storeId});

  @override
  State<PurchasesReportPage> createState() => _PurchasesReportPageState();
}

class _PurchasesReportPageState extends State<PurchasesReportPage> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportBloc>()
        ..add(
          LoadPurchasesReport(
            storeId: widget.storeId,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reporte de Compras'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ReportBloc>().add(
                  LoadPurchasesReport(
                    storeId: widget.storeId,
                    startDate: startDate,
                    endDate: endDate,
                  ),
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
                          LoadPurchasesReport(
                            storeId: widget.storeId,
                            startDate: startDate,
                            endDate: endDate,
                          ),
                        );
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is PurchasesReportLoaded) {
              return _buildReport(context, state.report);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context, PurchasesReport report) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'Bs ',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportBloc>().add(
          LoadPurchasesReport(
            storeId: widget.storeId,
            startDate: startDate,
            endDate: endDate,
          ),
        );
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Período del reporte
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Período',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${dateFormat.format(report.startDate)} - ${dateFormat.format(report.endDate)}',
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
                  'Total Compras',
                  currencyFormat.format(report.totalPurchases),
                  Icons.shopping_cart,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  'Transacciones',
                  '${report.totalTransactions}',
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            context,
            'Compra Promedio',
            currencyFormat.format(report.averagePurchase),
            Icons.trending_up,
            Colors.green,
          ),

          const SizedBox(height: 24),

          // Compras por día
          Text(
            'Compras por Día',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDailyPurchasesChart(context, report.purchasesByDay),

          const SizedBox(height: 24),

          // Top proveedores
          Text(
            'Proveedores Principales',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTopSuppliersList(context, report.topSuppliers),

          const SizedBox(height: 24),

          // Compras por tienda
          Text(
            'Compras por Tienda',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStoresList(context, report.purchasesByStore),
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

  Widget _buildDailyPurchasesChart(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de compras por día'),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: 'Bs ',
      decimalDigits: 2,
    );
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEntries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final date = DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.parse(entry.key));
          final amount = entry.value as double;

          return ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.orange),
            title: Text(date),
            trailing: Text(
              currencyFormat.format(amount),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSuppliersList(
    BuildContext context,
    Map<String, dynamic> suppliers,
  ) {
    if (suppliers.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de proveedores'),
        ),
      );
    }

    final supplierList = suppliers.values.toList();
    final currencyFormat = NumberFormat.currency(
      symbol: 'Bs ',
      decimalDigits: 2,
    );

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: supplierList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final supplier = supplierList[index] as Map<String, dynamic>;
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(supplier['supplierName'] ?? 'Proveedor ${index + 1}'),
            subtitle: Text('Compras: ${supplier['count']}'),
            trailing: Text(
              currencyFormat.format(supplier['total']),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
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
            subtitle: Text('Transacciones: ${storeData['transactions']}'),
            trailing: Text(
              currencyFormat.format(storeData['total']),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      if (context.mounted) {
        context.read<ReportBloc>().add(
          LoadPurchasesReport(
            storeId: widget.storeId,
            startDate: startDate,
            endDate: endDate,
          ),
        );
      }
    }
  }
}
