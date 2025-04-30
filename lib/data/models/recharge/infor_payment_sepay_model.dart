// To parse this JSON data, do
//
//     final inforPaymentSePayModel = inforPaymentSePayModelFromJson(jsonString);

import 'dart:convert';

InforPaymentSePayModel inforPaymentSePayModelFromJson(String str) =>
    InforPaymentSePayModel.fromJson(json.decode(str));

String inforPaymentSePayModelToJson(InforPaymentSePayModel data) =>
    json.encode(data.toJson());

class InforPaymentSePayModel {
  int status;
  String message;
  String url;
  Recharge recharge;

  InforPaymentSePayModel({
    required this.status,
    required this.message,
    required this.url,
    required this.recharge,
  });

  factory InforPaymentSePayModel.fromJson(Map<String, dynamic> json) =>
      InforPaymentSePayModel(
        status: json["status"],
        message: json["message"],
        url: json["url"],
        recharge: Recharge.fromJson(json["recharge"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "url": url,
        "recharge": recharge.toJson(),
      };
}

class Recharge {
  int userId;
  int amount;
  String note;
  int type;
  int adminId;
  int activeFlg;
  String code;
  DateTime updatedAt;
  DateTime createdAt;
  int rechargeId;

  Recharge({
    required this.userId,
    required this.amount,
    required this.note,
    required this.type,
    required this.adminId,
    required this.activeFlg,
    required this.code,
    required this.updatedAt,
    required this.createdAt,
    required this.rechargeId,
  });

  factory Recharge.fromJson(Map<String, dynamic> json) => Recharge(
        userId: json["user_id"],
        amount: json["amount"],
        note: json["note"],
        type: json["type"],
        adminId: json["admin_id"],
        activeFlg: json["active_flg"],
        code: json["code"],
        updatedAt: DateTime.parse(json["updated_at"]),
        createdAt: DateTime.parse(json["created_at"]),
        rechargeId: json["recharge_id"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "amount": amount,
        "note": note,
        "type": type,
        "admin_id": adminId,
        "active_flg": activeFlg,
        "code": code,
        "updated_at": updatedAt.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "recharge_id": rechargeId,
      };
}
