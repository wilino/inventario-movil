import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _skuController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _unitController = TextEditingController();

  bool _hasVariants = false;
  bool _isActive = true;
  bool _isEditing = false;

  final List<String> _suggestedCategories = [
    'Decoración',
    'Muebles',
    'Accesorios',
    'Iluminación',
    'Textiles',
    'Arte',
    'Jardinería',
    'Cocina',
  ];

  final List<String> _suggestedUnits = [
    'Unidad',
    'Pieza',
    'Set',
    'Par',
    'Caja',
    'Paquete',
    'Metro',
    'Kilogramo',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _isEditing = true;
      _loadProductData(widget.product!);
    } else {
      _unitController.text = 'Unidad';
    }
  }

  void _loadProductData(Product product) {
    _skuController.text = product.sku;
    _nameController.text = product.name;
    _descriptionController.text = product.description ?? '';
    _categoryController.text = product.category;
    _costPriceController.text = product.costPrice.toString();
    _salePriceController.text = product.salePrice.toString();
    _unitController.text = product.unit;
    _hasVariants = product.hasVariants;
    _isActive = product.isActive;
  }

  @override
  void dispose() {
    _skuController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _costPriceController.dispose();
    _salePriceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final product = Product(
        id: widget.product?.id ?? const Uuid().v4(),
        sku: _skuController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        costPrice: double.parse(_costPriceController.text),
        salePrice: double.parse(_salePriceController.text),
        unit: _unitController.text.trim(),
        hasVariants: _hasVariants,
        isActive: _isActive,
        createdAt: widget.product?.createdAt ?? now,
        updatedAt: now,
        isDeleted: false,
      );

      if (_isEditing) {
        context.read<ProductBloc>().add(ProductUpdateRequested(product));
      } else {
        context.read<ProductBloc>().add(ProductCreateRequested(product));
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Producto' : 'Nuevo Producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SKU
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU *',
                hintText: 'Código del producto',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El SKU es requerido';
                }
                return null;
              },
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                hintText: 'Nombre del producto',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Descripción opcional del producto',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Categoría
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _categoryController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _suggestedCategories;
                }
                return _suggestedCategories.where(
                  (category) => category.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (value) => _categoryController.text = value,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _categoryController.addListener(() {
                      controller.text = _categoryController.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        hintText: 'Selecciona o escribe una categoría',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La categoría es requerida';
                        }
                        return null;
                      },
                      onChanged: (value) => _categoryController.text = value,
                    );
                  },
            ),
            const SizedBox(height: 16),

            // Precios
            Row(
              children: [
                // Precio de costo
                Expanded(
                  child: TextFormField(
                    controller: _costPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de Costo *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Precio de venta
                Expanded(
                  child: TextFormField(
                    controller: _salePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio de Venta *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.sell),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Requerido';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price < 0) {
                        return 'Precio inválido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Unidad de medida
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _unitController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _suggestedUnits;
                }
                return _suggestedUnits.where(
                  (unit) => unit.toLowerCase().contains(
                    textEditingValue.text.toLowerCase(),
                  ),
                );
              },
              onSelected: (value) => _unitController.text = value,
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    _unitController.addListener(() {
                      controller.text = _unitController.text;
                    });
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        labelText: 'Unidad de Medida *',
                        hintText: 'Unidad, Pieza, Set, etc.',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La unidad es requerida';
                        }
                        return null;
                      },
                      onChanged: (value) => _unitController.text = value,
                    );
                  },
            ),
            const SizedBox(height: 16),

            // Switches
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Tiene variantes'),
                    subtitle: const Text('Ej: Tallas, colores, etc.'),
                    value: _hasVariants,
                    onChanged: (value) => setState(() => _hasVariants = value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Producto activo'),
                    subtitle: const Text('Disponible para venta'),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _handleSubmit,
                    child: Text(_isEditing ? 'Actualizar' : 'Crear'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
