// To parse this JSON data, do
//
//     final cartProducts = cartProductsFromJson(jsonString);

import 'dart:convert';

CartProducts cartProductsFromJson(String str) => CartProducts.fromJson(json.decode(str));

String cartProductsToJson(CartProducts data) => json.encode(data.toJson());

class CartProducts {
    Cart? cart;
    List<Detail>? details;

    CartProducts({
        this.cart,
        this.details,
    });

    factory CartProducts.fromJson(Map<String, dynamic> json) => CartProducts(
        cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
        details: json["details"] == null ? [] : List<Detail>.from(json["details"]!.map((x) => Detail.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "cart": cart?.toJson(),
        "details": details == null ? [] : List<dynamic>.from(details!.map((x) => x.toJson())),
    };
}

class Cart {
    int? id;
    int? userId;
    int? status;
    int? isOpen;
    DateTime? createdAt;
    DateTime? updatedAt;

    Cart({
        this.id,
        this.userId,
        this.status,
        this.isOpen,
        this.createdAt,
        this.updatedAt,
    });

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: json["id"],
        userId: json["user_id"],
        status: json["status"],
        isOpen: json["is_open"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "status": status,
        "is_open": isOpen,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class Detail {
    int? id;
    int? cartId;
    Product? product;
    int? qty;
    double? totalPrice;
    int? isOpen;

    Detail({
        this.id,
        this.cartId,
        this.product,
        this.qty,
        this.totalPrice,
        this.isOpen,
    });

    factory Detail.fromJson(Map<String, dynamic> json) => Detail(
        id: json["id"],
        cartId: json["cart_id"],
        product: json["product"] == null ? null : Product.fromJson(json["product"]),
        qty: json["qty"],
        totalPrice: json["total_price"]?.toDouble(),
        isOpen: json["is_open"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "cart_id": cartId,
        "product": product?.toJson(),
        "qty": qty,
        "total_price": totalPrice,
        "is_open": isOpen,
    };
}

class Product {
    int? id;
    String? image;
    String? name;

    Product({
        this.id,
        this.image,
        this.name,
    });

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        image: json["image"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "name": name,
    };
}
