class FavouriteItem {
  final int id;
  final String userId;
  final int productId;
  final String? productName;
  final String? productImage;
  final double? productPrice;
  final DateTime? createdAt;

  FavouriteItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.productName,
    this.productImage,
    this.productPrice,
    this.createdAt,
  });

  factory FavouriteItem.fromJson(Map<String, dynamic> json) {
    final product = json['products'] as Map<String, dynamic>?;
    return FavouriteItem(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      productId: json['product_id'] as int,
      productName: product?['name'] as String?,
      productImage: product?['image'] as String?,
      productPrice: (product?['price'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }
}
