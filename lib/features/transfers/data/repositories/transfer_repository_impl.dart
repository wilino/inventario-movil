import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_local_datasource.dart';
import '../datasources/transfer_remote_datasource.dart';

/// Implementación del repositorio de transferencias con patrón Offline-First
class TransferRepositoryImpl implements TransferRepository {
  final TransferLocalDataSource localDataSource;
  final TransferRemoteDataSource remoteDataSource;

  TransferRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Result<List<Transfer>>> getStoreTransfers(String storeId) async {
    try {
      // Obtener de la base de datos local
      final transfers = await localDataSource.getStoreTransfers(storeId);
      return Success(transfers);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al obtener transferencias: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Transfer>>> getOutgoingTransfers(String storeId) async {
    try {
      final transfers = await localDataSource.getOutgoingTransfers(storeId);
      return Success(transfers);
    } catch (e) {
      return Error(
        CacheFailure(
          message: 'Error al obtener transferencias enviadas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<Transfer>>> getIncomingTransfers(String storeId) async {
    try {
      final transfers = await localDataSource.getIncomingTransfers(storeId);
      return Success(transfers);
    } catch (e) {
      return Error(
        CacheFailure(
          message: 'Error al obtener transferencias recibidas: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<Transfer>>> getPendingTransfers(String storeId) async {
    try {
      final transfers = await localDataSource.getPendingTransfers(storeId);
      return Success(transfers);
    } catch (e) {
      return Error(
        CacheFailure(
          message: 'Error al obtener transferencias pendientes: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<List<Transfer>>> getInTransitTransfers(String storeId) async {
    try {
      final transfers = await localDataSource.getInTransitTransfers(storeId);
      return Success(transfers);
    } catch (e) {
      return Error(
        CacheFailure(
          message: 'Error al obtener transferencias en tránsito: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Result<Transfer>> getTransferById(String id) async {
    try {
      final transfer = await localDataSource.getTransferById(id);
      if (transfer == null) {
        return const Error(NotFoundFailure(message: 'Transferencia no encontrada'));
      }
      return Success(transfer);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al obtener transferencia: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Transfer>> createTransfer(Transfer transfer) async {
    try {
      // Guardar localmente
      final created = await localDataSource.createTransfer(transfer);

      // Intentar sincronizar con el servidor (sin bloquear)
      _syncWithRemoteInBackground(created, 'create');

      return Success(created);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al crear transferencia: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Transfer>> sendTransfer(String id) async {
    try {
      // Actualizar localmente y decrementar inventario
      final sent = await localDataSource.sendTransfer(id);

      // Intentar sincronizar con el servidor (sin bloquear)
      _syncWithRemoteInBackground(sent, 'update');

      return Success(sent);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al enviar transferencia: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Transfer>> receiveTransfer(String id) async {
    try {
      // Actualizar localmente e incrementar inventario
      final received = await localDataSource.receiveTransfer(id);

      // Intentar sincronizar con el servidor (sin bloquear)
      _syncWithRemoteInBackground(received, 'update');

      return Success(received);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al recibir transferencia: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Transfer>> cancelTransfer(String id, String reason) async {
    try {
      // Actualizar localmente y revertir inventario si es necesario
      final cancelled = await localDataSource.cancelTransfer(id, reason);

      // Intentar sincronizar con el servidor (sin bloquear)
      _syncWithRemoteInBackground(cancelled, 'update');

      return Success(cancelled);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al cancelar transferencia: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getTransfersStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final stats = await localDataSource.getTransfersStats(
        storeId,
        startDate: startDate,
        endDate: endDate,
      );
      return Success(stats);
    } catch (e) {
      return Error(
        CacheFailure(message: 'Error al obtener estadísticas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> syncWithRemote(String storeId) async {
    try {
      // Obtener la última fecha de sincronización (podrías guardarla en SharedPreferences)
      final lastSync = DateTime.now().subtract(const Duration(days: 7));

      // Obtener transferencias actualizadas desde el servidor
      final remoteTransfers =
          await remoteDataSource.syncTransfersSince(storeId, lastSync);

      // Actualizar la base de datos local con las transferencias remotas
      for (final transfer in remoteTransfers) {
        final localTransfer = await localDataSource.getTransferById(transfer.id);

        if (localTransfer == null) {
          // Nueva transferencia del servidor
          await localDataSource.createTransfer(transfer);
        } else if (transfer.updatedAt.isAfter(localTransfer.updatedAt)) {
          // La versión del servidor es más reciente
          // Nota: En producción, aquí deberías manejar conflictos de manera más sofisticada
          await localDataSource.createTransfer(transfer);
        }
      }

      return const Success(null);
    } catch (e) {
      return Error(
        ServerFailure(message: 'Error al sincronizar: ${e.toString()}'),
      );
    }
  }

  /// Sincroniza con el servidor en segundo plano sin bloquear la operación
  void _syncWithRemoteInBackground(Transfer transfer, String operation) {
    // Ejecutar en segundo plano
    Future.microtask(() async {
      try {
        if (operation == 'create') {
          await remoteDataSource.createTransfer(transfer);
        } else {
          await remoteDataSource.updateTransfer(transfer);
        }
      } catch (e) {
        // Log del error pero no bloquea la operación local
        print('Error al sincronizar con el servidor: $e');
      }
    });
  }
}
