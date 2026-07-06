import 'dart:convert';

UpDateUserData upDateUserDataFromJson(String str) =>
    UpDateUserData.fromJson(json.decode(str));

String upDateUserDataToJson(UpDateUserData data) => json.encode(data.toJson());

class UpDateUserData {
  Data? data;
  String? message;
  int? status;

  UpDateUserData({
    this.data,
    this.message,
    this.status,
  });

  factory UpDateUserData.fromJson(Map<String, dynamic> json) => UpDateUserData(
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
  String? id;
  String? name;
  String? email;
  String? phoneNumber;
  String? vehicleType;
  String? vehicleNumber;
  String? state;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
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
