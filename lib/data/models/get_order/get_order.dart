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
  String? userId;
  int? cartId;
  int? totalPrice;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;
  String? deliveryAddress;
  double? deliveryLat;
  double? deliveryLng;
  String? addressLabel;

  Order({
    this.id,
    this.userId,
    this.cartId,
    this.totalPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    this.addressLabel,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: (json["id"] as num?)?.toInt(),
        userId: json["user_id"]?.toString(),
        cartId: (json["cart_id"] as num?)?.toInt(),
        totalPrice: (json["total_price"] as num?)?.toInt(),
        status: json["status"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        user: json["profiles"] == null ? null : User.fromJson(json["profiles"]),
        deliveryAddress: json["delivery_address"],
        deliveryLat: (json["delivery_lat"] as num?)?.toDouble(),
        deliveryLng: (json["delivery_lng"] as num?)?.toDouble(),
        addressLabel: json["address_label"],
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
        "delivery_address": deliveryAddress,
        "delivery_lat": deliveryLat,
        "delivery_lng": deliveryLng,
        "address_label": addressLabel,
      };
}

class User {
  String? id;
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
        id: json["id"]?.toString(),
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
