import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/sale.dart' as domain;

/// Data source remoto para sincronizar ventas con Supabase
class SaleRemoteDataSource {
  final SupabaseClient supabase;

  SaleRemoteDataSource(this.supabase);

  /// Obtiene todas las ventas de una tienda desde Supabase
  Future<List<domain.Sale>> getStoreSales(String storeId) async {
    final response = await supabase
        .from('sales')
        .select('*, sale_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene ventas por rango de fechas
  Future<List<domain.Sale>> getSalesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await supabase
        .from('sales')
        .select('*, sale_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .gte('at', startDate.toIso8601String())
        .lte('at', endDate.toIso8601String())
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene una venta específica por ID
  Future<domain.Sale?> getSaleById(String id) async {
    final response = await supabase
        .from('sales')
        .select('*, sale_items(*)')
        .eq('id', id)
        .maybeSingle();

    return response != null ? _mapToEntity(response) : null;
  }

  /// Busca ventas por cliente
  Future<List<domain.Sale>> searchSalesByCustomer(
    String storeId,
    String query,
  ) async {
    final response = await supabase
        .from('sales')
        .select('*, sale_items(*)')
        .eq('store_id', storeId)
        .eq('is_deleted', false)
        .ilike('customer', '%$query%')
        .order('at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Crea una nueva venta en Supabase
  Future<domain.Sale> createSale(domain.Sale sale) async {
    // Insertar el encabezado de la venta
    await supabase.from('sales').insert({
      'id': sale.id,
      'store_id': sale.storeId,
      'author_user_id': sale.authorUserId,
      'subtotal': sale.subtotal,
      'discount': sale.discount,
      'tax': sale.tax,
      'total': sale.total,
      'customer': sale.customer,
      'notes': sale.notes,
      'at': sale.at.toIso8601String(),
      'created_at': sale.createdAt.toIso8601String(),
      'updated_at': sale.updatedAt.toIso8601String(),
      'is_deleted': sale.isDeleted,
    });

    // Insertar los items de la venta
    final itemsData = sale.items
        .map(
          (item) => {
            'id': '${sale.id}_${item.productId}',
            'sale_id': sale.id,
            'product_id': item.productId,
            'variant_id': item.variantId,
            'product_name': item.productName,
            'qty': item.qty,
            'unit_price': item.unitPrice,
            'total': item.total,
          },
        )
        .toList();

    if (itemsData.isNotEmpty) {
      await supabase.from('sale_items').insert(itemsData);
    }

    return sale;
  }

  /// Cancela una venta (soft delete) en Supabase
  Future<void> cancelSale(String id) async {
    await supabase
        .from('sales')
        .update({
          'is_deleted': true,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  /// Obtiene las ventas del día actual
  Future<List<domain.Sale>> getTodaySales(String storeId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getSalesByDateRange(storeId, startOfDay, endOfDay);
  }

  /// Mapea de JSON a Entity
  domain.Sale _mapToEntity(Map<String, dynamic> json) {
    final itemsJson = json['sale_items'] as List? ?? [];
    final items = itemsJson
        .map((itemJson) => _mapItemToEntity(itemJson))
        .toList();

    return domain.Sale(
      id: json['id'],
      storeId: json['store_id'],
      authorUserId: json['author_user_id'],
      items: items,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      customer: json['customer'],
      notes: json['notes'],
      at: DateTime.parse(json['at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  /// Mapea de JSON a SaleItem
  domain.SaleItem _mapItemToEntity(Map<String, dynamic> json) {
    return domain.SaleItem(
      productId: json['product_id'],
      variantId: json['variant_id'],
      productName: json['product_name'],
      qty: (json['qty'] as num).toDouble(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }
}
