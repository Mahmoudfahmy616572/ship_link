// To parse this JSON data, do
//
//     final signUpDriver = signUpDriverFromJson(jsonString);

import 'dart:convert';

SignUpDriver signUpDriverFromJson(String str) =>
    SignUpDriver.fromJson(json.decode(str));

String signUpDriverToJson(SignUpDriver data) => json.encode(data.toJson());

class SignUpDriver {
  String? message;
  String? token;
  User? user;

  SignUpDriver({
    this.message,
    this.token,
    this.user,
  });

  factory SignUpDriver.fromJson(Map<String, dynamic> json) => SignUpDriver(
        message: json["message"],
        token: json["token"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "token": token,
        "user": user?.toJson(),
      };
}

class User {
  String? name;
  String? email;
  String? phoneNumber;
  String? stateId;
  String? gender;
  String? code;
  String? vehicleNumber;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;
  State? state;

  User({
    this.name,
    this.email,
    this.phoneNumber,
    this.stateId,
    this.gender,
    this.code,
    this.vehicleNumber,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.state,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        email: json["email"],
        phoneNumber: json["phone_number"],
        stateId: json["state_id"],
        gender: json["gender"],
        code: json["code"],
        vehicleNumber: json["vehicle_Number"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        id: json["id"],
        state: json["state"] == null ? null : State.fromJson(json["state"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "state_id": stateId,
        "gender": gender,
        "code": code,
        "vehicle_Number": vehicleNumber,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
        "state": state?.toJson(),
      };
}

class State {
  int? id;
  String? name;

  State({
    this.id,
    this.name,
  });

  factory State.fromJson(Map<String, dynamic> json) => State(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
