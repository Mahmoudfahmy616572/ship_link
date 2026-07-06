import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/user/data/models/review/review_model.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<Review>>> getReviews(int productId);
  Future<Either<Failure, Map<String, dynamic>>> getProductRating(int productId);
  Future<Either<Failure, void>> addReview({
    required int productId,
    int? orderId,
    required int rating,
    String? comment,
  });
  Future<Either<Failure, bool>> hasReviewed(int productId, int orderId);
}
