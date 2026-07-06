import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/driver/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/driver/data/models/getStates/get_states.dart';
import 'package:ship_link/driver/data/models/get_order/get_order.dart';
import 'package:ship_link/driver/data/models/update_user_data/up_user_data.dart';
import 'package:ship_link/driver/data/models/getUserDriverData/get_user_driver_data.dart';

abstract class DriverHomeRepository {
  Future<Either<Failure, GetOrder>> getOrders();
  Future<Either<Failure, GetStates>> getStates({required String selectedState});
  Future<Either<Failure, GetAcceptOrder>> getAcceptedOrders();
  Future<Either<Failure, GetuserDriverData>> getuserData();
  Future<Either<Failure, UpDateUserData>> updateUserData({
    required String name, required String phoneNumber,
  });
  Future<Either<Failure, AcceptOrder>> acceptOrders({required int orderId});
  Future<Either<Failure, AcceptOrder>> markPickedUp({required int orderId});
  Future<Either<Failure, AcceptOrder>> markShipped({required int orderId});
  Future<Either<Failure, AcceptOrder>> markDelivered({required int orderId});
  Future<Either<Failure, AcceptOrder>> cancelOrder({required int orderId});
}
