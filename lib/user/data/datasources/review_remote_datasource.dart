import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRemoteDataSource {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getReviews(int productId) async {
    return await _supabase
        .from('reviews')
        .select('*, profiles(name, avatar)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getRatings(int productId) async {
    return await _supabase.from('reviews').select('rating').eq('product_id', productId);
  }

  Future<void> insertReview(Map<String, dynamic> data) async {
    await _supabase.from('reviews').insert(data);
  }

  Future<Map<String, dynamic>?> findExisting(String userId, int productId, int orderId) async {
    return await _supabase
        .from('reviews')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .eq('order_id', orderId)
        .maybeSingle();
  }
}
