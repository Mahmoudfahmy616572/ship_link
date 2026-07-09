class Review {
  final int? id;
  final String? userId;
  final int? productId;
  final int? orderId;
  final int rating;
  final String? comment;
  final String? createdAt;
  final Map<String, dynamic>? user;

  Review({
    this.id,
    this.userId,
    this.productId,
    this.orderId,
    required this.rating,
    this.comment,
    this.createdAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      productId: json['product_id'] as int?,
      orderId: json['order_id'] as int?,
      rating: json['rating'] as int? ?? 5,
      comment: json['comment'] as String?,
      createdAt: json['created_at'] as String?,
      user: json['profiles'] as Map<String, dynamic>?,
    );
  }
}
