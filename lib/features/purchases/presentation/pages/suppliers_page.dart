import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../domain/entities/supplier.dart';
import '../bloc/purchase_bloc.dart';
import '../bloc/purchase_event.dart';
import '../bloc/purchase_state.dart';

/// Página para gestionar proveedores
class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Supplier> _filteredSuppliers = [];
  List<Supplier> _allSuppliers = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<PurchaseBloc>()..add(const LoadActiveSuppliers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Proveedores'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () {
                context.read<PurchaseBloc>().add(const LoadActiveSuppliers());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildSuppliersList()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showSupplierDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Nuevo Proveedor'),
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
          hintText: 'Buscar proveedor...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _filteredSuppliers = _allSuppliers;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (query) {
          setState(() {
            if (query.isEmpty) {
              _filteredSuppliers = _allSuppliers;
            } else {
              _filteredSuppliers = _allSuppliers.where((supplier) {
                final searchLower = query.toLowerCase();
                return supplier.name.toLowerCase().contains(searchLower) ||
                    (supplier.email?.toLowerCase().contains(searchLower) ??
                        false) ||
                    (supplier.phone?.contains(query) ?? false);
              }).toList();
            }
          });
        },
      ),
    );
  }

  /// Lista de proveedores
  Widget _buildSuppliersList() {
    return BlocConsumer<PurchaseBloc, PurchaseState>(
      listener: (context, state) {
        if (state is PurchaseError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is SupplierCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proveedor creado exitosamente')),
          );
          context.read<PurchaseBloc>().add(const LoadActiveSuppliers());
        } else if (state is SupplierUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proveedor actualizado exitosamente')),
          );
          context.read<PurchaseBloc>().add(const LoadActiveSuppliers());
        } else if (state is SupplierDeactivated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proveedor desactivado exitosamente')),
          );
          context.read<PurchaseBloc>().add(const LoadActiveSuppliers());
        }
      },
      builder: (context, state) {
        if (state is PurchaseLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SuppliersLoaded) {
          if (_allSuppliers != state.suppliers) {
            _allSuppliers = state.suppliers;
            _filteredSuppliers = _searchController.text.isEmpty
                ? _allSuppliers
                : _filteredSuppliers;
          }

          final displaySuppliers = _searchController.text.isEmpty
              ? state.suppliers
              : _filteredSuppliers;

          if (displaySuppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty
                        ? 'No hay proveedores registrados'
                        : 'No se encontraron proveedores',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: displaySuppliers.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final supplier = displaySuppliers[index];
              return _buildSupplierCard(context, supplier);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Tarjeta de proveedor
  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSupplierDetail(context, supplier),
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
                    child: Text(
                      supplier.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showSupplierDialog(context, supplier: supplier);
                      } else if (value == 'deactivate') {
                        _confirmDeactivateSupplier(context, supplier);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: Row(
                          children: [
                            Icon(Icons.block, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Desactivar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (supplier.contactName != null) ...[
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      supplier.contactName!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (supplier.email != null) ...[
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        supplier.email!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (supplier.phone != null) ...[
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      supplier.phone!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Mostrar detalle del proveedor
  void _showSupplierDetail(BuildContext context, Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
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
                        'Detalle del Proveedor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(context);
                          _showSupplierDialog(context, supplier: supplier);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  _buildDetailRow('Nombre', supplier.name),
                  if (supplier.contactName != null)
                    _buildDetailRow('Contacto', supplier.contactName!),
                  if (supplier.email != null)
                    _buildDetailRow('Email', supplier.email!),
                  if (supplier.phone != null)
                    _buildDetailRow('Teléfono', supplier.phone!),
                  if (supplier.address != null)
                    _buildDetailRow('Dirección', supplier.address!),
                  if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Notas',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(supplier.notes!),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDeactivateSupplier(context, supplier);
                      },
                      icon: const Icon(Icons.block, color: Colors.red),
                      label: const Text(
                        'Desactivar Proveedor',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  /// Diálogo para crear/editar proveedor
  void _showSupplierDialog(BuildContext context, {Supplier? supplier}) {
    final isEditing = supplier != null;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: supplier?.name);
    final contactController = TextEditingController(
      text: supplier?.contactName,
    );
    final emailController = TextEditingController(text: supplier?.email);
    final phoneController = TextEditingController(text: supplier?.phone);
    final addressController = TextEditingController(text: supplier?.address);
    final notesController = TextEditingController(text: supplier?.notes);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    labelText: 'Persona de Contacto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        !value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Dirección',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newSupplier = Supplier(
                  id: supplier?.id ?? const Uuid().v4(),
                  name: nameController.text.trim(),
                  contactName: contactController.text.trim().isEmpty
                      ? null
                      : contactController.text.trim(),
                  email: emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  phone: phoneController.text.trim().isEmpty
                      ? null
                      : phoneController.text.trim(),
                  address: addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  isActive: true,
                  createdAt: supplier?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                Navigator.pop(dialogContext);

                if (isEditing) {
                  context.read<PurchaseBloc>().add(UpdateSupplier(newSupplier));
                } else {
                  context.read<PurchaseBloc>().add(CreateSupplier(newSupplier));
                }
              }
            },
            child: Text(isEditing ? 'Actualizar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  /// Confirmar desactivación de proveedor
  void _confirmDeactivateSupplier(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desactivar Proveedor'),
        content: Text(
          '¿Está seguro de que desea desactivar a "${supplier.name}"? '
          'El proveedor no aparecerá en las listas de compras.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<PurchaseBloc>().add(DeactivateSupplier(supplier.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }
}
