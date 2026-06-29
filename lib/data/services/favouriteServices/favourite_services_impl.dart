import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/favourite/favourite_model.dart';
import 'package:ship_link/data/services/favouriteServices/favourite_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteServiceImpl extends FavouriteService {
  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<FavouriteItem>>> getFavourites() async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final data = await _supabase
          .from('favourites')
          .select('*, products(*)')
          .eq('user_id', _userId!);
      final items = (data as List).map((e) => FavouriteItem.fromJson(e as Map<String, dynamic>)).toList();
      return right(items);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleFavourite({required int productId}) async {
    try {
      if (_userId == null) return left(ServerFailure('Not authenticated'));
      final existing = await _supabase
          .from('favourites')
          .select('id')
          .eq('user_id', _userId!)
          .eq('product_id', productId)
          .maybeSingle();
      if (existing != null) {
        await _supabase
            .from('favourites')
            .delete()
            .eq('user_id', _userId!)
            .eq('product_id', productId);
        return right(false);
      } else {
        await _supabase.from('favourites').insert({
          'user_id': _userId!,
          'product_id': productId,
        });
        return right(true);
      }
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
