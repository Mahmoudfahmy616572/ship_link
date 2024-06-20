// To parse this JSON data, do
//
//     final allProducts = allProductsFromJson(jsonString);

import 'dart:convert';

AllProducts allProductsFromJson(String str) => AllProducts.fromJson(json.decode(str));

String allProductsToJson(AllProducts data) => json.encode(data.toJson());

class AllProducts {
    Products? products;

    AllProducts({
        this.products,
    });

    factory AllProducts.fromJson(Map<String, dynamic> json) => AllProducts(
        products: json["Products"] == null ? null : Products.fromJson(json["Products"]),
    );

    Map<String, dynamic> toJson() => {
        "Products": products?.toJson(),
    };
}

class Products {
    int? productscount;
    List<Product>? products;

    Products({
        this.productscount,
        this.products,
    });

    factory Products.fromJson(Map<String, dynamic> json) => Products(
        productscount: json["Productscount"],
        products: json["Products"] == null ? [] : List<Product>.from(json["Products"]!.map((x) => Product.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Productscount": productscount,
        "Products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    };
}

class Product {
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

    Product({
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

    factory Product.fromJson(Map<String, dynamic> json) => Product(
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
