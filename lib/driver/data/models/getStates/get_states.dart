// To parse this JSON data, do
//
//     final getStates = getStatesFromJson(jsonString);

import 'dart:convert';

GetStates getStatesFromJson(String str) => GetStates.fromJson(json.decode(str));

String getStatesToJson(GetStates data) => json.encode(data.toJson());

class GetStates {
  List<Datum>? data;
  String? message;
  int? status;

  GetStates({
    this.data,
    this.message,
    this.status,
  });

  factory GetStates.fromJson(Map<String, dynamic> json) => GetStates(
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        message: json["message"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class Datum {
  int? id;
  String? name;

  Datum({
    this.id,
    this.name,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
