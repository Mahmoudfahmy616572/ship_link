import 'package:dartz/dartz.dart';
import 'package:ship_link/data/models/getTopSeller/getTopSeller.dart';

import '../../../constant/Errors/failures.dart';
import '../../models/allProducts/all_products.dart';

abstract class HomeServeices {
  Future<Either<Failure, AllProducts>> getAllproducts();
  Future<Either<Failure, GetTopSeller>> getTopSeller();
}
