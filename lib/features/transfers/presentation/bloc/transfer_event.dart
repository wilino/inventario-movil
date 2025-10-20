import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer.dart';

/// Eventos del BLoC de transferencias
abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar transferencias de una tienda
class LoadStoreTransfersEvent extends TransferEvent {
  final String storeId;

  const LoadStoreTransfersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Cargar transferencias enviadas
class LoadOutgoingTransfersEvent extends TransferEvent {
  final String storeId;

  const LoadOutgoingTransfersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Cargar transferencias recibidas
class LoadIncomingTransfersEvent extends TransferEvent {
  final String storeId;

  const LoadIncomingTransfersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Cargar transferencias pendientes
class LoadPendingTransfersEvent extends TransferEvent {
  final String storeId;

  const LoadPendingTransfersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Cargar transferencias en tránsito
class LoadInTransitTransfersEvent extends TransferEvent {
  final String storeId;

  const LoadInTransitTransfersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}

/// Cargar detalle de transferencia
class LoadTransferDetailEvent extends TransferEvent {
  final String id;

  const LoadTransferDetailEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Crear nueva transferencia
class CreateTransferEvent extends TransferEvent {
  final Transfer transfer;

  const CreateTransferEvent(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Enviar transferencia (pending -> in_transit)
class SendTransferEvent extends TransferEvent {
  final String id;

  const SendTransferEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Recibir transferencia (in_transit -> completed)
class ReceiveTransferEvent extends TransferEvent {
  final String id;

  const ReceiveTransferEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Cancelar transferencia
class CancelTransferEvent extends TransferEvent {
  final String id;
  final String reason;

  const CancelTransferEvent(this.id, this.reason);

  @override
  List<Object?> get props => [id, reason];
}

/// Filtrar por estado
class FilterTransfersByStatusEvent extends TransferEvent {
  final String storeId;
  final TransferStatus? status;

  const FilterTransfersByStatusEvent(this.storeId, this.status);

  @override
  List<Object?> get props => [storeId, status];
}

/// Cargar estadísticas
class LoadTransfersStatsEvent extends TransferEvent {
  final String storeId;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadTransfersStatsEvent(this.storeId, {this.startDate, this.endDate});

  @override
  List<Object?> get props => [storeId, startDate, endDate];
}

/// Sincronizar con servidor
class SyncTransfersEvent extends TransferEvent {
  final String storeId;

  const SyncTransfersEvent(this.storeId);

  @override
  List<Object?> get props => [storeId];
}
