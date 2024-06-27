// To parse this JSON data, do
//
//     final confirmCart = confirmCartFromJson(jsonString);

import 'dart:convert';

ConfirmCart confirmCartFromJson(String str) =>
    ConfirmCart.fromJson(json.decode(str));

String confirmCartToJson(ConfirmCart data) => json.encode(data.toJson());

class ConfirmCart {
  String? success;
  Order? order;

  ConfirmCart({
    this.success,
    this.order,
  });

  factory ConfirmCart.fromJson(Map<String, dynamic> json) => ConfirmCart(
        success: json["success"],
        order: json["order"] == null ? null : Order.fromJson(json["order"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "order": order?.toJson(),
      };
}

class Order {
  int? userId;
  String? cartId;
  int? totalPrice;
  String? status;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;

  Order({
    this.userId,
    this.cartId,
    this.totalPrice,
    this.status,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        userId: json["user_id"],
        cartId: json["cart_id"],
        totalPrice: json["total_price"],
        status: json["status"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "cart_id": cartId,
        "total_price": totalPrice,
        "status": status,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
      };
}
