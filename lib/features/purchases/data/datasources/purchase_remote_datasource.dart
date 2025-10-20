import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/purchase.dart' as domain;
import '../../domain/entities/supplier.dart' show Supplier;

/// Data source remoto para el manejo de compras con Supabase
class PurchaseRemoteDataSource {
  final SupabaseClient client;

  PurchaseRemoteDataSource(this.client);

  /// Obtiene todas las compras de una tienda desde Supabase
  Future<List<domain.Purchase>> getStorePurchases(String storeId) async {
    final response = await client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene compras por rango de fechas desde Supabase
  Future<List<domain.Purchase>> getPurchasesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .gte('at', startDate.toIso8601String())
        .lte('at', endDate.toIso8601String())
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene una compra específica por ID desde Supabase
  Future<domain.Purchase?> getPurchaseById(String id) async {
    final response = await client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('id', id)
        .maybeSingle();

    return response != null ? _mapToEntity(response) : null;
  }

  /// Busca compras por proveedor en Supabase
  Future<List<domain.Purchase>> searchPurchasesBySupplier(
    String storeId,
    String supplierId,
  ) async {
    final response = await client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .eq('supplier_id', supplierId)
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Busca compras por número de factura en Supabase
  Future<List<domain.Purchase>> searchPurchasesByInvoice(
    String storeId,
    String query,
  ) async {
    final response = await client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .ilike('invoice_number', '%$query%')
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Sube una compra a Supabase
  Future<void> uploadPurchase(domain.Purchase purchase) async {
    // Insertar el encabezado
    await client.from('purchases').upsert({
      'id': purchase.id,
      'store_id': purchase.storeId,
      'supplier_id': purchase.supplierId,
      'supplier_name': purchase.supplierName,
      'author_user_id': purchase.authorUserId,
      'subtotal': purchase.subtotal,
      'discount': purchase.discount,
      'tax': purchase.tax,
      'total': purchase.total,
      'invoice_number': purchase.invoiceNumber,
      'notes': purchase.notes,
      'at': purchase.at.toIso8601String(),
      'created_at': purchase.createdAt.toIso8601String(),
      'updated_at': purchase.updatedAt.toIso8601String(),
      'is_deleted': purchase.isDeleted,
    });

    // Insertar los items
    for (final item in purchase.items) {
      await client.from('purchase_items').upsert({
        'id': '${purchase.id}_${item.productId}',
        'purchase_id': purchase.id,
        'product_id': item.productId,
        'variant_id': item.variantId,
        'product_name': item.productName,
        'qty': item.qty,
        'unit_cost': item.unitCost,
        'total': item.total,
      });
    }
  }

  /// Cancela una compra en Supabase (soft delete)
  Future<void> cancelPurchase(String id) async {
    await client
        .from('purchases')
        .update({
          'is_deleted': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Obtiene todas las compras de una tienda (incluyendo eliminadas)
  Future<List<domain.Purchase>> getAllStorePurchases(String storeId) async {
    final response = await client
        .from('purchases')
        .select('*, purchase_items(*)')
        .eq('store_id', storeId)
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene proveedores activos desde Supabase
  Future<List<Supplier>> getActiveSuppliers() async {
    final response = await client
        .from('suppliers')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => _mapSupplierToEntity(json))
        .toList();
  }

  /// Sube un proveedor a Supabase
  Future<void> uploadSupplier(Supplier supplier) async {
    await client.from('suppliers').upsert({
      'id': supplier.id,
      'name': supplier.name,
      'contact_name': supplier.contactName,
      'email': supplier.email,
      'phone': supplier.phone,
      'address': supplier.address,
      'notes': supplier.notes,
      'is_active': supplier.isActive,
      'created_at': supplier.createdAt.toIso8601String(),
      'updated_at': supplier.updatedAt.toIso8601String(),
    });
  }

  /// Mapea de JSON a Entity (Purchase)
  domain.Purchase _mapToEntity(Map<String, dynamic> json) {
    final items =
        (json['purchase_items'] as List?)
            ?.map(
              (itemJson) => domain.PurchaseItem(
                productId: itemJson['product_id'],
                variantId: itemJson['variant_id'],
                productName: itemJson['product_name'],
                qty: (itemJson['qty'] as num).toDouble(),
                unitCost: (itemJson['unit_cost'] as num).toDouble(),
                total: (itemJson['total'] as num).toDouble(),
              ),
            )
            .toList() ??
        [];

    return domain.Purchase(
      id: json['id'],
      storeId: json['store_id'],
      supplierId: json['supplier_id'],
      supplierName: json['supplier_name'],
      authorUserId: json['author_user_id'],
      items: items,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      invoiceNumber: json['invoice_number'],
      notes: json['notes'],
      at: DateTime.parse(json['at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  /// Mapea de JSON a Entity (Supplier)
  Supplier _mapSupplierToEntity(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactName: json['contact_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      notes: json['notes'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
