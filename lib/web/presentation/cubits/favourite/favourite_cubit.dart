import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/presentation/cubits/favourite/favourite_state.dart';
import 'package:ship_link/web/domain/repositories/favourite_repository.dart';

export 'package:ship_link/web/presentation/cubits/favourite/favourite_state.dart';

class FavouriteCubit extends Cubit<FavouriteState> {
  final FavouriteRepository _service;
  Set<int> _favouriteIds = {};

  FavouriteCubit(this._service) : super(FavouriteInitial());

  bool isFavourite(int productId) => _favouriteIds.contains(productId);

  Set<int> get favouriteIds => _favouriteIds;

  Future<void> getFavourites() async {
    if (!isClosed) emit(FavouriteLoading());
    final result = await _service.getFavourites();
    result.fold(
      (failure) { if (!isClosed) emit(FavouriteError(failure.errMessage)); },
      (items) {
        _favouriteIds = items.map((e) => e.productId).toSet();
        if (!isClosed) emit(FavouriteLoaded(items: items, favouriteIds: _favouriteIds));
      },
    );
  }

  Future<void> toggleFavourite(int productId) async {
    final result = await _service.toggleFavourite(productId: productId);
    result.fold(
      (failure) { if (!isClosed) emit(FavouriteError(failure.errMessage)); },
      (added) {
        if (added) {
          _favouriteIds.add(productId);
        } else {
          _favouriteIds.remove(productId);
        }
        if (!isClosed) {
          final current = state;
          if (current is FavouriteLoaded) {
            final filtered = current.items.where((e) => _favouriteIds.contains(e.productId)).toList();
            emit(FavouriteLoaded(items: filtered, favouriteIds: _favouriteIds));
          } else {
            emit(FavouriteLoaded(items: [], favouriteIds: _favouriteIds));
          }
        }
      },
    );
  }

  Future<void> toggleStockWatch(int productId) async {
    final result = await _service.toggleStockWatch(productId: productId);
    result.fold(
      (failure) { if (!isClosed) emit(FavouriteError(failure.errMessage)); },
      (_) { getFavourites(); },
    );
  }
}
