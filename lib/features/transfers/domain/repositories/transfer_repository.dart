import '../../../../core/utils/result.dart';
import '../entities/transfer.dart';

/// Repositorio de transferencias
abstract class TransferRepository {
  /// Obtiene todas las transferencias de una tienda (enviadas y recibidas)
  Future<Result<List<Transfer>>> getStoreTransfers(String storeId);

  /// Obtiene transferencias enviadas desde una tienda
  Future<Result<List<Transfer>>> getOutgoingTransfers(String storeId);

  /// Obtiene transferencias recibidas por una tienda
  Future<Result<List<Transfer>>> getIncomingTransfers(String storeId);

  /// Obtiene transferencias pendientes de una tienda
  Future<Result<List<Transfer>>> getPendingTransfers(String storeId);

  /// Obtiene transferencias en tránsito de una tienda
  Future<Result<List<Transfer>>> getInTransitTransfers(String storeId);

  /// Obtiene una transferencia por ID
  Future<Result<Transfer>> getTransferById(String id);

  /// Crea una nueva transferencia (estado: pending)
  Future<Result<Transfer>> createTransfer(Transfer transfer);

  /// Marca una transferencia como enviada (pending -> in_transit)
  /// Decrementa inventario de origen
  Future<Result<Transfer>> sendTransfer(String id);

  /// Marca una transferencia como recibida (in_transit -> completed)
  /// Incrementa inventario de destino
  Future<Result<Transfer>> receiveTransfer(String id);

  /// Cancela una transferencia (pending/in_transit -> cancelled)
  /// Si estaba en tránsito, revierte el inventario de origen
  Future<Result<Transfer>> cancelTransfer(String id, String reason);

  /// Obtiene estadísticas de transferencias
  Future<Result<Map<String, dynamic>>> getTransfersStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Sincroniza con el servidor remoto
  Future<Result<void>> syncWithRemote(String storeId);
}
