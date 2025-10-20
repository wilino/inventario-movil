import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:drift/drift.dart';
import '../config/database.dart';
import '../config/supabase_config.dart';
import 'connectivity_service.dart';

/// Servicio de sincronización entre base de datos local y Supabase
class SyncService {
  final AppDatabase db;
  final ConnectivityService connectivityService;
  final SupabaseClient remote = SupabaseConfig.client;

  DateTime? _lastSyncAt;

  SyncService({required this.db, required this.connectivityService});

  /// Sincroniza operaciones pendientes con el servidor
  Future<void> syncPendingOps() async {
    if (!connectivityService.isOnline) {
      print('⚠️ No hay conexión. Sincronización omitida.');
      return;
    }

    print('🔄 Iniciando sincronización de operaciones pendientes...');

    try {
      // Obtener operaciones pendientes (máximo 50 por lote)
      final pendingOperations =
          await (db.select(db.pendingOps)
                ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
                ..limit(50))
              .get();

      if (pendingOperations.isEmpty) {
        print('✅ No hay operaciones pendientes');
      }

      for (final op in pendingOperations) {
        try {
          await _applyRemote(op);

          // Eliminar operación exitosa
          await (db.delete(
            db.pendingOps,
          )..where((t) => t.id.equals(op.id))).go();

          print('✅ Operación ${op.entity}:${op.op} aplicada exitosamente');
        } catch (e) {
          print('❌ Error en operación ${op.entity}:${op.op}: $e');

          // Marcar error y aumentar contador de reintentos
          await (db.update(
            db.pendingOps,
          )..where((t) => t.id.equals(op.id))).write(
            PendingOpsCompanion(
              retryCount: Value(op.retryCount + 1),
              lastError: Value(e.toString()),
            ),
          );
        }
      }

      // Pull de cambios remotos
      await _pullRemoteChanges();

      _lastSyncAt = DateTime.now();
      print('✅ Sincronización completada');
    } catch (e) {
      print('❌ Error en sincronización: $e');
    }
  }

  /// Aplica una operación en el servidor remoto
  Future<void> _applyRemote(PendingOp op) async {
    final payload = jsonDecode(op.payload) as Map<String, dynamic>;

    switch (op.entity) {
      case 'sales':
        await _applySaleOp(op.op, payload);
        break;
      case 'purchases':
        await _applyPurchaseOp(op.op, payload);
        break;
      case 'transfers':
        await _applyTransferOp(op.op, payload);
        break;
      case 'inventory':
        await _applyInventoryOp(op.op, payload);
        break;
      case 'products':
        await _applyProductOp(op.op, payload);
        break;
      default:
        throw Exception('Entidad desconocida: ${op.entity}');
    }
  }

  Future<void> _applySaleOp(String op, Map<String, dynamic> payload) async {
    switch (op) {
      case 'insert':
        await remote.from('sales').insert(payload);
        break;
      case 'update':
        await remote.from('sales').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await remote.from('sales').delete().eq('id', payload['id']);
        break;
    }
  }

  Future<void> _applyPurchaseOp(String op, Map<String, dynamic> payload) async {
    switch (op) {
      case 'insert':
        await remote.from('purchases').insert(payload);
        break;
      case 'update':
        await remote.from('purchases').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await remote.from('purchases').delete().eq('id', payload['id']);
        break;
    }
  }

  Future<void> _applyTransferOp(String op, Map<String, dynamic> payload) async {
    switch (op) {
      case 'insert':
      case 'rpc':
        // Usar RPC para transferencias (transacción atómica)
        await remote.rpc('perform_transfer', params: payload);
        break;
      case 'update':
        await remote.from('transfers').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await remote.from('transfers').delete().eq('id', payload['id']);
        break;
    }
  }

  Future<void> _applyInventoryOp(
    String op,
    Map<String, dynamic> payload,
  ) async {
    switch (op) {
      case 'insert':
        await remote.from('inventory').insert(payload);
        break;
      case 'update':
        await remote.from('inventory').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        await remote.from('inventory').delete().eq('id', payload['id']);
        break;
    }
  }

  Future<void> _applyProductOp(String op, Map<String, dynamic> payload) async {
    switch (op) {
      case 'insert':
        await remote.from('products').insert(payload);
        break;
      case 'update':
        await remote.from('products').update(payload).eq('id', payload['id']);
        break;
      case 'delete':
        // Soft delete
        await remote
            .from('products')
            .update({'is_deleted': true})
            .eq('id', payload['id']);
        break;
    }
  }

  /// Obtiene cambios remotos desde la última sincronización
  Future<void> _pullRemoteChanges() async {
    print('📥 Obteniendo cambios remotos...');

    final lastSync =
        _lastSyncAt ?? DateTime.now().subtract(const Duration(days: 30));

    try {
      // Pull productos
      final products =
          await remote
                  .from('products')
                  .select()
                  .gte('updated_at', lastSync.toIso8601String())
              as List;

      for (final product in products) {
        await db
            .into(db.products)
            .insertOnConflictUpdate(
              ProductsCompanion.insert(
                id: product['id'] as String,
                sku: product['sku'] as String,
                name: product['name'] as String,
                description: Value(product['description'] as String?),
                category: product['category'] as String,
                costPrice: (product['cost_price'] as num).toDouble(),
                salePrice: (product['sale_price'] as num).toDouble(),
                unit: product['unit'] as String,
                hasVariants: Value(product['has_variants'] as bool? ?? false),
                isActive: Value(product['is_active'] as bool? ?? true),
                createdAt: DateTime.parse(product['created_at'] as String),
                updatedAt: DateTime.parse(product['updated_at'] as String),
                deletedAt: Value(
                  product['deleted_at'] != null
                      ? DateTime.parse(product['deleted_at'] as String)
                      : null,
                ),
              ),
            );
      }

      // Pull inventario
      final inventory =
          await remote
                  .from('inventory')
                  .select()
                  .gte('updated_at', lastSync.toIso8601String())
              as List;

      for (final item in inventory) {
        await db
            .into(db.inventory)
            .insertOnConflictUpdate(
              InventoryCompanion.insert(
                id: item['id'],
                storeId: item['store_id'],
                productId: item['product_id'],
                variantId: Value(item['variant_id']),
                stockQty: item['stock_qty'],
                minQty: Value(item['min_qty']),
                maxQty: Value(item['max_qty']),
                updatedAt: DateTime.parse(item['updated_at']),
              ),
            );
      }

      print('✅ Cambios remotos aplicados');
    } catch (e) {
      print('❌ Error al obtener cambios remotos: $e');
    }
  }

  /// Fuerza una sincronización inmediata
  Future<void> forceSyncNow() async {
    await syncPendingOps();
  }
}
