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

    try {
      // Pull productos (todos, sin filtro de fecha para forzar sincronización completa)
      final products = await remote.from('products').select() as List;
      print('📦 Descargando ${products.length} productos de Supabase...');

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

      // Pull variantes
      final variants = await remote.from('product_variants').select() as List;
      print('🎨 Descargando ${variants.length} variantes...');

      for (final variant in variants) {
        await db
            .into(db.productVariants)
            .insertOnConflictUpdate(
              ProductVariantsCompanion.insert(
                id: variant['id'],
                productId: variant['product_id'],
                attrs: jsonEncode(variant['attrs']),
                sku: Value(variant['sku']),
                createdAt: DateTime.parse(variant['created_at']),
                updatedAt: DateTime.parse(variant['updated_at']),
              ),
            );
      }

      // Pull proveedores
      final suppliers = await remote.from('suppliers').select() as List;
      print('🏢 Descargando ${suppliers.length} proveedores...');

      for (final supplier in suppliers) {
        await db
            .into(db.suppliers)
            .insertOnConflictUpdate(
              SuppliersCompanion.insert(
                id: supplier['id'],
                name: supplier['name'],
                contactName: Value(supplier['contact_name']),
                email: Value(supplier['email']),
                phone: Value(supplier['phone']),
                address: Value(supplier['address']),
                notes: Value(null),
                isActive: Value(supplier['is_active'] ?? true),
                createdAt: DateTime.parse(supplier['created_at']),
                updatedAt: DateTime.parse(supplier['updated_at']),
              ),
            );
      }

      // Pull inventario
      final inventory = await remote.from('inventory').select() as List;
      print('📊 Descargando ${inventory.length} registros de inventario...');

      for (final item in inventory) {
        await db
            .into(db.inventory)
            .insertOnConflictUpdate(
              InventoryCompanion.insert(
                id: item['id'],
                storeId: item['store_id'],
                productId: item['product_id'],
                variantId: Value(item['variant_id']),
                stockQty: (item['stock_qty'] as num).toDouble(),
                minQty: Value((item['min_qty'] as num?)?.toDouble() ?? 0.0),
                maxQty: Value((item['max_qty'] as num?)?.toDouble() ?? 0.0),
                updatedAt: DateTime.parse(item['updated_at']),
              ),
            );
      }

      // Pull ventas
      final sales = await remote.from('sales').select() as List;
      print('💰 Descargando ${sales.length} ventas...');

      for (final sale in sales) {
        await db
            .into(db.sales)
            .insertOnConflictUpdate(
              SalesCompanion.insert(
                id: sale['id'],
                storeId: sale['store_id'],
                authorUserId: Value(sale['author_user_id']),
                subtotal: (sale['subtotal'] as num).toDouble(),
                discount: Value((sale['discount'] as num?)?.toDouble() ?? 0.0),
                tax: Value((sale['tax'] as num?)?.toDouble() ?? 0.0),
                total: (sale['total'] as num).toDouble(),
                customer: Value(sale['customer']),
                notes: Value(sale['notes']),
                at: DateTime.parse(sale['at']),
                createdAt: DateTime.parse(sale['created_at']),
                updatedAt: DateTime.parse(sale['updated_at']),
                isDeleted: Value(sale['is_deleted'] ?? false),
              ),
            );
      }

      // Pull items de ventas
      final saleItems = await remote.from('sale_items').select() as List;
      print('📄 Descargando ${saleItems.length} items de ventas...');

      for (final item in saleItems) {
        await db
            .into(db.saleItems)
            .insertOnConflictUpdate(
              SaleItemsCompanion.insert(
                id: item['id'],
                saleId: item['sale_id'],
                productId: item['product_id'],
                variantId: Value(item['variant_id']),
                productName: item['product_name'],
                qty: (item['qty'] as num).toDouble(),
                unitPrice: (item['unit_price'] as num).toDouble(),
                total: (item['total'] as num).toDouble(),
              ),
            );
      }

      // Pull compras
      final purchases = await remote.from('purchases').select() as List;
      print('🛒 Descargando ${purchases.length} compras...');

      for (final purchase in purchases) {
        await db
            .into(db.purchases)
            .insertOnConflictUpdate(
              PurchasesCompanion.insert(
                id: purchase['id'],
                storeId: purchase['store_id'],
                supplierId: Value(purchase['supplier_id']),
                supplierName: purchase['supplier_name'],
                authorUserId: Value(purchase['author_user_id']),
                subtotal: (purchase['subtotal'] as num).toDouble(),
                discount: Value(
                  (purchase['discount'] as num?)?.toDouble() ?? 0.0,
                ),
                tax: Value((purchase['tax'] as num?)?.toDouble() ?? 0.0),
                total: (purchase['total'] as num).toDouble(),
                invoiceNumber: Value(purchase['invoice_number']),
                notes: Value(purchase['notes']),
                at: DateTime.parse(purchase['at']),
                createdAt: DateTime.parse(purchase['created_at']),
                updatedAt: DateTime.parse(purchase['updated_at']),
                isDeleted: Value(purchase['is_deleted'] ?? false),
              ),
            );
      }

      // Pull items de compras
      final purchaseItems =
          await remote.from('purchase_items').select() as List;
      print('📦 Descargando ${purchaseItems.length} items de compras...');

      for (final item in purchaseItems) {
        await db
            .into(db.purchaseItems)
            .insertOnConflictUpdate(
              PurchaseItemsCompanion.insert(
                id: item['id'],
                purchaseId: item['purchase_id'],
                productId: item['product_id'],
                variantId: Value(item['variant_id']),
                productName: item['product_name'],
                qty: (item['qty'] as num).toDouble(),
                unitCost: (item['unit_price'] as num).toDouble(),
                total: (item['subtotal'] as num).toDouble(),
              ),
            );
      }

      // Pull transferencias con JOIN para obtener nombres de tiendas
      final transfers =
          await remote.from('transfers').select('''
            *,
            from_store:stores!from_store_id(name),
            to_store:stores!to_store_id(name)
          ''')
              as List;
      print('🔄 Descargando ${transfers.length} transferencias...');

      for (final transfer in transfers) {
        // Extraer nombres de tiendas del JOIN
        final fromStoreName = transfer['from_store'] != null
            ? (transfer['from_store'] as Map)['name'] ?? 'Desconocida'
            : 'Desconocida';
        final toStoreName = transfer['to_store'] != null
            ? (transfer['to_store'] as Map)['name'] ?? 'Desconocida'
            : 'Desconocida';

        await db
            .into(db.transfers)
            .insertOnConflictUpdate(
              TransfersCompanion.insert(
                id: transfer['id'],
                fromStoreId: transfer['from_store_id'],
                fromStoreName: fromStoreName,
                toStoreId: transfer['to_store_id'],
                toStoreName: toStoreName,
                productId: transfer['product_id'],
                variantId: Value(transfer['variant_id']),
                productName: transfer['product_name'],
                qty: (transfer['qty'] as num).toDouble(),
                status: transfer['status'],
                authorUserId: transfer['requested_by'] ?? '',
                notes: Value(transfer['notes']),
                requestedAt: DateTime.parse(transfer['requested_at']),
                sentAt: transfer['sent_at'] != null
                    ? Value(DateTime.parse(transfer['sent_at']))
                    : const Value(null),
                receivedAt: transfer['received_at'] != null
                    ? Value(DateTime.parse(transfer['received_at']))
                    : const Value(null),
                // Campos de cancelación (migración necesaria en Supabase)
                cancelledAt:
                    transfer.containsKey('cancelled_at') &&
                        transfer['cancelled_at'] != null
                    ? Value(DateTime.parse(transfer['cancelled_at']))
                    : const Value(null),
                cancellationReason: transfer.containsKey('cancellation_reason')
                    ? Value(transfer['cancellation_reason'])
                    : const Value(null),
                createdAt: DateTime.parse(transfer['created_at']),
                updatedAt: DateTime.parse(transfer['updated_at']),
              ),
            );
      }

      print(
        '✅ Sincronización completa: ${products.length} productos, ${sales.length} ventas, ${purchases.length} compras, ${transfers.length} transferencias',
      );
    } catch (e, stackTrace) {
      print('❌ Error al obtener cambios remotos: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Fuerza una sincronización inmediata
  Future<void> forceSyncNow() async {
    await syncPendingOps();
  }
}
