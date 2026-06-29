// To parse this JSON data, do
//
//     final getFromCart = getFromCartFromJson(jsonString);

import 'dart:convert';

GetFromCart getFromCartFromJson(String str) => GetFromCart.fromJson(json.decode(str));

String getFromCartToJson(GetFromCart data) => json.encode(data.toJson());

class GetFromCart {
    Cart? cart;
    List<Detail>? details;

    GetFromCart({
        this.cart,
        this.details,
    });

    factory GetFromCart.fromJson(Map<String, dynamic> json) => GetFromCart(
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
    String? userId;
    int? status;
    double? totalPrice;
    int? isOpen;
    DateTime? createdAt;
    DateTime? updatedAt;

    Cart({
        this.id,
        this.userId,
        this.status,
        this.totalPrice,
        this.isOpen,
        this.createdAt,
        this.updatedAt,
    });

    factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        id: (json["id"] as num?)?.toInt(),
        userId: json["user_id"]?.toString(),
        status: json["status"],
        totalPrice: (json["totalPrice"] as num?)?.toDouble(),
        isOpen: json["is_open"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "status": status,
        "totalPrice": totalPrice,
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
        id: (json["id"] as num?)?.toInt(),
        cartId: (json["id"] as num?)?.toInt(),
        product: (json["products"] ?? json["product"]) == null
            ? null
            : Product.fromJson(json["products"] ?? json["product"]),
        qty: json["quantity"],
        totalPrice: (json["total_price"] as num?)?.toDouble(),
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
    double? price;
    String? category;
    List<String>? images;

    Product({
        this.id,
        this.image,
        this.name,
        this.price,
        this.category,
        this.images,
    });

    List<String> get imageList {
      if (images != null && images!.isNotEmpty) return images!;
      if (image != null) return [image!];
      return [];
    }

    factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        image: json["image"],
        name: json["name"],
        price: json["price"]?.toDouble(),
        category: json["category"],
        images: json["images"] == null ? null : List<String>.from(json["images"]!.map((x) => x.toString())),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "name": name,
        "price": price,
        "category": category,
        "images": images,
    };
}
