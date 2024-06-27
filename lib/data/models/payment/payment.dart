// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  String? url;
  String? message;

  Payment({
    this.url,
    this.message,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        url: json["url"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "message": message,
      };
}
