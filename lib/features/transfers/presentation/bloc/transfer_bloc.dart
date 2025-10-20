import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/transfer.dart';
import '../../domain/usecases/create_transfer_usecase.dart';
import '../../domain/usecases/get_pending_transfers_usecase.dart';
import '../../domain/usecases/get_store_transfers_usecase.dart';
import '../../domain/usecases/get_transfers_stats_usecase.dart';
import '../../domain/repositories/transfer_repository.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

/// BLoC para manejar el estado de las transferencias
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final TransferRepository repository;
  final CreateTransferUseCase createTransferUseCase;
  final GetStoreTransfersUseCase getStoreTransfersUseCase;
  final GetPendingTransfersUseCase getPendingTransfersUseCase;
  final GetTransfersStatsUseCase getTransfersStatsUseCase;

  TransferBloc({
    required this.repository,
    required this.createTransferUseCase,
    required this.getStoreTransfersUseCase,
    required this.getPendingTransfersUseCase,
    required this.getTransfersStatsUseCase,
  }) : super(const TransferInitial()) {
    on<LoadStoreTransfersEvent>(_onLoadStoreTransfers);
    on<LoadOutgoingTransfersEvent>(_onLoadOutgoingTransfers);
    on<LoadIncomingTransfersEvent>(_onLoadIncomingTransfers);
    on<LoadPendingTransfersEvent>(_onLoadPendingTransfers);
    on<LoadInTransitTransfersEvent>(_onLoadInTransitTransfers);
    on<LoadTransferDetailEvent>(_onLoadTransferDetail);
    on<CreateTransferEvent>(_onCreateTransfer);
    on<SendTransferEvent>(_onSendTransfer);
    on<ReceiveTransferEvent>(_onReceiveTransfer);
    on<CancelTransferEvent>(_onCancelTransfer);
    on<FilterTransfersByStatusEvent>(_onFilterByStatus);
    on<LoadTransfersStatsEvent>(_onLoadStats);
    on<SyncTransfersEvent>(_onSyncTransfers);
  }

  /// Cargar todas las transferencias de una tienda
  Future<void> _onLoadStoreTransfers(
    LoadStoreTransfersEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await getStoreTransfersUseCase(event.storeId);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  /// Cargar transferencias enviadas
  Future<void> _onLoadOutgoingTransfers(
    LoadOutgoingTransfersEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.getOutgoingTransfers(event.storeId);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  /// Cargar transferencias recibidas
  Future<void> _onLoadIncomingTransfers(
    LoadIncomingTransfersEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.getIncomingTransfers(event.storeId);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  /// Cargar transferencias pendientes
  Future<void> _onLoadPendingTransfers(
    LoadPendingTransfersEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await getPendingTransfersUseCase(event.storeId);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  /// Cargar transferencias en tránsito
  Future<void> _onLoadInTransitTransfers(
    LoadInTransitTransfersEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.getInTransitTransfers(event.storeId);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfers) => emit(TransfersLoaded(transfers)),
    );
  }

  /// Cargar detalle de una transferencia
  Future<void> _onLoadTransferDetail(
    LoadTransferDetailEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.getTransferById(event.id);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferDetailLoaded(transfer)),
    );
  }

  /// Crear nueva transferencia
  Future<void> _onCreateTransfer(
    CreateTransferEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await createTransferUseCase(event.transfer);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferCreated(transfer)),
    );
  }

  /// Enviar transferencia (pending -> in_transit)
  Future<void> _onSendTransfer(
    SendTransferEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.sendTransfer(event.id);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferSent(transfer)),
    );
  }

  /// Recibir transferencia (in_transit -> completed)
  Future<void> _onReceiveTransfer(
    ReceiveTransferEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.receiveTransfer(event.id);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferReceived(transfer)),
    );
  }

  /// Cancelar transferencia
  Future<void> _onCancelTransfer(
    CancelTransferEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.cancelTransfer(event.id, event.reason);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (transfer) => emit(TransferCancelled(transfer)),
    );
  }

  /// Filtrar transferencias por estado
  Future<void> _onFilterByStatus(
    FilterTransfersByStatusEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    if (event.status == null) {
      // Cargar todas
      final result = await repository.getStoreTransfers(event.storeId);
      result.fold(
        (failure) => emit(TransferError(failure.message)),
        (transfers) => emit(TransfersLoaded(transfers)),
      );
    } else {
      // Filtrar por estado específico
      final result = switch (event.status!) {
        TransferStatus.pending => await repository.getPendingTransfers(
          event.storeId,
        ),
        TransferStatus.inTransit => await repository.getInTransitTransfers(
          event.storeId,
        ),
        TransferStatus.completed => await repository.getStoreTransfers(
          event.storeId,
        ),
        TransferStatus.cancelled => await repository.getStoreTransfers(
          event.storeId,
        ),
      };

      result.fold((failure) => emit(TransferError(failure.message)), (
        transfers,
      ) {
        // Para completed y cancelled, filtrar localmente
        if (event.status == TransferStatus.completed) {
          final filtered = transfers.where((t) => t.isCompleted).toList();
          emit(TransfersLoaded(filtered));
        } else if (event.status == TransferStatus.cancelled) {
          final filtered = transfers.where((t) => t.isCancelled).toList();
          emit(TransfersLoaded(filtered));
        } else {
          emit(TransfersLoaded(transfers));
        }
      });
    }
  }

  /// Cargar estadísticas
  Future<void> _onLoadStats(
    LoadTransfersStatsEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await getTransfersStatsUseCase(
      event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (stats) => emit(TransfersStatsLoaded(stats)),
    );
  }

  /// Sincronizar con servidor
  Future<void> _onSyncTransfers(
    SyncTransfersEvent event,
    Emitter<TransferState> emit,
  ) async {
    emit(const TransferLoading());

    final result = await repository.syncWithRemote(event.storeId);

    result.fold(
      (failure) => emit(TransferError(failure.message)),
      (_) => emit(const TransfersSynced()),
    );
  }
}
