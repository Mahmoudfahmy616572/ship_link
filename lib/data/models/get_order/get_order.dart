// To parse this JSON data, do
//
//     final getOrder = getOrderFromJson(jsonString);

import 'dart:convert';

GetOrder getOrderFromJson(String str) => GetOrder.fromJson(json.decode(str));

String getOrderToJson(GetOrder data) => json.encode(data.toJson());

class GetOrder {
  Data? data;
  String? message;
  int? status;

  GetOrder({
    this.data,
    this.message,
    this.status,
  });

  factory GetOrder.fromJson(Map<String, dynamic> json) => GetOrder(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "message": message,
        "status": status,
      };
}

class Data {
  List<dynamic>? orderShipping;
  List<Order>? order;

  Data({
    this.orderShipping,
    this.order,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderShipping: json["OrderShipping"] == null
            ? []
            : List<dynamic>.from(json["OrderShipping"]!.map((x) => x)),
        order: json["order"] == null
            ? []
            : List<Order>.from(json["order"]!.map((x) => Order.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "OrderShipping": orderShipping == null
            ? []
            : List<dynamic>.from(orderShipping!.map((x) => x)),
        "order": order == null
            ? []
            : List<dynamic>.from(order!.map((x) => x.toJson())),
      };
}

class Order {
  int? id;
  int? userId;
  int? cartId;
  int? totalPrice;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;

  Order({
    this.id,
    this.userId,
    this.cartId,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        userId: json["user_id"],
        cartId: json["cart_id"],
        totalPrice: json["total_price"],
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "cart_id": cartId,
        "total_price": totalPrice,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "user": user?.toJson(),
      };
}

class User {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        phoneNumber: json["phone_number"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone_number": phoneNumber,
      };
}
