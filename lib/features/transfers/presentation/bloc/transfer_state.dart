import 'package:equatable/equatable.dart';
import '../../domain/entities/transfer.dart';

/// Estados del BLoC de transferencias
abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class TransferInitial extends TransferState {
  const TransferInitial();
}

/// Cargando
class TransferLoading extends TransferState {
  const TransferLoading();
}

/// Transferencias cargadas
class TransfersLoaded extends TransferState {
  final List<Transfer> transfers;
  final Map<String, dynamic>? stats;

  const TransfersLoaded(this.transfers, {this.stats});

  @override
  List<Object?> get props => [transfers, stats];
}

/// Detalle de transferencia cargado
class TransferDetailLoaded extends TransferState {
  final Transfer transfer;

  const TransferDetailLoaded(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia creada
class TransferCreated extends TransferState {
  final Transfer transfer;

  const TransferCreated(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia enviada
class TransferSent extends TransferState {
  final Transfer transfer;

  const TransferSent(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia recibida
class TransferReceived extends TransferState {
  final Transfer transfer;

  const TransferReceived(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Transferencia cancelada
class TransferCancelled extends TransferState {
  final Transfer transfer;

  const TransferCancelled(this.transfer);

  @override
  List<Object?> get props => [transfer];
}

/// Estadísticas cargadas
class TransfersStatsLoaded extends TransferState {
  final Map<String, dynamic> stats;

  const TransfersStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Sincronización completada
class TransfersSynced extends TransferState {
  const TransfersSynced();
}

/// Error
class TransferError extends TransferState {
  final String message;

  const TransferError(this.message);

  @override
  List<Object?> get props => [message];
}
