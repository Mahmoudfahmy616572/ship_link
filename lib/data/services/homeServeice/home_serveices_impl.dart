// ignore_for_file: deprecated_member_use

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/constant/api_serveices.dart';
import 'package:ship_link/data/models/getTopSeller/getTopSeller.dart';
import 'package:ship_link/data/services/homeServeice/home_serveices.dart';

import '../../../constant/constant.dart';
import '../../models/allProducts/all_products.dart';

class HomeServeicesImpl extends HomeServeices {
  final ApiServeices apiServeices;
  HomeServeicesImpl(this.apiServeices);
  @override
  Future<Either<Failure, AllProducts>> getAllproducts() async {
    try {
      var data =
          await apiServeices.getHttp(endpoint: getProducts, headers: header);

      AllProducts allProducts = AllProducts.fromJson(data);

      return right(allProducts);
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
  Future<Either<Failure, GetTopSeller>> getTopSeller() async {
    try {
      var data = await apiServeices.getHttp(
          endpoint: getTopSellerUrl, headers: header);

      GetTopSeller allProducts = GetTopSeller.fromJson(data);

      return right(allProducts);
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
