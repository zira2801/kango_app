// To parse this JSON data, do
//
//     final rechargeListModel = rechargeListModelFromJson(jsonString);

import 'dart:convert';

RechargeListModel rechargeListModelFromJson(String str) =>
    RechargeListModel.fromJson(json.decode(str));

String rechargeListModelToJson(RechargeListModel data) =>
    json.encode(data.toJson());

class RechargeListModel {
  int status;
  List<ItemRechargeModel> data;
  String message;

  RechargeListModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory RechargeListModel.fromJson(Map<String, dynamic> json) =>
      RechargeListModel(
        status: json["status"] ?? 0,
        data: json["data"] != null
            ? List<ItemRechargeModel>.from((json["data"] as List)
                .map((x) => ItemRechargeModel.fromJson(x)))
            : [],
        message: json["message"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
      };
}

class ItemRechargeModel {
  int rechargeId;
  int userId;
  int amount;
  String? note;
  String? image;
  int status;
  int? adminId;
  int activeFlg;
  int deleteFlg;
  DateTime? createdAt;
  DateTime? updatedAt;
  int type;
  String code;
  String? statusLabel;
  String? typeLabel;

  ItemRechargeModel({
    required this.rechargeId,
    required this.userId,
    required this.amount,
    this.note,
    this.image,
    required this.status,
    this.adminId,
    required this.activeFlg,
    required this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    required this.type,
    required this.code,
    this.statusLabel,
    this.typeLabel,
  });

  factory ItemRechargeModel.fromJson(Map<String, dynamic> json) =>
      ItemRechargeModel(
        rechargeId: json["recharge_id"] ?? 0,
        userId: json["user_id"] ?? 0,
        amount: json["amount"] ?? 0,
        note: json["note"],
        image: json["image"],
        status: json["status"] ?? 0,
        adminId: json["admin_id"] ?? 0, // Thêm giá trị mặc định
        activeFlg: json["active_flg"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"])
            : null,
        type: json["type"] ?? 0,
        code: json["code"] ?? '',
        statusLabel: json["status_label"],
        typeLabel: json["type_label"],
      );

  Map<String, dynamic> toJson() => {
        "recharge_id": rechargeId,
        "user_id": userId,
        "amount": amount,
        "note": note,
        "image": image,
        "status": status,
        "admin_id": adminId,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "type": type,
        "code": code,
        "status_label": statusLabel,
        "type_label": typeLabel,
      };
}
