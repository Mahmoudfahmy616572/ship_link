import 'package:dartz/dartz.dart';
import 'package:ship_link/constant/Errors/failures.dart';
import 'package:ship_link/data/models/getTopSeller/getTopSeller.dart';
import 'package:ship_link/data/services/homeServeice/home_serveices.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/allProducts/all_products.dart';

class HomeServeicesImpl extends HomeServeices {
  HomeServeicesImpl();

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  Future<Either<Failure, AllProducts>> getAllproducts() async {
    try {
      final data = await _supabase.from('products').select('*');
      AllProducts allProducts = AllProducts.fromJson({
        'Products': {
          'Productscount': data.length,
          'Products': data,
        }
      });
      return right(allProducts);
    } catch (e) {
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
      GetTopSeller allProducts = GetTopSeller.fromJson({
        'top_sellers': data,
      });
      return right(allProducts);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
