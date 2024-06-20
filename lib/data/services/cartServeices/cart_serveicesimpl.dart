// ignore_for_file: deprecated_member_use

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveices.dart';

import '../../../constant/api_serveices.dart';
import '../../../constant/constant.dart';

class CartServeicesImpl extends CartServeices {
  final ApiServeices apiServeices;
  CartServeicesImpl(this.apiServeices);

  @override
  Future<Either<Failure, GetFromCart>> getFromCart() async {
    try {
      var data = await apiServeices.getHttp(
        endpoint: getfromCart,
        headers: {
          "Accept": "application/json",
          "Authorization": 'Bearer $token'
        },
      );

      GetFromCart getFromCart = GetFromCart.fromJson(data);

      return right(getFromCart);
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
  Future addToCart({required int id}) async {
    try {
      var data = await apiServeices.postHttp(
          endpoint: addProducts,
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token'
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
}
