import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/data/models/favourite/favourite_model.dart';

abstract class FavouriteRepository {
  Future<Either<Failure, List<FavouriteItem>>> getFavourites();
  Future<Either<Failure, bool>> toggleFavourite({required int productId});
  Future<Either<Failure, bool>> toggleStockWatch({required int productId});
}
