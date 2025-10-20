import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/create_purchase_usecase.dart';
import '../../domain/usecases/get_store_purchases_usecase.dart';
import '../../domain/usecases/get_today_purchases_usecase.dart';
import '../../domain/usecases/get_purchases_stats_usecase.dart';
import '../../domain/usecases/get_active_suppliers_usecase.dart';
import '../../domain/repositories/purchase_repository.dart';
import 'purchase_event.dart';
import 'purchase_state.dart';

/// BLoC para gestionar compras y proveedores
class PurchaseBloc extends Bloc<PurchaseEvent, PurchaseState> {
  final CreatePurchaseUseCase createPurchaseUseCase;
  final GetStorePurchasesUseCase getStorePurchasesUseCase;
  final GetTodayPurchasesUseCase getTodayPurchasesUseCase;
  final GetPurchasesStatsUseCase getPurchasesStatsUseCase;
  final GetActiveSuppliersUseCase getActiveSuppliersUseCase;
  final PurchaseRepository repository;

  PurchaseBloc({
    required this.createPurchaseUseCase,
    required this.getStorePurchasesUseCase,
    required this.getTodayPurchasesUseCase,
    required this.getPurchasesStatsUseCase,
    required this.getActiveSuppliersUseCase,
    required this.repository,
  }) : super(PurchaseInitial()) {
    on<LoadStorePurchases>(_onLoadStorePurchases);
    on<LoadTodayPurchases>(_onLoadTodayPurchases);
    on<CreatePurchase>(_onCreatePurchase);
    on<CancelPurchase>(_onCancelPurchase);
    on<GetPurchaseDetail>(_onGetPurchaseDetail);
    on<FilterPurchasesByDateRange>(_onFilterPurchasesByDateRange);
    on<SearchPurchasesBySupplier>(_onSearchPurchasesBySupplier);
    on<SearchPurchasesByInvoice>(_onSearchPurchasesByInvoice);
    on<LoadPurchasesStats>(_onLoadPurchasesStats);
    on<LoadActiveSuppliers>(_onLoadActiveSuppliers);
    on<CreateSupplier>(_onCreateSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeactivateSupplier>(_onDeactivateSupplier);
    on<SyncPurchases>(_onSyncPurchases);
  }

  /// Cargar compras de una tienda
  Future<void> _onLoadStorePurchases(
    LoadStorePurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await getStorePurchasesUseCase(event.storeId);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }

  /// Cargar compras del día actual
  Future<void> _onLoadTodayPurchases(
    LoadTodayPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await getTodayPurchasesUseCase(event.storeId);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }

  /// Crear una nueva compra
  Future<void> _onCreatePurchase(
    CreatePurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await createPurchaseUseCase(event.purchase);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchase) => emit(PurchaseCreated(purchase)),
    );
  }

  /// Cancelar una compra
  Future<void> _onCancelPurchase(
    CancelPurchase event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.cancelPurchase(event.id);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (_) => emit(PurchaseCancelled(event.id)),
    );
  }

  /// Obtener detalle de una compra
  Future<void> _onGetPurchaseDetail(
    GetPurchaseDetail event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.getPurchaseById(event.id);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchase) => emit(PurchaseDetailLoaded(purchase)),
    );
  }

  /// Filtrar compras por rango de fechas
  Future<void> _onFilterPurchasesByDateRange(
    FilterPurchasesByDateRange event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.getPurchasesByDateRange(
      event.storeId,
      event.startDate,
      event.endDate,
    );
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }

  /// Buscar compras por proveedor
  Future<void> _onSearchPurchasesBySupplier(
    SearchPurchasesBySupplier event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.searchPurchasesBySupplier(
      event.storeId,
      event.supplierId,
    );
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }

  /// Buscar compras por factura
  Future<void> _onSearchPurchasesByInvoice(
    SearchPurchasesByInvoice event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.searchPurchasesByInvoice(
      event.storeId,
      event.query,
    );
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (purchases) => emit(PurchasesLoaded(purchases)),
    );
  }

  /// Cargar estadísticas de compras
  Future<void> _onLoadPurchasesStats(
    LoadPurchasesStats event,
    Emitter<PurchaseState> emit,
  ) async {
    // Cargar compras primero
    final purchasesResult = await getStorePurchasesUseCase(event.storeId);
    
    // Cargar estadísticas
    final statsResult = await getPurchasesStatsUseCase(
      event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );
    
    if (purchasesResult.isError) {
      emit(PurchaseError(purchasesResult.errorOrNull!.message));
      return;
    }
    
    if (statsResult.isError) {
      emit(PurchaseError(statsResult.errorOrNull!.message));
      return;
    }
    
    emit(PurchasesLoaded(
      purchasesResult.valueOrNull!,
      stats: statsResult.valueOrNull,
    ));
  }

  /// Cargar proveedores activos
  Future<void> _onLoadActiveSuppliers(
    LoadActiveSuppliers event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await getActiveSuppliersUseCase();
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (suppliers) => emit(SuppliersLoaded(suppliers)),
    );
  }

  /// Crear un proveedor
  Future<void> _onCreateSupplier(
    CreateSupplier event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.createSupplier(event.supplier);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (supplier) => emit(SupplierCreated(supplier)),
    );
  }

  /// Actualizar un proveedor
  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.updateSupplier(event.supplier);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (supplier) => emit(SupplierUpdated(supplier)),
    );
  }

  /// Desactivar un proveedor
  Future<void> _onDeactivateSupplier(
    DeactivateSupplier event,
    Emitter<PurchaseState> emit,
  ) async {
    emit(PurchaseLoading());
    
    final result = await repository.deactivateSupplier(event.id);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (_) => emit(SupplierDeactivated(event.id)),
    );
  }

  /// Sincronizar con el servidor
  Future<void> _onSyncPurchases(
    SyncPurchases event,
    Emitter<PurchaseState> emit,
  ) async {
    final result = await repository.syncWithRemote(event.storeId);
    
    result.fold(
      (failure) => emit(PurchaseError(failure.message)),
      (_) => emit(PurchasesSynced()),
    );
  }
}
