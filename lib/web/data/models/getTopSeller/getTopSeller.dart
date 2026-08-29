// To parse this JSON data, do
//
//     final getTopSeller = getTopSellerFromJson(jsonString);

import 'dart:convert';

GetTopSeller getTopSellerFromJson(String str) =>
    GetTopSeller.fromJson(json.decode(str));

String getTopSellerToJson(GetTopSeller data) => json.encode(data.toJson());

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

class GetTopSeller {
  List<TopSeller>? topSellers;

  GetTopSeller({
    this.topSellers,
  });

  factory GetTopSeller.fromJson(Map<String, dynamic> json) => GetTopSeller(
        topSellers: json["top_sellers"] == null
            ? []
            : List<TopSeller>.from(
                json["top_sellers"]!.map((x) => TopSeller.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "top_sellers": topSellers == null
            ? []
            : List<dynamic>.from(topSellers!.map((x) => x.toJson())),
      };
}

class TopSeller {
  int? id;
  String? name;
  String? description;
  String? image;
  double? price;
  int? isOffer;
  double? newPrice;
  int? qty;
  int? status;
  int? popular;
  int? providerId;
  String? category;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<String>? images;

  TopSeller({
    this.id,
    this.name,
    this.description,
    this.image,
    this.price,
    this.isOffer,
    this.newPrice,
    this.qty,
    this.status,
    this.popular,
    this.providerId,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.images,
  });

  List<String> get imageList {
    if (images != null && images!.isNotEmpty) return images!;
    if (image != null) return [image!];
    return [];
  }

  factory TopSeller.fromJson(Map<String, dynamic> json) => TopSeller(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        price: _toDouble(json["price"]),
        isOffer: _toInt(json["is_offer"]),
        newPrice: _toDouble(json["new_price"]),
        qty: _toInt(json["qty"]),
        status: _toInt(json["status"]),
        popular: _toInt(json["popular"]),
        providerId: _toInt(json["provider_id"]),
        category: json["category"],
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"]),
        images: json["images"] == null ? null : List<String>.from(json["images"]!.map((x) => x.toString())),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "image": image,
        "price": price,
        "is_offer": isOffer,
        "new_price": newPrice,
        "qty": qty,
        "status": status,
        "popular": popular,
        "provider_id": providerId,
        "category": category,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "images": images,
      };
}
