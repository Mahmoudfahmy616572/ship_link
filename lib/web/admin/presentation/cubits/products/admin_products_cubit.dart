import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/products/admin_products_state.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  AdminProductsCubit(this._repository) : super(AdminProductsInitial());

  final AdminRepository _repository;

  static AdminProductsCubit get(context) => BlocProvider.of<AdminProductsCubit>(context);

  Future<void> loadProducts({int limit = 20, int offset = 0, String? search, bool append = false}) async {
    if (!append) {
      if (!isClosed) emit(AdminProductsLoading());
    }
    final result = await _repository.getProducts(limit: limit, offset: offset, search: search);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (products) {
        if (!isClosed) {
          final current = append && state is AdminProductsLoaded ? (state as AdminProductsLoaded).products : <Map<String, dynamic>>[];
          final merged = [...current, ...products];
          emit(AdminProductsLoaded(merged, search: search, hasMore: products.length >= limit));
        }
      },
    );
  }

  Future<void> loadMoreProducts({String? search}) async {
    if (state is! AdminProductsLoaded) return;
    final loaded = state as AdminProductsLoaded;
    if (!loaded.hasMore) return;
    await loadProducts(offset: loaded.products.length, search: search, append: true);
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    if (!isClosed) emit(AdminProductsLoading());
    final result = await _repository.createProduct(data);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (created) {
        if (!isClosed) emit(AdminProductSaveSuccess(id: created['id'] is int ? created['id'] : null));
      },
    );
  }

  Future<void> updateProduct({required int id, required Map<String, dynamic> data}) async {
    if (!isClosed) emit(AdminProductsLoading());
    final result = await _repository.updateProduct(id: id, data: data);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminProductSaveSuccess(id: id));
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    if (!isClosed) emit(AdminProductsLoading());
    final result = await _repository.deleteProduct(id);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminProductDeleteSuccess(id));
      },
    );
  }
}
