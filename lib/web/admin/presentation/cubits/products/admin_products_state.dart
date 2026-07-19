import 'package:ship_link/web/admin/domain/models/admin_models.dart';

abstract class AdminProductsState {}

class AdminProductsInitial extends AdminProductsState {}

class AdminProductsLoading extends AdminProductsState {}

class AdminProductsLoaded extends AdminProductsState {
  final List<AdminProduct> products;
  final String? search;
  final String? category;
  final String sortBy;
  final bool ascending;
  final bool hasMore;
  AdminProductsLoaded(this.products, {this.search, this.category, this.sortBy = 'created_at', this.ascending = false, this.hasMore = false});
}

class AdminProductsError extends AdminProductsState {
  final String message;
  AdminProductsError(this.message);
}

class AdminProductSaveSuccess extends AdminProductsState {
  final int? id;
  AdminProductSaveSuccess({this.id});
}

class AdminProductDeleteSuccess extends AdminProductsState {
  final int id;
  AdminProductDeleteSuccess(this.id);
}

class AdminProductsBulkDeleteSuccess extends AdminProductsState {
  final int count;
  AdminProductsBulkDeleteSuccess(this.count);
}
