import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/data/models/getTopSeller/getTopSeller.dart';
import 'package:ship_link/web/domain/repositories/home_repository.dart';
import 'package:ship_link/web/data/datasources/home_remote_datasource.dart';
import 'package:ship_link/web/data/models/allProducts/all_products.dart';

class HomeRepositoryImpl extends HomeRepository {
  HomeRepositoryImpl();

  final _dataSource = HomeRemoteDataSource();

  @override
  Future<Either<Failure, AllProducts>> getAllproducts() async {
    try {
      final data = await _dataSource.getAllProducts();
      final json = {
        'Products': {
          'Productscount': data.length,
          'Products': data,
        }
      };
      AllProducts allProducts = AllProducts.fromJson(json);
      return right(allProducts);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetTopSeller>> getTopSeller() async {
    try {
      final data = await _dataSource.getTopSellers();
      final json = {'top_sellers': data};
      GetTopSeller allProducts = GetTopSeller.fromJson(json);
      return right(allProducts);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
