// ignore_for_file: deprecated_member_use

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/constant/api_serveices.dart';
import 'package:ship_link/data/models/get_order/get_order.dart';

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
}
