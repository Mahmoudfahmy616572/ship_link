import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/data/models/getTopSeller/getTopSeller.dart';
import 'package:ship_link/web/data/models/allProducts/all_products.dart';

abstract class HomeRepository {
  Future<Either<Failure, AllProducts>> getAllproducts();
  Future<Either<Failure, GetTopSeller>> getTopSeller();
}
