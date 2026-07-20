import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/products/admin_products_state.dart';

class AdminProductsCubit extends Cubit<AdminProductsState> {
  AdminProductsCubit(this._repository) : super(AdminProductsInitial());

  final AdminRepository _repository;

  static AdminProductsCubit get(context) => BlocProvider.of<AdminProductsCubit>(context);

  Future<void> loadProducts({int limit = 20, int offset = 0, String? search, String? category, String sortBy = 'created_at', bool ascending = false, bool append = false}) async {
    // ignore: avoid_print
    print('DEBUG loadProducts called, append=$append, currentState=${state.runtimeType}');
    if (!append) {
      if (!isClosed) emit(AdminProductsLoading());
    }
    final result = await _repository.getProducts(limit: limit, offset: offset, search: search, category: category, sortBy: sortBy, ascending: ascending);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (products) {
        if (!isClosed) {
          final current = append && state is AdminProductsLoaded ? (state as AdminProductsLoaded).products : <AdminProduct>[];
          final merged = [...current, ...products];
          emit(AdminProductsLoaded(merged, search: search, category: category, sortBy: sortBy, ascending: ascending, hasMore: products.length >= limit));
        }
      },
    );
  }

  Future<void> loadMoreProducts({String? search, String? category, String sortBy = 'created_at', bool ascending = false}) async {
    if (state is! AdminProductsLoaded) return;
    final loaded = state as AdminProductsLoaded;
    if (!loaded.hasMore) return;
    await loadProducts(offset: loaded.products.length, search: search, category: category, sortBy: sortBy, ascending: ascending, append: true);
  }

  List<String> _categories = const [];
  List<String> get categories => _categories;

  Future<void> loadCategories() async {
    final result = await _repository.getProductCategories();
    result.fold(
      (failure) {},
      (cats) {
        if (!isClosed) _categories = cats;
      },
    );
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    if (!isClosed) emit(AdminProductsLoading());
    final result = await _repository.createProduct(data);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (created) {
        if (!isClosed) emit(AdminProductSaveSuccess(id: created.id));
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

  Future<Either<Failure, String>> uploadProductImage(Uint8List bytes, String fileName) async {
    return _repository.uploadProductImage(bytes, fileName);
  }

  Future<void> deleteProductsBulk(List<int> ids) async {
    if (!isClosed) emit(AdminProductsLoading());
    final result = await _repository.deleteProductsBulk(ids);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminProductsBulkDeleteSuccess(ids.length));
      },
    );
  }

  Future<void> toggleStatus(int id, int currentStatus) async {
    // ignore: avoid_print
    print('DEBUG toggleStatus id=$id current=$currentStatus');
    final newStatus = currentStatus == 1 ? 0 : 1;
    final result = await _repository.toggleProductStatus(id, newStatus);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminProductsError(failure.errMessage));
      },
      (_) {
        // نحدث المنتج محلياً من غير ما نعمل reload كامل
        if (state is AdminProductsLoaded && !isClosed) {
          final loaded = state as AdminProductsLoaded;
          final updated = loaded.products.map((p) => p.id == id ? p.copyWith(status: newStatus) : p).toList();
          emit(AdminProductsLoaded(updated, search: loaded.search, category: loaded.category, sortBy: loaded.sortBy, ascending: loaded.ascending, hasMore: loaded.hasMore));
        }
      },
    );
  }
}
