import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';

import '../../models/getFromCart/get_from_cart.dart';

abstract class CartServeices {
  Future<Either<Failure, GetFromCart>> getFromCart();
  Future addToCart({required int id});
}
