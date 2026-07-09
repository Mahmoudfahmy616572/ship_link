import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/data/models/favourite/favourite_model.dart';
import 'package:ship_link/web/domain/repositories/favourite_repository.dart';
import 'package:ship_link/web/data/datasources/favourite_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteRepositoryImpl extends FavouriteRepository {
  final _dataSource = FavouriteRemoteDataSource();

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<FavouriteItem>>> getFavourites() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _dataSource.getFavourites();
      final watchedIds = await _dataSource.getWatchedProductIds();
      final items = (data as List).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        map['stock_watch'] = watchedIds.contains(map['product_id']) ? [true] : [];
        return FavouriteItem.fromJson(map);
      }).toList();
      return right(items);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavourite({required int productId}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final existing = await _dataSource.getExistingFavourite(productId);
      if (existing != null) {
        await _dataSource.deleteFavourite(productId);
        return right(false);
      } else {
        await _dataSource.insertFavourite(productId);
        return right(true);
      }
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleStockWatch({required int productId}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final watched = await _dataSource.getWatchedProductIds();
      if (watched.contains(productId)) {
        await _dataSource.removeStockWatch(productId);
        return right(false);
      } else {
        await _dataSource.addStockWatch(productId);
        return right(true);
      }
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
