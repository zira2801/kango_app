// To parse this JSON data, do
//
//     final getDataDetailsSePayModel = getDataDetailsSePayModelFromJson(jsonString);

import 'dart:convert';

GetDataDetailsSePayModel getDataDetailsSePayModelFromJson(String str) =>
    GetDataDetailsSePayModel.fromJson(json.decode(str));

String getDataDetailsSePayModelToJson(GetDataDetailsSePayModel data) =>
    json.encode(data.toJson());

class GetDataDetailsSePayModel {
  int status;
  Recharge recharge;
  BankAccountDetail bankAccountDetail;
  int timeExpiredPayment;
  String code;

  GetDataDetailsSePayModel({
    required this.status,
    required this.recharge,
    required this.bankAccountDetail,
    required this.timeExpiredPayment,
    required this.code,
  });

  factory GetDataDetailsSePayModel.fromJson(Map<String, dynamic> json) =>
      GetDataDetailsSePayModel(
        status: json["status"],
        recharge: Recharge.fromJson(json["recharge"]),
        bankAccountDetail:
            BankAccountDetail.fromJson(json["bank_account_detail"]),
        timeExpiredPayment: json["time_expired_payment"],
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "recharge": recharge.toJson(),
        "bank_account_detail": bankAccountDetail.toJson(),
        "time_expired_payment": timeExpiredPayment,
        "code": code
      };
}

class BankAccountDetail {
  String id;
  String accountHolderName;
  String accountNumber;
  String accumulated;
  DateTime lastTransaction;
  String label;
  String active;
  DateTime createdAt;
  String bankShortName;
  String bankFullName;
  String bankBin;
  String bankCode;

  BankAccountDetail({
    required this.id,
    required this.accountHolderName,
    required this.accountNumber,
    required this.accumulated,
    required this.lastTransaction,
    required this.label,
    required this.active,
    required this.createdAt,
    required this.bankShortName,
    required this.bankFullName,
    required this.bankBin,
    required this.bankCode,
  });

  factory BankAccountDetail.fromJson(Map<String, dynamic> json) =>
      BankAccountDetail(
        id: json["id"],
        accountHolderName: json["account_holder_name"],
        accountNumber: json["account_number"],
        accumulated: json["accumulated"],
        lastTransaction: DateTime.parse(json["last_transaction"]),
        label: json["label"],
        active: json["active"],
        createdAt: DateTime.parse(json["created_at"]),
        bankShortName: json["bank_short_name"],
        bankFullName: json["bank_full_name"],
        bankBin: json["bank_bin"],
        bankCode: json["bank_code"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "account_holder_name": accountHolderName,
        "account_number": accountNumber,
        "accumulated": accumulated,
        "last_transaction": lastTransaction.toIso8601String(),
        "label": label,
        "active": active,
        "created_at": createdAt.toIso8601String(),
        "bank_short_name": bankShortName,
        "bank_full_name": bankFullName,
        "bank_bin": bankBin,
        "bank_code": bankCode,
      };
}

class Recharge {
  int rechargeId;
  int userId;
  int amount;
  String note;
  dynamic image;
  int status;
  int adminId;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  int type;
  String code;
  dynamic adminNote;
  dynamic priceOther;
  dynamic sepayTransactionId;

  Recharge({
    required this.rechargeId,
    required this.userId,
    required this.amount,
    required this.note,
    required this.image,
    required this.status,
    required this.adminId,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.type,
    required this.code,
    required this.adminNote,
    required this.priceOther,
    required this.sepayTransactionId,
  });

  factory Recharge.fromJson(Map<String, dynamic> json) => Recharge(
        rechargeId: json["recharge_id"],
        userId: json["user_id"],
        amount: json["amount"],
        note: json["note"],
        image: json["image"],
        status: json["status"],
        adminId: json["admin_id"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        type: json["type"],
        code: json["code"],
        adminNote: json["admin_note"],
        priceOther: json["price_other"],
        sepayTransactionId: json["sepay_transaction_id"],
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
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "type": type,
        "code": code,
        "admin_note": adminNote,
        "price_other": priceOther,
        "sepay_transaction_id": sepayTransactionId,
      };
}
