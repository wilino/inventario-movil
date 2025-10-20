import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/create_sale_usecase.dart';
import '../../domain/usecases/get_sales_stats_usecase.dart';
import '../../domain/usecases/get_store_sales_usecase.dart';
import '../../domain/usecases/get_today_sales_usecase.dart';
import '../../domain/repositories/sale_repository.dart';
import 'sale_event.dart';
import 'sale_state.dart';

/// BLoC para el manejo del estado de Ventas
class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final CreateSaleUseCase createSaleUseCase;
  final GetStoreSalesUseCase getStoreSalesUseCase;
  final GetTodaySalesUseCase getTodaySalesUseCase;
  final GetSalesStatsUseCase getSalesStatsUseCase;
  final SaleRepository repository;

  SaleBloc({
    required this.createSaleUseCase,
    required this.getStoreSalesUseCase,
    required this.getTodaySalesUseCase,
    required this.getSalesStatsUseCase,
    required this.repository,
  }) : super(SaleInitial()) {
    on<LoadStoreSales>(_onLoadStoreSales);
    on<LoadTodaySales>(_onLoadTodaySales);
    on<CreateSale>(_onCreateSale);
    on<CancelSale>(_onCancelSale);
    on<FilterSalesByDateRange>(_onFilterSalesByDateRange);
    on<SearchSalesByCustomer>(_onSearchSalesByCustomer);
    on<LoadSalesStats>(_onLoadSalesStats);
    on<LoadSaleDetail>(_onLoadSaleDetail);
    on<ClearFilters>(_onClearFilters);
  }

  /// Maneja el evento de cargar ventas de la tienda
  Future<void> _onLoadStoreSales(
    LoadStoreSales event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());

    final result = await getStoreSalesUseCase(event.storeId);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }

  /// Maneja el evento de cargar ventas del día
  Future<void> _onLoadTodaySales(
    LoadTodaySales event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());

    final result = await getTodaySalesUseCase(event.storeId);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }

  /// Maneja el evento de crear una venta
  Future<void> _onCreateSale(CreateSale event, Emitter<SaleState> emit) async {
    emit(SaleLoading());

    final result = await createSaleUseCase(event.sale);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (sale) => emit(SaleCreated(sale)),
    );
  }

  /// Maneja el evento de cancelar una venta
  Future<void> _onCancelSale(CancelSale event, Emitter<SaleState> emit) async {
    emit(SaleLoading());

    final result = await repository.cancelSale(event.saleId);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (_) => emit(SaleCancelled(event.saleId)),
    );
  }

  /// Maneja el evento de filtrar por rango de fechas
  Future<void> _onFilterSalesByDateRange(
    FilterSalesByDateRange event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());

    final result = await repository.getSalesByDateRange(
      event.storeId,
      event.startDate,
      event.endDate,
    );

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }

  /// Maneja el evento de buscar por cliente
  Future<void> _onSearchSalesByCustomer(
    SearchSalesByCustomer event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());

    final result = await repository.searchSalesByCustomer(
      event.storeId,
      event.query,
    );

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }

  /// Maneja el evento de cargar estadísticas
  Future<void> _onLoadSalesStats(
    LoadSalesStats event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());

    final result = await getSalesStatsUseCase(
      event.storeId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (stats) => emit(SalesStatsLoaded(stats)),
    );
  }

  /// Maneja el evento de cargar detalle de venta
  Future<void> _onLoadSaleDetail(
    LoadSaleDetail event,
    Emitter<SaleState> emit,
  ) async {
    emit(SaleLoading());

    final result = await repository.getSaleById(event.saleId);

    result.fold(
      (failure) => emit(SaleError(failure.message)),
      (sale) => emit(SaleDetailLoaded(sale)),
    );
  }

  /// Maneja el evento de limpiar filtros
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<SaleState> emit,
  ) async {
    // Recargar todas las ventas sin filtros
    add(LoadStoreSales(event.storeId));
  }
}
