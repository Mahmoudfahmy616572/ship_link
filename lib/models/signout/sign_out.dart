// To parse this JSON data, do
//
//     final signOut = signOutFromJson(jsonString);

import 'dart:convert';

SignOut signOutFromJson(String str) => SignOut.fromJson(json.decode(str));

String signOutToJson(SignOut data) => json.encode(data.toJson());

class SignOut {
    String? message;

    SignOut({
        this.message,
    });

    factory SignOut.fromJson(Map<String, dynamic> json) => SignOut(
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
    };
}
