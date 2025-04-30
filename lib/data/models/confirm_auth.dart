// To parse this JSON data, do
//
//     final confirmOtpAuthModel = confirmOtpAuthModelFromJson(jsonString);

import 'dart:convert';

ConfirmOtpAuthModel confirmOtpAuthModelFromJson(String str) =>
    ConfirmOtpAuthModel.fromJson(json.decode(str));

String confirmOtpAuthModelToJson(ConfirmOtpAuthModel data) =>
    json.encode(data.toJson());

class ConfirmOtpAuthModel {
  int status;
  String route;
  Otp otp;
  Message message;

  ConfirmOtpAuthModel({
    required this.status,
    required this.route,
    required this.otp,
    required this.message,
  });

  factory ConfirmOtpAuthModel.fromJson(Map<String, dynamic> json) =>
      ConfirmOtpAuthModel(
        status: json["status"],
        route: json["route"],
        otp: Otp.fromJson(json["otp"]),
        message: Message.fromJson(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "route": route,
        "otp": otp.toJson(),
        "message": message.toJson(),
      };
}

class Message {
  String title;
  String text;
  String icon;

  Message({
    required this.title,
    required this.text,
    required this.icon,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        title: json["title"],
        text: json["text"],
        icon: json["icon"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "text": text,
        "icon": icon,
      };
}

class Otp {
  int codeOtpId;
  String email;
  String token;
  DateTime createdAt;

  Otp({
    required this.codeOtpId,
    required this.email,
    required this.token,
    required this.createdAt,
  });

  factory Otp.fromJson(Map<String, dynamic> json) => Otp(
        codeOtpId: json["code_otp_id"],
        email: json["email"],
        token: json["token"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "code_otp_id": codeOtpId,
        "email": email,
        "token": token,
        "created_at": createdAt.toIso8601String(),
      };
}
