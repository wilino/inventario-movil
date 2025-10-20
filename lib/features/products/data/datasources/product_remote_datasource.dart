import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product.dart' as domain;

/// Data source remoto para productos usando Supabase
class ProductRemoteDataSource {
  final SupabaseClient client;

  ProductRemoteDataSource(this.client);

  /// Obtener todos los productos
  Future<List<domain.Product>> getAllProducts() async {
    try {
      final response = await client
          .from('products')
          .select()
          .isFilter('deleted_at', null)
          .order('name');

      return (response as List)
          .map((json) => _mapFromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  /// Obtener productos activos
  Future<List<domain.Product>> getActiveProducts() async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('is_active', true)
          .isFilter('deleted_at', null)
          .order('name');

      return (response as List)
          .map((json) => _mapFromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos activos: $e');
    }
  }

  /// Obtener producto por ID
  Future<domain.Product?> getProductById(int id) async {
    try {
      final response = await client
          .from('products')
          .select()
          .eq('id', id)
          .isFilter('deleted_at', null)
          .maybeSingle();

      return response != null ? _mapFromJson(response) : null;
    } catch (e) {
      throw Exception('Error al obtener producto: $e');
    }
  }

  /// Crear producto
  Future<domain.Product> createProduct(domain.Product product) async {
    try {
      final response = await client
          .from('products')
          .insert(_mapToJson(product))
          .select()
          .single();

      return _mapFromJson(response);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  /// Actualizar producto
  Future<domain.Product> updateProduct(domain.Product product) async {
    try {
      final response = await client
          .from('products')
          .update(_mapToJson(product))
          .eq('id', product.id!)
          .select()
          .single();

      return _mapFromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  /// Eliminar producto
  Future<void> deleteProduct(int id) async {
    try {
      await client
          .from('products')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  /// Mapear de JSON a entidad
  domain.Product _mapFromJson(Map<String, dynamic> json) {
    return domain.Product(
      id: json['id'] as int,
      sku: json['sku'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      costPrice: (json['cost_price'] as num).toDouble(),
      salePrice: (json['sale_price'] as num).toDouble(),
      unit: json['unit'] as String,
      hasVariants: json['has_variants'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Mapear de entidad a JSON
  Map<String, dynamic> _mapToJson(domain.Product product) {
    return {
      if (product.id != null) 'id': product.id,
      'sku': product.sku,
      'name': product.name,
      'description': product.description,
      'category': product.category,
      'cost_price': product.costPrice,
      'sale_price': product.salePrice,
      'unit': product.unit,
      'has_variants': product.hasVariants,
      'is_active': product.isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
