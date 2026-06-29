import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/favourite/favourite_model.dart';

abstract class FavouriteService {
  Future<Either<Failure, List<FavouriteItem>>> getFavourites();
  Future<Either<Failure, bool>> toggleFavourite({required int productId});
}
