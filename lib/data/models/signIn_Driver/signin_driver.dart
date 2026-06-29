import 'dart:convert';

SigninDriver signinDriverFromJson(String str) =>
    SigninDriver.fromJson(json.decode(str));

String signinDriverToJson(SigninDriver data) => json.encode(data.toJson());

class SigninDriver {
  String? message;
  String? token;
  User? user;

  SigninDriver({
    this.message,
    this.token,
    this.user,
  });

  factory SigninDriver.fromJson(Map<String, dynamic> json) => SigninDriver(
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
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? vehicleType;
  String? vehicleNumber;
  String? state;
  DateTime? createdAt;
  DateTime? updatedAt;

  User({
    this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.vehicleType,
    this.vehicleNumber,
    this.state,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phoneNumber: json["phone_number"],
        vehicleType: json["vehicle_type"],
        vehicleNumber: json["vehicle_number"],
        state: json["state"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone_number": phoneNumber,
        "vehicle_type": vehicleType,
        "vehicle_number": vehicleNumber,
        "state": state,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
