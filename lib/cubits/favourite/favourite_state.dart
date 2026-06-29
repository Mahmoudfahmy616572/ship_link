import 'package:ship_link/data/models/favourite/favourite_model.dart';

abstract class FavouriteState {}

class FavouriteInitial extends FavouriteState {}

class FavouriteLoading extends FavouriteState {}

class FavouriteLoaded extends FavouriteState {
  final List<FavouriteItem> items;
  final Set<int> favouriteIds;
  FavouriteLoaded({required this.items, required this.favouriteIds});
}

class FavouriteError extends FavouriteState {
  final String message;
  FavouriteError(this.message);
}
