import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/entities/inventory_adjustment.dart';
import '../../domain/usecases/get_store_inventory.dart';
import '../../domain/usecases/get_low_stock_items.dart';
import '../../domain/usecases/adjust_inventory.dart';
import '../../domain/usecases/get_adjustment_history.dart';
import '../../domain/usecases/get_inventory_stats.dart';

// Events
abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryLoadRequested extends InventoryEvent {
  final String storeId;
  InventoryLoadRequested(this.storeId);
  
  @override
  List<Object?> get props => [storeId];
}

class InventoryLowStockRequested extends InventoryEvent {
  final String storeId;
  InventoryLowStockRequested(this.storeId);
  
  @override
  List<Object?> get props => [storeId];
}

class InventoryAdjustRequested extends InventoryEvent {
  final AdjustInventoryParams params;
  InventoryAdjustRequested(this.params);
  
  @override
  List<Object?> get props => [params];
}

class InventoryStatsRequested extends InventoryEvent {
  final String storeId;
  InventoryStatsRequested(this.storeId);
  
  @override
  List<Object?> get props => [storeId];
}

class InventoryHistoryRequested extends InventoryEvent {
  final String inventoryId;
  InventoryHistoryRequested(this.inventoryId);
  
  @override
  List<Object?> get props => [inventoryId];
}

// States
abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryItem> items;
  InventoryLoaded(this.items);
  
  @override
  List<Object?> get props => [items];
}

class InventoryStatsLoaded extends InventoryState {
  final Map<String, dynamic> stats;
  InventoryStatsLoaded(this.stats);
  
  @override
  List<Object?> get props => [stats];
}

class InventoryHistoryLoaded extends InventoryState {
  final List<InventoryAdjustment> history;
  InventoryHistoryLoaded(this.history);
  
  @override
  List<Object?> get props => [history];
}

class InventoryOperationSuccess extends InventoryState {
  final String message;
  InventoryOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetStoreInventoryUseCase getStoreInventoryUseCase;
  final GetLowStockItemsUseCase getLowStockItemsUseCase;
  final AdjustInventoryUseCase adjustInventoryUseCase;
  final GetAdjustmentHistoryUseCase getAdjustmentHistoryUseCase;
  final GetInventoryStatsUseCase getInventoryStatsUseCase;

  InventoryBloc({
    required this.getStoreInventoryUseCase,
    required this.getLowStockItemsUseCase,
    required this.adjustInventoryUseCase,
    required this.getAdjustmentHistoryUseCase,
    required this.getInventoryStatsUseCase,
  }) : super(InventoryInitial()) {
    on<InventoryLoadRequested>(_onLoadRequested);
    on<InventoryLowStockRequested>(_onLowStockRequested);
    on<InventoryAdjustRequested>(_onAdjustRequested);
    on<InventoryStatsRequested>(_onStatsRequested);
    on<InventoryHistoryRequested>(_onHistoryRequested);
  }

  Future<void> _onLoadRequested(
    InventoryLoadRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await getStoreInventoryUseCase(event.storeId);
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError('Error al cargar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onLowStockRequested(
    InventoryLowStockRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final items = await getLowStockItemsUseCase(event.storeId);
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError('Error al cargar productos con stock bajo: ${e.toString()}'));
    }
  }

  Future<void> _onAdjustRequested(
    InventoryAdjustRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await adjustInventoryUseCase(event.params);
      emit(InventoryOperationSuccess('Inventario ajustado correctamente'));
      // Recargar inventario
      final items = await getStoreInventoryUseCase(event.params.inventoryId);
      emit(InventoryLoaded(items));
    } catch (e) {
      emit(InventoryError('Error al ajustar inventario: ${e.toString()}'));
    }
  }

  Future<void> _onStatsRequested(
    InventoryStatsRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final stats = await getInventoryStatsUseCase(event.storeId);
      emit(InventoryStatsLoaded(stats));
    } catch (e) {
      emit(InventoryError('Error al cargar estadísticas: ${e.toString()}'));
    }
  }

  Future<void> _onHistoryRequested(
    InventoryHistoryRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    try {
      final history = await getAdjustmentHistoryUseCase(event.inventoryId);
      emit(InventoryHistoryLoaded(history));
    } catch (e) {
      emit(InventoryError('Error al cargar historial: ${e.toString()}'));
    }
  }
}
