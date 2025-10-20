import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/inventory_bloc.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/adjust_inventory.dart';

class InventoryDashboardPage extends StatefulWidget {
  final String storeId;

  const InventoryDashboardPage({
    super.key,
    required this.storeId,
  });

  @override
  State<InventoryDashboardPage> createState() =>
      _InventoryDashboardPageState();
}

class _InventoryDashboardPageState extends State<InventoryDashboardPage> {
  bool _showLowStockOnly = false;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  void _loadInventory() {
    if (_showLowStockOnly) {
      context.read<InventoryBloc>().add(
            InventoryLowStockRequested(widget.storeId),
          );
    } else {
      context.read<InventoryBloc>().add(
            InventoryLoadRequested(widget.storeId),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          FilterChip(
            label: const Text('Stock Bajo'),
            selected: _showLowStockOnly,
            onSelected: (value) {
              setState(() => _showLowStockOnly = value);
              _loadInventory();
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              context.read<InventoryBloc>().add(
                    InventoryStatsRequested(widget.storeId),
                  );
              _showStatsDialog();
            },
            tooltip: 'Estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInventory,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: BlocConsumer<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state is InventoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is InventoryOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InventoryLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showLowStockOnly
                          ? 'No hay productos con stock bajo'
                          : 'No hay productos en inventario',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadInventory(),
              child: ListView.builder(
                itemCount: state.items.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return _InventoryItemCard(
                    item: item,
                    onAdjust: () => _showAdjustDialog(item),
                    onHistory: () => _showHistoryDialog(item.id),
                  );
                },
              ),
            );
          }

          return const Center(child: Text('Cargando inventario...'));
        },
      ),
    );
  }

  void _showAdjustDialog(InventoryItem item) {
    final qtyController = TextEditingController(
      text: item.stockQty.toString(),
    );
    String adjustType = 'set';
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajustar Inventario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Stock actual: ${item.stockQty}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: adjustType,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: const [
                  DropdownMenuItem(value: 'set', child: Text('Establecer')),
                  DropdownMenuItem(
                    value: 'increment',
                    child: Text('Incrementar'),
                  ),
                  DropdownMenuItem(
                    value: 'decrement',
                    child: Text('Decrementar'),
                  ),
                ],
                onChanged: (value) => adjustType = value!,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Motivo'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final newQty = double.tryParse(qtyController.text) ?? 0;
              context.read<InventoryBloc>().add(
                    InventoryAdjustRequested(
                      AdjustInventoryParams(
                        inventoryId: item.id,
                        newQty: newQty,
                        userId: 'current_user_id', // TODO: Obtener del auth
                        type: adjustType,
                        reason: reasonController.text,
                        notes: null,
                      ),
                    ),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text('Ajustar'),
          ),
        ],
      ),
    );
  }

  void _showHistoryDialog(String inventoryId) {
    context.read<InventoryBloc>().add(InventoryHistoryRequested(inventoryId));

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Historial de Ajustes'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryHistoryLoaded) {
                return ListView.builder(
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final adj = state.history[index];
                    return ListTile(
                      leading: Icon(
                        adj.type == 'increment'
                            ? Icons.arrow_upward
                            : adj.type == 'decrement'
                                ? Icons.arrow_downward
                                : Icons.edit,
                        color: adj.type == 'increment'
                            ? Colors.green
                            : adj.type == 'decrement'
                                ? Colors.red
                                : Colors.blue,
                      ),
                      title: Text(
                        '${adj.previousQty} → ${adj.newQty} (${adj.adjustmentQty >= 0 ? '+' : ''}${adj.adjustmentQty})',
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (adj.reason != null) Text('Motivo: ${adj.reason}'),
                          Text(
                            adj.createdAt.toString().substring(0, 16),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Estadísticas de Inventario'),
        content: BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, state) {
            if (state is InventoryStatsLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StatRow(
                    icon: Icons.inventory,
                    label: 'Total Productos',
                    value: state.stats['totalProducts'].toString(),
                  ),
                  _StatRow(
                    icon: Icons.warning,
                    label: 'Stock Bajo',
                    value: state.stats['lowStockItems'].toString(),
                    color: Colors.orange,
                  ),
                  _StatRow(
                    icon: Icons.error,
                    label: 'Agotados',
                    value: state.stats['outOfStockItems'].toString(),
                    color: Colors.red,
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback onAdjust;
  final VoidCallback onHistory;

  const _InventoryItemCard({
    required this.item,
    required this.onAdjust,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.isOutOfStock
              ? Colors.red
              : item.isLowStock
                  ? Colors.orange
                  : Colors.green,
          child: Text(
            item.stockQty.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Producto: ${item.productId.substring(0, 8)}...'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Stock: ${item.stockQty}'),
            Text('Min: ${item.minQty} | Max: ${item.maxQty}'),
            LinearProgressIndicator(
              value: item.stockPercentage,
              backgroundColor: Colors.grey[300],
              color: item.isOutOfStock
                  ? Colors.red
                  : item.isLowStock
                      ? Colors.orange
                      : Colors.green,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'adjust',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Ajustar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'history',
              child: Row(
                children: [
                  Icon(Icons.history),
                  SizedBox(width: 8),
                  Text('Historial'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'adjust') onAdjust();
            if (value == 'history') onHistory();
          },
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
