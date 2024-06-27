// ignore_for_file: non_constant_identifier_names

import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/confirmCart/confirmCart.dart';

import '../../models/getFromCart/get_from_cart.dart';
import '../../models/payment/payment.dart';

abstract class CartServeices {
  Future<Either<Failure, GetFromCart>> getFromCart();
  Future addToCart({required int id});
  Future<Either<Failure, ConfirmCart>> confirmCart({required int id});
  Future deletefromCart({required int cart_id, required int product_id});
  Future<Either<Failure, Payment>> checkOut({required int totalPrice});
}
