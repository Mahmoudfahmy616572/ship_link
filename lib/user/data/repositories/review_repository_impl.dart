import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/user/data/models/review/review_model.dart';
import 'package:ship_link/user/domain/repositories/review_repository.dart';
import 'package:ship_link/user/data/datasources/review_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRepositoryImpl extends ReviewRepository {
  final _dataSource = ReviewRemoteDataSource();

  @override
  Future<Either<Failure, List<Review>>> getReviews(int productId) async {
    try {
      final data = await _dataSource.getReviews(productId);
      return right((data).map((e) => Review.fromJson(e)).toList());
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProductRating(int productId) async {
    try {
      final data = await _dataSource.getRatings(productId);
      final ratings = data.map((e) => e['rating'] as int).toList();
      if (ratings.isEmpty) return right({'avg': 0.0, 'count': 0});
      final avg = ratings.reduce((a, b) => a + b) / ratings.length;
      return right({'avg': avg, 'count': ratings.length});
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addReview({
    required int productId,
    int? orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return left(ServerFailure('Not authenticated'));
      await _dataSource.insertReview({
        'user_id': userId,
        'product_id': productId,
        if (orderId != null) 'order_id': orderId,
        'rating': rating,
        'comment': comment ?? '',
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasReviewed(int productId, int orderId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return right(false);
      final existing = await _dataSource.findExisting(userId, productId, orderId);
      return right(existing != null);
    } catch (e) {
      return right(false);
    }
  }
}
