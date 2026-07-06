import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/user/data/models/getTopSeller/getTopSeller.dart';
import 'package:ship_link/user/domain/repositories/home_repository.dart';
import 'package:ship_link/user/data/datasources/home_remote_datasource.dart';
import 'package:ship_link/core/services/cache_service.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';

class HomeRepositoryImpl extends HomeRepository {
  HomeRepositoryImpl();

  final _dataSource = HomeRemoteDataSource();
  final _cache = CacheService();

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
      if (data.isNotEmpty) {
        await _cache.put('all_products', json);
      }
      AllProducts allProducts = AllProducts.fromJson(json);
      return right(allProducts);
    } catch (e) {
      final cached = await _cache.get('all_products');
      if (cached != null) {
        return right(AllProducts.fromJson(cached));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, GetTopSeller>> getTopSeller() async {
    try {
      final data = await _dataSource.getTopSellers();
      final json = {'top_sellers': data};
      if (data.isNotEmpty) {
        await _cache.put('top_sellers', json);
      }
      GetTopSeller allProducts = GetTopSeller.fromJson(json);
      return right(allProducts);
    } catch (e) {
      final cached = await _cache.get('top_sellers');
      if (cached != null) {
        return right(GetTopSeller.fromJson(cached));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}
