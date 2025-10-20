import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../domain/entities/purchase.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/purchase_bloc.dart';
import '../bloc/purchase_event.dart';
import '../bloc/purchase_state.dart';

/// Página para crear una nueva compra
class NewPurchasePage extends StatefulWidget {
  final String storeId;

  const NewPurchasePage({super.key, required this.storeId});

  @override
  State<NewPurchasePage> createState() => _NewPurchasePageState();
}

class _NewPurchasePageState extends State<NewPurchasePage> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');

  Supplier? _selectedSupplier;
  final List<PurchaseItem> _items = [];

  @override
  void dispose() {
    _invoiceController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PurchaseBloc>()..add(const LoadActiveSuppliers()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva Compra')),
        body: BlocConsumer<PurchaseBloc, PurchaseState>(
          listener: (context, state) {
            if (state is PurchaseCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compra creada exitosamente')),
              );
              Navigator.pop(context, true);
            } else if (state is PurchaseError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is PurchaseLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSupplierSection(state),
                    const SizedBox(height: 24),
                    _buildInvoiceField(),
                    const SizedBox(height: 16),
                    _buildItemsSection(),
                    const SizedBox(height: 24),
                    _buildTotalsSection(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                    const SizedBox(height: 24),
                    _buildCreateButton(context),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Sección de selección de proveedor
  Widget _buildSupplierSection(PurchaseState state) {
    List<Supplier> suppliers = [];
    if (state is SuppliersLoaded) {
      suppliers = state.suppliers;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proveedor *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Supplier>(
          value: _selectedSupplier,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Seleccione un proveedor',
          ),
          items: suppliers.map((supplier) {
            return DropdownMenuItem(
              value: supplier,
              child: Text(supplier.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedSupplier = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Debe seleccionar un proveedor';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Campo de número de factura
  Widget _buildInvoiceField() {
    return TextFormField(
      controller: _invoiceController,
      decoration: const InputDecoration(
        labelText: 'Número de Factura',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
    );
  }

  /// Sección de items
  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddItemDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Agregar Item'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_items.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay items agregados',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_items.map((item) => _buildItemCard(item))),
      ],
    );
  }

  /// Tarjeta de item
  Widget _buildItemCard(PurchaseItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(item.productName),
        subtitle: Text(
          '${item.qty} x \$${NumberFormat('#,##0.00').format(item.unitCost)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${NumberFormat('#,##0.00').format(item.total)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _items.remove(item);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Sección de totales
  Widget _buildTotalsSection() {
    final subtotal = _calculateSubtotal();
    final discount = double.tryParse(_discountController.text) ?? 0;
    final taxPercent = double.tryParse(_taxController.text) ?? 0;
    final taxAmount = (subtotal - discount) * taxPercent / 100;
    final total = subtotal - discount + taxAmount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _discountController,
                    decoration: const InputDecoration(
                      labelText: 'Descuento',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _taxController,
                    decoration: const InputDecoration(
                      labelText: 'IVA',
                      border: OutlineInputBorder(),
                      suffixText: '%',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            _buildTotalRow('Subtotal', subtotal),
            if (discount > 0) _buildTotalRow('Descuento', -discount),
            if (taxAmount > 0) _buildTotalRow('IVA ($taxPercent%)', taxAmount),
            const Divider(),
            _buildTotalRow('TOTAL', total, isBold: true, fontSize: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
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
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(amount)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: amount < 0 ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de notas
  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notas',
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
    );
  }

  /// Botón de crear compra
  Widget _buildCreateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _items.isEmpty ? null : () => _createPurchase(context),
        icon: const Icon(Icons.check),
        label: const Text('Crear Compra'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Diálogo para agregar item
  void _showAddItemDialog() {
    final productNameController = TextEditingController();
    final qtyController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: productNameController,
              decoration: const InputDecoration(
                labelText: 'Producto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              decoration: const InputDecoration(
                labelText: 'Costo Unitario',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final productName = productNameController.text.trim();
              final qty = double.tryParse(qtyController.text) ?? 0;
              final cost = double.tryParse(costController.text) ?? 0;

              if (productName.isNotEmpty && qty > 0 && cost > 0) {
                setState(() {
                  _items.add(
                    PurchaseItem(
                      productId: const Uuid().v4(),
                      variantId: null,
                      productName: productName,
                      qty: qty,
                      unitCost: cost,
                      total: qty * cost,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  /// Calcular subtotal
  double _calculateSubtotal() {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  /// Crear compra
  void _createPurchase(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) return;
    if (_selectedSupplier == null) return;

    final subtotal = _calculateSubtotal();
    final discount = double.tryParse(_discountController.text) ?? 0;
    final tax = double.tryParse(_taxController.text) ?? 0;
    final total = Purchase.calculateTotal(_items, discount, tax);

    final purchase = Purchase(
      id: const Uuid().v4(),
      storeId: widget.storeId,
      supplierId: _selectedSupplier!.id,
      supplierName: _selectedSupplier!.name,
      authorUserId: 'current-user', // TODO: Get from auth
      items: _items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      invoiceNumber: _invoiceController.text.trim().isEmpty
          ? null
          : _invoiceController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      at: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: false,
    );

    context.read<PurchaseBloc>().add(CreatePurchase(purchase));
  }
}
