// To parse this JSON data, do
//
//     final getTopSeller = getTopSellerFromJson(jsonString);

import 'dart:convert';

GetTopSeller getTopSellerFromJson(String str) =>
    GetTopSeller.fromJson(json.decode(str));

String getTopSellerToJson(GetTopSeller data) => json.encode(data.toJson());

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
  int? price;
  int? isOffer;
  dynamic newPrice;
  int? qty;
  int? status;
  int? popular;
  int? providerId;
  dynamic createdAt;
  DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  factory TopSeller.fromJson(Map<String, dynamic> json) => TopSeller(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        price: json["price"],
        isOffer: json["is_offer"],
        newPrice: json["new_price"],
        qty: json["qty"],
        status: json["status"],
        popular: json["popular"],
        providerId: json["provider_id"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
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
        "created_at": createdAt,
        "updated_at": updatedAt?.toIso8601String(),
      };
}
