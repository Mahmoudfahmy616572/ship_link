// ignore_for_file: deprecated_member_use

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/confirmCart/confirmCart.dart';
import 'package:ship_link/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/data/models/payment/payment.dart';
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
          data: {"user_id": '2', "product_id": id.toString()},
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
  Future deletefromCart({
    required int cart_id,
    required int product_id,
  }) async {
    try {
      print(cart_id);
      print(product_id);
      var data = await apiServeices.deleteHttp(
        endpoint: "$deletefromCart1$cart_id$deletefromCart2$product_id",
        headers: {
          "Accept": "application/json",
          "Authorization": 'Bearer $token'
        },
      );
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
  Future<Either<Failure, ConfirmCart>> confirmCart(
      {required int id, required int userId}) async {
    try {
      var data = await apiServeices.postHttp(
          endpoint: confirmeCart,
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token'
          },
          data: {"user_id": userId.toString(), "cart_id": id.toString()},
          id: id);
      print(data);
      print(id);
      ConfirmCart confirmCart = ConfirmCart.fromJson(data);

      return right(confirmCart);
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
  Future<Either<Failure, Payment>> checkOut({required int totalPrice}) async {
    try {
      var data = await apiServeices.postHttp(endpoint: paymentUrl, headers: {
        "Accept": "application/json",
        "Authorization": 'Bearer $token'
      }, queryParameters: {
        "total": totalPrice,
      });

      Payment payment = Payment.fromJson(data);

      return right(payment);
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
