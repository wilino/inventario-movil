import 'package:drift/drift.dart';
import '../../../../core/config/database.dart';
import '../../domain/entities/transfer.dart' as domain;

/// Data source local para el manejo de transferencias con Drift
class TransferLocalDataSource {
  final AppDatabase db;

  TransferLocalDataSource(this.db);

  /// Obtiene todas las transferencias de una tienda (enviadas y recibidas)
  Future<List<domain.Transfer>> getStoreTransfers(String storeId) async {
    final transfers =
        await (db.select(db.transfers)
              ..where(
                (t) =>
                    t.fromStoreId.equals(storeId) | t.toStoreId.equals(storeId),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return transfers.map((t) => _mapToEntity(t)).toList();
  }

  /// Obtiene transferencias enviadas desde una tienda
  Future<List<domain.Transfer>> getOutgoingTransfers(String storeId) async {
    final transfers =
        await (db.select(db.transfers)
              ..where((t) => t.fromStoreId.equals(storeId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return transfers.map((t) => _mapToEntity(t)).toList();
  }

  /// Obtiene transferencias recibidas por una tienda
  Future<List<domain.Transfer>> getIncomingTransfers(String storeId) async {
    final transfers =
        await (db.select(db.transfers)
              ..where((t) => t.toStoreId.equals(storeId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return transfers.map((t) => _mapToEntity(t)).toList();
  }

  /// Obtiene transferencias pendientes de una tienda
  Future<List<domain.Transfer>> getPendingTransfers(String storeId) async {
    final transfers =
        await (db.select(db.transfers)
              ..where(
                (t) =>
                    (t.fromStoreId.equals(storeId) |
                        t.toStoreId.equals(storeId)) &
                    t.status.equals('pending'),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return transfers.map((t) => _mapToEntity(t)).toList();
  }

  /// Obtiene transferencias en tránsito de una tienda
  Future<List<domain.Transfer>> getInTransitTransfers(String storeId) async {
    final transfers =
        await (db.select(db.transfers)
              ..where(
                (t) =>
                    (t.fromStoreId.equals(storeId) |
                        t.toStoreId.equals(storeId)) &
                    t.status.equals('in_transit'),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();

    return transfers.map((t) => _mapToEntity(t)).toList();
  }

  /// Obtiene una transferencia por ID
  Future<domain.Transfer?> getTransferById(String id) async {
    final transfer = await (db.select(
      db.transfers,
    )..where((t) => t.id.equals(id))).getSingleOrNull();

    return transfer != null ? _mapToEntity(transfer) : null;
  }

  /// Crea una nueva transferencia (estado: pending)
  Future<domain.Transfer> createTransfer(domain.Transfer transfer) async {
    await db
        .into(db.transfers)
        .insert(
          TransfersCompanion.insert(
            id: transfer.id,
            fromStoreId: transfer.fromStoreId,
            fromStoreName: transfer.fromStoreName,
            toStoreId: transfer.toStoreId,
            toStoreName: transfer.toStoreName,
            productId: transfer.productId,
            variantId: Value(transfer.variantId),
            productName: transfer.productName,
            qty: transfer.qty,
            status: domain.Transfer.statusToString(transfer.status),
            authorUserId: transfer.authorUserId,
            notes: Value(transfer.notes),
            requestedAt: transfer.requestedAt,
            sentAt: Value(transfer.sentAt),
            receivedAt: Value(transfer.receivedAt),
            cancelledAt: Value(transfer.cancelledAt),
            cancellationReason: Value(transfer.cancellationReason),
            createdAt: transfer.createdAt,
            updatedAt: transfer.updatedAt,
          ),
        );

    return transfer;
  }

  /// Marca una transferencia como enviada (pending -> in_transit)
  /// Decrementa inventario de origen
  Future<domain.Transfer> sendTransfer(String id) async {
    final transfer = await getTransferById(id);
    if (transfer == null) throw Exception('Transferencia no encontrada');

    if (!transfer.canBeSent) {
      throw Exception('La transferencia no puede ser enviada');
    }

    await db.transaction(() async {
      // Actualizar estado de la transferencia
      await (db.update(db.transfers)..where((t) => t.id.equals(id))).write(
        TransfersCompanion(
          status: const Value('in_transit'),
          sentAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Decrementar inventario de origen
      await _updateInventory(
        transfer.fromStoreId,
        transfer.productId,
        transfer.variantId,
        -transfer.qty, // Negativo para decrementar
      );
    });

    return (await getTransferById(id))!;
  }

  /// Marca una transferencia como recibida (in_transit -> completed)
  /// Incrementa inventario de destino
  Future<domain.Transfer> receiveTransfer(String id) async {
    final transfer = await getTransferById(id);
    if (transfer == null) throw Exception('Transferencia no encontrada');

    if (!transfer.canBeReceived) {
      throw Exception('La transferencia no puede ser recibida');
    }

    await db.transaction(() async {
      // Actualizar estado de la transferencia
      await (db.update(db.transfers)..where((t) => t.id.equals(id))).write(
        TransfersCompanion(
          status: const Value('completed'),
          receivedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Incrementar inventario de destino
      await _updateInventory(
        transfer.toStoreId,
        transfer.productId,
        transfer.variantId,
        transfer.qty, // Positivo para incrementar
      );
    });

    return (await getTransferById(id))!;
  }

  /// Cancela una transferencia
  /// Si estaba en tránsito, revierte el inventario de origen
  Future<domain.Transfer> cancelTransfer(String id, String reason) async {
    final transfer = await getTransferById(id);
    if (transfer == null) throw Exception('Transferencia no encontrada');

    if (!transfer.canBeCancelled) {
      throw Exception('La transferencia no puede ser cancelada');
    }

    await db.transaction(() async {
      // Actualizar estado de la transferencia
      await (db.update(db.transfers)..where((t) => t.id.equals(id))).write(
        TransfersCompanion(
          status: const Value('cancelled'),
          cancelledAt: Value(DateTime.now()),
          cancellationReason: Value(reason),
          updatedAt: Value(DateTime.now()),
        ),
      );

      // Si estaba en tránsito, revertir el inventario de origen
      if (transfer.isInTransit) {
        await _updateInventory(
          transfer.fromStoreId,
          transfer.productId,
          transfer.variantId,
          transfer.qty, // Positivo para revertir
        );
      }
    });

    return (await getTransferById(id))!;
  }

  /// Obtiene estadísticas de transferencias
  Future<Map<String, dynamic>> getTransfersStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start =
        startDate ?? DateTime.now().subtract(const Duration(days: 30));
    final end = endDate ?? DateTime.now();

    // Obtener todas las transferencias del periodo
    final outgoing =
        await (db.select(db.transfers)..where(
              (t) =>
                  t.fromStoreId.equals(storeId) &
                  t.createdAt.isBiggerOrEqualValue(start) &
                  t.createdAt.isSmallerOrEqualValue(end),
            ))
            .get();

    final incoming =
        await (db.select(db.transfers)..where(
              (t) =>
                  t.toStoreId.equals(storeId) &
                  t.createdAt.isBiggerOrEqualValue(start) &
                  t.createdAt.isSmallerOrEqualValue(end),
            ))
            .get();

    // Contar por estado
    final pendingCount =
        await (db.select(db.transfers)..where(
              (t) =>
                  (t.fromStoreId.equals(storeId) |
                      t.toStoreId.equals(storeId)) &
                  t.status.equals('pending'),
            ))
            .get()
            .then((list) => list.length);

    final inTransitCount =
        await (db.select(db.transfers)..where(
              (t) =>
                  (t.fromStoreId.equals(storeId) |
                      t.toStoreId.equals(storeId)) &
                  t.status.equals('in_transit'),
            ))
            .get()
            .then((list) => list.length);

    final completedCount =
        await (db.select(db.transfers)..where(
              (t) =>
                  (t.fromStoreId.equals(storeId) |
                      t.toStoreId.equals(storeId)) &
                  t.status.equals('completed'),
            ))
            .get()
            .then((list) => list.length);

    return {
      'totalOutgoing': outgoing.length,
      'totalIncoming': incoming.length,
      'pending': pendingCount,
      'inTransit': inTransitCount,
      'completed': completedCount,
    };
  }

  /// Actualiza el inventario después de una transferencia
  Future<void> _updateInventory(
    String storeId,
    String productId,
    String? variantId,
    double qtyChange,
  ) async {
    final inventory =
        await (db.select(db.inventory)..where(
              (t) => t.storeId.equals(storeId) & t.productId.equals(productId),
            ))
            .getSingleOrNull();

    if (inventory != null) {
      final newQty = inventory.stockQty + qtyChange;
      await (db.update(
        db.inventory,
      )..where((t) => t.id.equals(inventory.id))).write(
        InventoryCompanion(
          stockQty: Value(newQty),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Mapea de Drift a Entity
  domain.Transfer _mapToEntity(Transfer data) {
    return domain.Transfer(
      id: data.id,
      fromStoreId: data.fromStoreId,
      fromStoreName: data.fromStoreName,
      toStoreId: data.toStoreId,
      toStoreName: data.toStoreName,
      productId: data.productId,
      variantId: data.variantId,
      productName: data.productName,
      qty: data.qty,
      status: domain.Transfer.statusFromString(data.status),
      authorUserId: data.authorUserId,
      notes: data.notes,
      requestedAt: data.requestedAt,
      sentAt: data.sentAt,
      receivedAt: data.receivedAt,
      cancelledAt: data.cancelledAt,
      cancellationReason: data.cancellationReason,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
