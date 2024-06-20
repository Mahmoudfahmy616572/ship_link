import 'package:dartz/dartz.dart';

import '../../../constant/Errors/failures.dart';
import '../../models/allProducts/all_products.dart';

abstract class HomeServeices {
  Future<Either<Failure, AllProducts>> getAllproducts();
}
