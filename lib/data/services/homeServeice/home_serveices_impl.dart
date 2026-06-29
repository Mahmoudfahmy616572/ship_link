import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/getTopSeller/getTopSeller.dart';
import 'package:ship_link/data/services/homeServeice/home_serveices.dart';
import 'package:ship_link/services/cache_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/allProducts/all_products.dart';

class HomeServeicesImpl extends HomeServeices {
  HomeServeicesImpl();

  SupabaseClient get _supabase => Supabase.instance.client;
  final _cache = CacheService();

  @override
  Future<Either<Failure, AllProducts>> getAllproducts() async {
    try {
      final data = await _supabase.from('products').select('*');
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
      final data = await _supabase
          .from('products')
          .select('*')
          .eq('is_top_seller', true);
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
