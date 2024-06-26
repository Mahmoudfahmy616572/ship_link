import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';
import 'package:ship_link/data/models/update_user_data/up_user_data.dart';

import '../../models/getUserDriverData/get_user_driver_data.dart';

abstract class DriverHomeServeices {
  Future<Either<Failure, GetOrder>> getOrders();
  Future<Either<Failure, GetAcceptOrder>> getAcceptedOrders();
  Future<Either<Failure, GetuserDriverData>> getuserData();
  Future<Either<Failure, UpDateUserData>> updateUserData({
    required int id,
    required String phoneNumber,
    required String name,
  });
  Future<Either<Failure, AcceptOrder>> acceptOrders({required int orderId});
}
