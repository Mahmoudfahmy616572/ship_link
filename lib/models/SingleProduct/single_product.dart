// To parse this JSON data, do
//
//     final singleProduct = singleProductFromJson(jsonString);

import 'dart:convert';

SingleProduct singleProductFromJson(String str) => SingleProduct.fromJson(json.decode(str));

String singleProductToJson(SingleProduct data) => json.encode(data.toJson());

class SingleProduct {
    Products? products;

    SingleProduct({
        this.products,
    });

    factory SingleProduct.fromJson(Map<String, dynamic> json) => SingleProduct(
        products: json["Products"] == null ? null : Products.fromJson(json["Products"]),
    );

    Map<String, dynamic> toJson() => {
        "Products": products?.toJson(),
    };
}

class Products {
    int? id;
    String? name;
    String? description;
    String? image;
    double? price;
    int? isOffer;
    double? newPrice;
    int? qty;
    int? status;
    int? providerId;
    DateTime? createdAt;
    DateTime? updatedAt;

    Products({
        this.id,
        this.name,
        this.description,
        this.image,
        this.price,
        this.isOffer,
        this.newPrice,
        this.qty,
        this.status,
        this.providerId,
        this.createdAt,
        this.updatedAt,
    });

    factory Products.fromJson(Map<String, dynamic> json) => Products(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        image: json["image"],
        price: json["price"]?.toDouble(),
        isOffer: json["is_offer"],
        newPrice: json["new_price"]?.toDouble(),
        qty: json["qty"],
        status: json["status"],
        providerId: json["provider_id"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
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
        "provider_id": providerId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
