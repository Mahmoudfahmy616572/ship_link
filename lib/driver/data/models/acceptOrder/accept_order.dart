// To parse this JSON data, do
//
//     final acceptOrder = acceptOrderFromJson(jsonString);

import 'dart:convert';

AcceptOrder acceptOrderFromJson(String str) =>
    AcceptOrder.fromJson(json.decode(str));

String acceptOrderToJson(AcceptOrder data) => json.encode(data.toJson());

class AcceptOrder {
  int? data;
  String? message;
  int? status;

  AcceptOrder({
    this.data,
    this.message,
    this.status,
  });

  factory AcceptOrder.fromJson(Map<String, dynamic> json) => AcceptOrder(
        data: json["data"],
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "message": message,
        "status": status,
      };
}
