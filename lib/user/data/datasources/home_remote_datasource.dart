import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRemoteDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await _supabase.from('products').select('*');
  }

  Future<List<Map<String, dynamic>>> getTopSellers() async {
    return await _supabase.from('products').select('*').eq('is_top_seller', true);
  }
}
