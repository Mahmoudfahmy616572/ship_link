import 'package:ship_link/data/models/review/review_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Review>> getReviews(int productId) async {
    final data = await _supabase
        .from('reviews')
        .select('*, profiles(first_name, avatar)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
    return (data as List).map((e) => Review.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> getProductRating(int productId) async {
    final data = await _supabase
        .from('reviews')
        .select('rating')
        .eq('product_id', productId);
    final ratings = (data as List).map((e) => e['rating'] as int).toList();
    if (ratings.isEmpty) return {'avg': 0.0, 'count': 0};
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    return {'avg': avg, 'count': ratings.length};
  }

  Future<void> addReview({
    required int productId,
    int? orderId,
    required int rating,
    String? comment,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    await _supabase.from('reviews').insert({
      'user_id': userId,
      'product_id': productId,
      if (orderId != null) 'order_id': orderId,
      'rating': rating,
      'comment': comment ?? '',
    });
  }

  Future<bool> hasReviewed(int productId, int orderId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    final data = await _supabase
        .from('reviews')
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId)
        .eq('order_id', orderId)
        .maybeSingle();
    return data != null;
  }
}