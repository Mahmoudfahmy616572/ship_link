import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';

abstract class DriverHomeServeices {
  Future<Either<Failure, GetOrder>> getOrders();
}
