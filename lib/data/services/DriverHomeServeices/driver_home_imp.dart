// ignore_for_file: deprecated_member_use

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/constant/api_serveices.dart';
import 'package:ship_link/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/data/models/getStates/get_states.dart';
import 'package:ship_link/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';
import 'package:ship_link/data/models/update_user_data/up_user_data.dart';

import '../../../constant/constant.dart';
import 'driver_home_serveices.dart';

class DriverHomeServeicesImpl extends DriverHomeServeices {
  final ApiServeices apiServeices;
  DriverHomeServeicesImpl(this.apiServeices);
  @override
  Future<Either<Failure, GetOrder>> getOrders() async {
    try {
      var data = await apiServeices.getHttp(endpoint: getOrderUrl, headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token'
      });

      GetOrder getOrder = GetOrder.fromJson(data);

      return right(getOrder);
    } catch (e) {
      if (e is DioError) {
        return left(
          ServerFailure.fromDioError(e),
        );
      }
      return left(
        ServerFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GetuserDriverData>> getuserData() async {
    try {
      var data = await apiServeices.getHttp(endpoint: getuserDataUrl, headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token'
      });

      GetuserDriverData getuserDriverData = GetuserDriverData.fromJson(data);

      return right(getuserDriverData);
    } catch (e) {
      if (e is DioError) {
        return left(
          ServerFailure.fromDioError(e),
        );
      }
      return left(
        ServerFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UpDateUserData>> updateUserData(
      {required int id,
      required String name,
      required String phoneNumber}) async {
    try {
      var data = await apiServeices.postHttp(
          endpoint: updateUserDataUrl,
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token'
          },
          data: {"state_id": id.toString()},
          queryParameters: {
            "name": name,
            "phone_number": phoneNumber,
          },
          id: id);
      print(data);

      return right(data["success"]);
    } catch (e) {
      if (e is DioError) {
        return left(
          ServerFailure.fromDioError(e),
        );
      }
      return left(
        ServerFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, AcceptOrder>> acceptOrders(
      {required int orderId}) async {
    try {
      var data = await apiServeices.postHttp(
          endpoint: acceptOrder,
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token'
          },
          data: {"order_id": orderId.toString()},
          id: orderId);
      print(data);

      return right(data["success"]);
    } catch (e) {
      if (e is DioError) {
        return left(
          ServerFailure.fromDioError(e),
        );
      }
      return left(
        ServerFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GetAcceptOrder>> getAcceptedOrders() async {
    try {
      var data = await apiServeices.getHttp(
          endpoint: getAcceptedOrdersUrl,
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token'
          });

      GetAcceptOrder getAcceptedOrder = GetAcceptOrder.fromJson(data);

      return right(getAcceptedOrder);
    } catch (e) {
      if (e is DioError) {
        return left(
          ServerFailure.fromDioError(e),
        );
      }
      return left(
        ServerFailure(
          e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, GetStates>> getStates(
      {required String selectedState}) async {
    try {
      var data = await apiServeices.getHttp(endpoint: getStatesUrl, headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token'
      });

      GetStates getStates = GetStates.fromJson(data);

      return right(getStates);
    } catch (e) {
      if (e is DioError) {
        return left(
          ServerFailure.fromDioError(e),
        );
      }
      return left(
        ServerFailure(
          e.toString(),
        ),
      );
    }
  }
}
