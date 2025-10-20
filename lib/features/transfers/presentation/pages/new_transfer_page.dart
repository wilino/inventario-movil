import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../domain/entities/transfer.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';
import '../bloc/transfer_state.dart';

/// Página para crear nueva transferencia
class NewTransferPage extends StatefulWidget {
  final String storeId;

  const NewTransferPage({
    super.key,
    required this.storeId,
  });

  @override
  State<NewTransferPage> createState() => _NewTransferPageState();
}

class _NewTransferPageState extends State<NewTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  String? _destinationStoreId;
  String _destinationStoreName = '';
  String? _productId;
  String _productName = '';
  double _quantity = 1.0;

  // Mock data - En producción vendría de la base de datos
  final List<Map<String, String>> _stores = [
    {'id': 'store_1', 'name': 'Almacén Principal'},
    {'id': 'store_2', 'name': 'Sucursal Centro'},
    {'id': 'store_3', 'name': 'Sucursal Norte'},
    {'id': 'store_4', 'name': 'Sucursal Sur'},
  ];

  final List<Map<String, dynamic>> _products = [
    {'id': 'prod_1', 'name': 'Laptop HP 15', 'stock': 10.0},
    {'id': 'prod_2', 'name': 'Mouse Logitech', 'stock': 50.0},
    {'id': 'prod_3', 'name': 'Teclado Mecánico', 'stock': 20.0},
    {'id': 'prod_4', 'name': 'Monitor Samsung 24"', 'stock': 15.0},
    {'id': 'prod_5', 'name': 'Cable HDMI', 'stock': 100.0},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransferBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nueva Transferencia'),
        ),
        body: BlocListener<TransferBloc, TransferState>(
          listener: (context, state) {
            if (state is TransferCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Transferencia creada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is TransferError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStoreSelector(),
                const SizedBox(height: 16),
                _buildProductSelector(),
                const SizedBox(height: 16),
                _buildQuantityField(),
                const SizedBox(height: 16),
                _buildNotesField(),
                const SizedBox(height: 24),
                _buildSummaryCard(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoreSelector() {
    // Filtrar la tienda actual
    final availableStores = _stores
        .where((store) => store['id'] != widget.storeId)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Almacén de Destino',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar destino',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              value: _destinationStoreId,
              items: availableStores
                  .map((store) => DropdownMenuItem(
                        value: store['id'],
                        child: Text(store['name']!),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _destinationStoreId = value;
                  _destinationStoreName = _stores
                      .firstWhere((s) => s['id'] == value)['name']!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe seleccionar un almacén de destino';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Producto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar producto',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_bag),
              ),
              value: _productId,
              items: _products
                  .map((product) => DropdownMenuItem<String>(
                        value: product['id'] as String,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(product['name'] as String),
                            Text(
                              'Stock disponible: ${product['stock']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _productId = value;
                  final product = _products.firstWhere((p) => p['id'] == value);
                  _productName = product['name'];
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe seleccionar un producto';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Cantidad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Cantidad a transferir',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
                suffixText: 'unidades',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              initialValue: _quantity.toString(),
              onChanged: (value) {
                setState(() {
                  _quantity = double.tryParse(value) ?? 1.0;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Debe ingresar una cantidad';
                }
                final qty = double.tryParse(value);
                if (qty == null || qty <= 0) {
                  return 'La cantidad debe ser mayor a 0';
                }
                if (_productId != null) {
                  final product = _products.firstWhere((p) => p['id'] == _productId);
                  if (qty > product['stock']) {
                    return 'Stock insuficiente (disponible: ${product['stock']})';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Notas (Opcional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Agregar notas o comentarios',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit_note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    if (_destinationStoreId == null || _productId == null) {
      return const SizedBox();
    }

    final currentStoreName = _stores.firstWhere(
      (s) => s['id'] == widget.storeId,
      orElse: () => {'name': 'Almacén actual'},
    )['name']!;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de Transferencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 16),
            _buildSummaryRow('Producto', _productName),
            _buildSummaryRow('Cantidad', '$_quantity unidades'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origen',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currentStoreName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, color: Colors.blue[700]),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Destino',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _destinationStoreName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<TransferBloc, TransferState>(
      builder: (context, state) {
        final isLoading = state is TransferLoading;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _submitTransfer,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
              isLoading ? 'Creando...' : 'Crear Transferencia',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _submitTransfer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final currentStoreName = _stores.firstWhere(
      (s) => s['id'] == widget.storeId,
      orElse: () => {'name': 'Almacén actual'},
    )['name']!;

    final transfer = Transfer(
      id: const Uuid().v4(),
      fromStoreId: widget.storeId,
      fromStoreName: currentStoreName,
      toStoreId: _destinationStoreId!,
      toStoreName: _destinationStoreName,
      productId: _productId!,
      productName: _productName,
      qty: _quantity,
      status: TransferStatus.pending,
      authorUserId: 'current_user_id', // En producción viene del auth
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      requestedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<TransferBloc>().add(CreateTransferEvent(transfer));
  }
}
