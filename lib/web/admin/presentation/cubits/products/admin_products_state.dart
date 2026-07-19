abstract class AdminProductsState {}

class AdminProductsInitial extends AdminProductsState {}

class AdminProductsLoading extends AdminProductsState {}

class AdminProductsLoaded extends AdminProductsState {
  final List<Map<String, dynamic>> products;
  final String? search;
  final bool hasMore;
  AdminProductsLoaded(this.products, {this.search, this.hasMore = false});
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
