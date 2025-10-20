import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/transfer.dart' as domain;

/// Data source remoto para transferencias con Supabase
class TransferRemoteDataSource {
  final SupabaseClient supabase;

  TransferRemoteDataSource(this.supabase);

  /// Obtiene todas las transferencias de una tienda desde Supabase
  Future<List<domain.Transfer>> getStoreTransfers(String storeId) async {
    final response = await supabase
        .from('transfers')
        .select()
        .or('from_store_id.eq.$storeId,to_store_id.eq.$storeId')
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene transferencias enviadas desde una tienda
  Future<List<domain.Transfer>> getOutgoingTransfers(String storeId) async {
    final response = await supabase
        .from('transfers')
        .select()
        .eq('from_store_id', storeId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene transferencias recibidas por una tienda
  Future<List<domain.Transfer>> getIncomingTransfers(String storeId) async {
    final response = await supabase
        .from('transfers')
        .select()
        .eq('to_store_id', storeId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Obtiene una transferencia por ID
  Future<domain.Transfer?> getTransferById(String id) async {
    final response =
        await supabase.from('transfers').select().eq('id', id).maybeSingle();

    return response != null ? _mapToEntity(response) : null;
  }

  /// Crea una nueva transferencia en Supabase
  Future<domain.Transfer> createTransfer(domain.Transfer transfer) async {
    final data = _mapToJson(transfer);
    await supabase.from('transfers').insert(data);
    return transfer;
  }

  /// Actualiza una transferencia en Supabase
  Future<domain.Transfer> updateTransfer(domain.Transfer transfer) async {
    final data = _mapToJson(transfer);
    await supabase.from('transfers').update(data).eq('id', transfer.id);
    return transfer;
  }

  /// Sincroniza transferencias desde una fecha
  Future<List<domain.Transfer>> syncTransfersSince(
    String storeId,
    DateTime since,
  ) async {
    final response = await supabase
        .from('transfers')
        .select()
        .or('from_store_id.eq.$storeId,to_store_id.eq.$storeId')
        .gte('updated_at', since.toIso8601String())
        .order('updated_at', ascending: false);

    return (response as List).map((json) => _mapToEntity(json)).toList();
  }

  /// Mapea de JSON a Entity
  domain.Transfer _mapToEntity(Map<String, dynamic> json) {
    return domain.Transfer(
      id: json['id'] as String,
      fromStoreId: json['from_store_id'] as String,
      fromStoreName: json['from_store_name'] as String,
      toStoreId: json['to_store_id'] as String,
      toStoreName: json['to_store_name'] as String,
      productId: json['product_id'] as String,
      variantId: json['variant_id'] as String?,
      productName: json['product_name'] as String,
      qty: (json['qty'] as num).toDouble(),
      status: domain.Transfer.statusFromString(json['status'] as String),
      authorUserId: json['author_user_id'] as String,
      notes: json['notes'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Mapea de Entity a JSON
  Map<String, dynamic> _mapToJson(domain.Transfer transfer) {
    return {
      'id': transfer.id,
      'from_store_id': transfer.fromStoreId,
      'from_store_name': transfer.fromStoreName,
      'to_store_id': transfer.toStoreId,
      'to_store_name': transfer.toStoreName,
      'product_id': transfer.productId,
      'variant_id': transfer.variantId,
      'product_name': transfer.productName,
      'qty': transfer.qty,
      'status': domain.Transfer.statusToString(transfer.status),
      'author_user_id': transfer.authorUserId,
      'notes': transfer.notes,
      'requested_at': transfer.requestedAt.toIso8601String(),
      'sent_at': transfer.sentAt?.toIso8601String(),
      'received_at': transfer.receivedAt?.toIso8601String(),
      'cancelled_at': transfer.cancelledAt?.toIso8601String(),
      'cancellation_reason': transfer.cancellationReason,
      'created_at': transfer.createdAt.toIso8601String(),
      'updated_at': transfer.updatedAt.toIso8601String(),
    };
  }
}
