// To parse this JSON data, do
//
//     final getuserDriverData = getuserDriverDataFromJson(jsonString);

import 'dart:convert';

GetuserDriverData getuserDriverDataFromJson(String str) =>
    GetuserDriverData.fromJson(json.decode(str));

String getuserDriverDataToJson(GetuserDriverData data) =>
    json.encode(data.toJson());

class GetuserDriverData {
  Data? data;
  String? message;
  int? status;

  GetuserDriverData({
    this.data,
    this.message,
    this.status,
  });

  factory GetuserDriverData.fromJson(Map<String, dynamic> json) =>
      GetuserDriverData(
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
  int? id;
  dynamic fullname;
  String? name;
  String? email;
  dynamic emailVerifiedAt;
  String? gender;
  String? vehicleType;
  String? vehicleNumber;
  dynamic city;
  dynamic postalCode;
  int? stateId;
  dynamic passwordConfirmation;
  dynamic expirationMonth;
  dynamic expirationYear;
  String? phoneNumber;
  String? code;
  dynamic expire;
  String? accountType;
  DateTime? createdAt;
  DateTime? updatedAt;
  State? state;

  Data({
    this.id,
    this.fullname,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.gender,
    this.vehicleType,
    this.vehicleNumber,
    this.city,
    this.postalCode,
    this.stateId,
    this.passwordConfirmation,
    this.expirationMonth,
    this.expirationYear,
    this.phoneNumber,
    this.code,
    this.expire,
    this.accountType,
    this.createdAt,
    this.updatedAt,
    this.state,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        fullname: json["fullname"],
        name: json["name"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        gender: json["gender"],
        vehicleType: json["vehicle_type"],
        vehicleNumber: json["vehicle_Number"],
        city: json["city"],
        postalCode: json["postal_code"],
        stateId: json["state_id"],
        passwordConfirmation: json["password_confirmation"],
        expirationMonth: json["Expiration_month"],
        expirationYear: json["Expiration_year"],
        phoneNumber: json["phone_number"],
        code: json["code"],
        expire: json["expire"],
        accountType: json["account_type"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        state: json["state"] == null ? null : State.fromJson(json["state"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "name": name,
        "email": email,
        "email_verified_at": emailVerifiedAt,
        "gender": gender,
        "vehicle_type": vehicleType,
        "vehicle_Number": vehicleNumber,
        "city": city,
        "postal_code": postalCode,
        "state_id": stateId,
        "password_confirmation": passwordConfirmation,
        "Expiration_month": expirationMonth,
        "Expiration_year": expirationYear,
        "phone_number": phoneNumber,
        "code": code,
        "expire": expire,
        "account_type": accountType,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "state": state?.toJson(),
      };
}

class State {
  int? id;
  String? name;
  dynamic createdAt;
  dynamic updatedAt;

  State({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory State.fromJson(Map<String, dynamic> json) => State(
        id: json["id"],
        name: json["name"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
