import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../domain/entities/transfer.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';
import 'new_transfer_page.dart';

/// Página de historial de transferencias
class TransfersHistoryPage extends StatefulWidget {
  final String storeId;

  const TransfersHistoryPage({
    super.key,
    required this.storeId,
  });

  @override
  State<TransfersHistoryPage> createState() => _TransfersHistoryPageState();
}

class _TransfersHistoryPageState extends State<TransfersHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransferStatus? _currentFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentFilter = _getStatusFromTab(_tabController.index);
      });
      context.read<TransferBloc>().add(
            FilterTransfersByStatusEvent(widget.storeId, _currentFilter),
          );
    }
  }

  TransferStatus? _getStatusFromTab(int index) {
    switch (index) {
      case 0:
        return null; // Todas
      case 1:
        return TransferStatus.pending;
      case 2:
        return TransferStatus.inTransit;
      case 3:
        return TransferStatus.completed;
      case 4:
        return TransferStatus.cancelled;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransferBloc>()
        ..add(LoadStoreTransfersEvent(widget.storeId))
        ..add(LoadTransfersStatsEvent(widget.storeId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transferencias'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                context.read<TransferBloc>().add(
                      SyncTransfersEvent(widget.storeId),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronizando...')),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Todas'),
              Tab(text: 'Pendientes'),
              Tab(text: 'En Tránsito'),
              Tab(text: 'Completadas'),
              Tab(text: 'Canceladas'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildStatsCards(),
            Expanded(
              child: _buildTransfersList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => NewTransferPage(storeId: widget.storeId),
              ),
            );
            if (result == true && mounted) {
              context.read<TransferBloc>().add(
                    LoadStoreTransfersEvent(widget.storeId),
                  );
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Nueva Transferencia'),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<TransferBloc, TransferState>(
      builder: (context, state) {
        Map<String, dynamic> stats = {};

        if (state is TransfersLoaded && state.stats != null) {
          stats = state.stats!;
        } else if (state is TransfersStatsLoaded) {
          stats = state.stats;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Enviadas',
                  '${stats['totalOutgoing'] ?? 0}',
                  Icons.upload,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Recibidas',
                  '${stats['totalIncoming'] ?? 0}',
                  Icons.download,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  '${stats['pending'] ?? 0}',
                  Icons.pending,
                  Colors.blue,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
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

  Widget _buildTransfersList() {
    return BlocConsumer<TransferBloc, TransferState>(
      listener: (context, state) {
        if (state is TransferError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is TransfersSynced) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sincronización completada'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<TransferBloc>().add(
                LoadStoreTransfersEvent(widget.storeId),
              );
        }
      },
      builder: (context, state) {
        if (state is TransferLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TransfersLoaded) {
          if (state.transfers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay transferencias',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<TransferBloc>().add(
                    SyncTransfersEvent(widget.storeId),
                  );
            },
            child: ListView.builder(
              itemCount: state.transfers.length,
              itemBuilder: (context, index) {
                final transfer = state.transfers[index];
                return _buildTransferCard(transfer);
              },
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildTransferCard(Transfer transfer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showTransferDetail(transfer),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transfer.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cantidad: ${transfer.qty}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(transfer.status),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Origen:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          transfer.fromStoreName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: Colors.grey[400]),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Destino:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          transfer.toStoreName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Solicitada: ${DateFormat('dd/MM/yyyy HH:mm').format(transfer.requestedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TransferStatus status) {
    Color color;
    String label;

    switch (status) {
      case TransferStatus.pending:
        color = Colors.blue;
        label = 'Pendiente';
        break;
      case TransferStatus.inTransit:
        color = Colors.orange;
        label = 'En Tránsito';
        break;
      case TransferStatus.completed:
        color = Colors.green;
        label = 'Completada';
        break;
      case TransferStatus.cancelled:
        color = Colors.red;
        label = 'Cancelada';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _showTransferDetail(Transfer transfer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                        'Detalle de Transferencia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusChip(transfer.status),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Producto', transfer.productName),
                  _buildDetailRow('Cantidad', '${transfer.qty}'),
                  const SizedBox(height: 16),
                  _buildDetailRow('Origen', transfer.fromStoreName),
                  _buildDetailRow('Destino', transfer.toStoreName),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Solicitada',
                    DateFormat('dd/MM/yyyy HH:mm').format(transfer.requestedAt),
                  ),
                  if (transfer.sentAt != null)
                    _buildDetailRow(
                      'Enviada',
                      DateFormat('dd/MM/yyyy HH:mm').format(transfer.sentAt!),
                    ),
                  if (transfer.receivedAt != null)
                    _buildDetailRow(
                      'Recibida',
                      DateFormat('dd/MM/yyyy HH:mm').format(transfer.receivedAt!),
                    ),
                  if (transfer.cancelledAt != null) ...[
                    _buildDetailRow(
                      'Cancelada',
                      DateFormat('dd/MM/yyyy HH:mm').format(transfer.cancelledAt!),
                    ),
                    if (transfer.cancellationReason != null)
                      _buildDetailRow('Motivo', transfer.cancellationReason!),
                  ],
                  if (transfer.notes != null) ...[
                    const SizedBox(height: 16),
                    _buildDetailRow('Notas', transfer.notes!),
                  ],
                  const SizedBox(height: 24),
                  _buildActionButtons(transfer),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Transfer transfer) {
    return BlocProvider.value(
      value: context.read<TransferBloc>(),
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              if (transfer.canBeSent)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmSend(transfer);
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Marcar como Enviada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (transfer.canBeReceived)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmReceive(transfer);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Marcar como Recibida'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              if (transfer.canBeCancelled) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmCancel(transfer);
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancelar Transferencia'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  void _confirmSend(Transfer transfer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Envío'),
        content: const Text(
          '¿Está seguro que desea marcar esta transferencia como enviada?\n\n'
          'El inventario de origen será decrementado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TransferBloc>().add(SendTransferEvent(transfer.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transferencia enviada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _confirmReceive(Transfer transfer) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Recepción'),
        content: const Text(
          '¿Está seguro que desea marcar esta transferencia como recibida?\n\n'
          'El inventario de destino será incrementado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TransferBloc>().add(
                    ReceiveTransferEvent(transfer.id),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transferencia recibida')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Recibir'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(Transfer transfer) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Transferencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Por qué desea cancelar esta transferencia?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Motivo',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debe ingresar un motivo')),
                );
                return;
              }
              Navigator.pop(dialogContext);
              context.read<TransferBloc>().add(
                    CancelTransferEvent(
                      transfer.id,
                      reasonController.text.trim(),
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transferencia cancelada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancelar Transferencia'),
          ),
        ],
      ),
    );
  }
}
