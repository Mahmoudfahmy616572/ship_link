// To parse this JSON data, do
//
//     final signIn = signInFromJson(jsonString);

import 'dart:convert';

SignIn signInFromJson(String str) => SignIn.fromJson(json.decode(str));

String signInToJson(SignIn data) => json.encode(data.toJson());

class SignIn {
    String? message;
    String? token;
    User? user;

    SignIn({
        this.message,
        this.token,
        this.user,
    });

    factory SignIn.fromJson(Map<String, dynamic> json) => SignIn(
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
    int? id;
    String? firstName;
    String? lastName;
    dynamic username;
    String? email;
    String? phoneNumber;
    DateTime? emailVerifiedAt;
    dynamic twoFactorSecret;
    dynamic twoFactorRecoveryCodes;
    String? address;
    String? gender;
    String? code;
    dynamic providerId;
    dynamic state;
    dynamic passwordConfirmation;
    dynamic expire;
    DateTime? createdAt;
    DateTime? updatedAt;
    dynamic socialId;
    dynamic socialType;
    int? activeStatus;
    String? avatar;
    int? darkMode;
    dynamic messengerColor;

    User({
        this.id,
        this.firstName,
        this.lastName,
        this.username,
        this.email,
        this.phoneNumber,
        this.emailVerifiedAt,
        this.twoFactorSecret,
        this.twoFactorRecoveryCodes,
        this.address,
        this.gender,
        this.code,
        this.providerId,
        this.state,
        this.passwordConfirmation,
        this.expire,
        this.createdAt,
        this.updatedAt,
        this.socialId,
        this.socialType,
        this.activeStatus,
        this.avatar,
        this.darkMode,
        this.messengerColor,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        username: json["username"],
        email: json["email"],
        phoneNumber: json["phone_number"],
        emailVerifiedAt: json["email_verified_at"] == null ? null : DateTime.parse(json["email_verified_at"]),
        twoFactorSecret: json["two_factor_secret"],
        twoFactorRecoveryCodes: json["two_factor_recovery_codes"],
        address: json["address"],
        gender: json["gender"],
        code: json["code"],
        providerId: json["provider_id"],
        state: json["state"],
        passwordConfirmation: json["password_confirmation"],
        expire: json["expire"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        socialId: json["social_id"],
        socialType: json["social_type"],
        activeStatus: json["active_status"],
        avatar: json["avatar"],
        darkMode: json["dark_mode"],
        messengerColor: json["messenger_color"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "username": username,
        "email": email,
        "phone_number": phoneNumber,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "two_factor_secret": twoFactorSecret,
        "two_factor_recovery_codes": twoFactorRecoveryCodes,
        "address": address,
        "gender": gender,
        "code": code,
        "provider_id": providerId,
        "state": state,
        "password_confirmation": passwordConfirmation,
        "expire": expire,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "social_id": socialId,
        "social_type": socialType,
        "active_status": activeStatus,
        "avatar": avatar,
        "dark_mode": darkMode,
        "messenger_color": messengerColor,
    };
}
