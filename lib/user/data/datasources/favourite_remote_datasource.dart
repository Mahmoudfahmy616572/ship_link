import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteRemoteDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _userId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getFavourites() async {
    return await _supabase.from('favourites').select('*, products(*)').eq('user_id', _userId!);
  }

  Future<Set<int>> getWatchedProductIds() async {
    final rows = await _supabase.from('stock_watch').select('product_id').eq('user_id', _userId!).eq('notified', false);
    return rows.map((r) => r['product_id'] as int).toSet();
  }

  Future<void> addStockWatch(int productId) async {
    await _supabase.from('stock_watch').upsert({'user_id': _userId!, 'product_id': productId, 'notified': false}, onConflict: 'user_id,product_id');
  }

  Future<void> removeStockWatch(int productId) async {
    await _supabase.from('stock_watch').delete().eq('user_id', _userId!).eq('product_id', productId);
  }

  Future<Map<String, dynamic>?> getExistingFavourite(int productId) async {
    return await _supabase.from('favourites').select('id').eq('user_id', _userId!).eq('product_id', productId).maybeSingle();
  }

  Future<void> deleteFavourite(int productId) async {
    await _supabase.from('favourites').delete().eq('user_id', _userId!).eq('product_id', productId);
  }

  Future<void> insertFavourite(int productId) async {
    await _supabase.from('favourites').insert({'user_id': _userId!, 'product_id': productId});
  }
}
