import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/dependency_injection.dart';
import '../bloc/report_bloc.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';
import '../../domain/entities/report.dart';

/// Página de reporte detallado de traslados
class TransfersReportPage extends StatefulWidget {
  final String storeId;

  const TransfersReportPage({super.key, required this.storeId});

  @override
  State<TransfersReportPage> createState() => _TransfersReportPageState();
}

class _TransfersReportPageState extends State<TransfersReportPage> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReportBloc>()
        ..add(
          LoadTransfersReport(
            storeId: widget.storeId,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reporte de Traslados'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () => _selectDateRange(context),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ReportBloc>().add(
                  LoadTransfersReport(
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
                          LoadTransfersReport(
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

            if (state is TransfersReportLoaded) {
              return _buildReport(context, state.report);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildReport(BuildContext context, TransfersReport report) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ReportBloc>().add(
          LoadTransfersReport(
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
          _buildMetricCard(
            context,
            'Total Traslados',
            '${report.totalTransfers}',
            Icons.local_shipping,
            Colors.purple,
          ),

          const SizedBox(height: 24),

          // Estados de traslados
          Text(
            'Estados de Traslados',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Pendientes',
                  report.pendingTransfers,
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  context,
                  'En Tránsito',
                  report.inTransitTransfers,
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Completados',
                  report.completedTransfers,
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  context,
                  'Cancelados',
                  report.cancelledTransfers,
                  Icons.cancel,
                  Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Traslados por día
          Text(
            'Traslados por Día',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDailyTransfersChart(context, report.transfersByDay),

          const SizedBox(height: 24),

          // Traslados por tienda
          Text(
            'Traslados por Tienda',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStoresList(context, report.transfersByStore),
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

  Widget _buildStatusCard(
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

  Widget _buildDailyTransfersChart(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No hay datos de traslados por día'),
        ),
      );
    }

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
          final count = entry.value as int;

          return ListTile(
            leading: const Icon(Icons.calendar_today, color: Colors.purple),
            title: Text(date),
            trailing: Text(
              '$count traslados',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
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
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Salientes: ${storeData['outgoing']}'),
                Text('Entrantes: ${storeData['incoming']}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  '${storeData['total']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontSize: 18,
                  ),
                ),
              ],
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
          LoadTransfersReport(
            storeId: widget.storeId,
            startDate: startDate,
            endDate: endDate,
          ),
        );
      }
    }
  }
}
