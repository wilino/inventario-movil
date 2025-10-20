import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_active_products_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';

// Events
abstract class ProductEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductLoadRequested extends ProductEvent {}

class ProductSearchRequested extends ProductEvent {
  final String query;

  ProductSearchRequested(this.query);

  @override
  List<Object?> get props => [query];
}

class ProductCreateRequested extends ProductEvent {
  final Product product;

  ProductCreateRequested(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductUpdateRequested extends ProductEvent {
  final Product product;

  ProductUpdateRequested(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductDeleteRequested extends ProductEvent {
  final String productId;

  ProductDeleteRequested(this.productId);

  @override
  List<Object?> get props => [productId];
}

// States
abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;

  ProductLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductOperationSuccess extends ProductState {
  final String message;

  ProductOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetActiveProductsUseCase getActiveProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;

  ProductBloc({
    required this.getActiveProductsUseCase,
    required this.searchProductsUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
  }) : super(ProductInitial()) {
    on<ProductLoadRequested>(_onLoadRequested);
    on<ProductSearchRequested>(_onSearchRequested);
    on<ProductCreateRequested>(_onCreateRequested);
    on<ProductUpdateRequested>(_onUpdateRequested);
    on<ProductDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onLoadRequested(
    ProductLoadRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await getActiveProductsUseCase();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    ProductSearchRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final products = await searchProductsUseCase(event.query);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    ProductCreateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await createProductUseCase(event.product);
      emit(ProductOperationSuccess('Producto creado exitosamente'));
      // Recargar productos
      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    ProductUpdateRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await updateProductUseCase(event.product);
      emit(ProductOperationSuccess('Producto actualizado exitosamente'));
      // Recargar productos
      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    ProductDeleteRequested event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      await deleteProductUseCase(event.productId);
      emit(ProductOperationSuccess('Producto eliminado exitosamente'));
      // Recargar productos
      add(ProductLoadRequested());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
