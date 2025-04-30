// To parse this JSON data, do
//
//     final resStatusVnPayModel = resStatusVnPayModelFromJson(jsonString);

import 'dart:convert';

ResStatusVnPayModel resStatusVnPayModelFromJson(String str) =>
    ResStatusVnPayModel.fromJson(json.decode(str));

String resStatusVnPayModelToJson(ResStatusVnPayModel data) =>
    json.encode(data.toJson());

class ResStatusVnPayModel {
  int status;
  Data data;
  String? message;

  ResStatusVnPayModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory ResStatusVnPayModel.fromJson(Map<String, dynamic> json) =>
      ResStatusVnPayModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "message": message,
      };
}

class Data {
  Recharge recharge;
  Admin user;
  Admin admin;

  Data({
    required this.recharge,
    required this.user,
    required this.admin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        recharge: Recharge.fromJson(json["recharge"]),
        user: Admin.fromJson(json["user"]),
        admin: Admin.fromJson(json["admin"]),
      );

  Map<String, dynamic> toJson() => {
        "recharge": recharge.toJson(),
        "user": user.toJson(),
        "admin": admin.toJson(),
      };
}

class Admin {
  int userId;
  String userName;
  String userCode;
  String userApiKey;
  int positionId;
  int branchId;
  String userContactName;
  String userPhone;
  String? userAddress;
  String? userSignature;
  int? userLimitAmountForSale;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic userAccountantKey;
  String? userCompanyName;
  dynamic userTaxCode;
  String userAddress1;
  String userAddress2;
  dynamic userAddress3;
  dynamic userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  int? userRemainingLimit;
  dynamic userPriceListChangeDate;
  String? positionName;

  Admin({
    required this.userId,
    required this.userName,
    required this.userCode,
    required this.userApiKey,
    required this.positionId,
    required this.branchId,
    required this.userContactName,
    required this.userPhone,
    required this.userAddress,
    required this.userSignature,
    required this.userLimitAmountForSale,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.userAccountantKey,
    required this.userCompanyName,
    required this.userTaxCode,
    required this.userAddress1,
    required this.userAddress2,
    required this.userAddress3,
    required this.userLogo,
    required this.userDebitType,
    required this.userPriceListMainType,
    required this.userPriceListChangeType,
    required this.userRemainingLimit,
    required this.userPriceListChangeDate,
    this.positionName,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        userId: json["user_id"],
        userName: json["user_name"],
        userCode: json["user_code"],
        userApiKey: json["user_api_key"],
        positionId: json["position_id"],
        branchId: json["branch_id"],
        userContactName: json["user_contact_name"],
        userPhone: json["user_phone"],
        userAddress: json["user_address"],
        userSignature: json["user_signature"],
        userLimitAmountForSale: json["user_limit_amount_for_sale"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        userAccountantKey: json["user_accountant_key"],
        userCompanyName: json["user_company_name"],
        userTaxCode: json["user_tax_code"],
        userAddress1: json["user_address_1"],
        userAddress2: json["user_address_2"],
        userAddress3: json["user_address_3"],
        userLogo: json["user_logo"],
        userDebitType: json["user_debit_type"],
        userPriceListMainType: json["user_price_list_main_type"],
        userPriceListChangeType: json["user_price_list_change_type"],
        userRemainingLimit: json["user_remaining_limit"],
        userPriceListChangeDate: json["user_price_list_change_date"],
        positionName: json["position_name"],
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_name": userName,
        "user_code": userCode,
        "user_api_key": userApiKey,
        "position_id": positionId,
        "branch_id": branchId,
        "user_contact_name": userContactName,
        "user_phone": userPhone,
        "user_address": userAddress,
        "user_signature": userSignature,
        "user_limit_amount_for_sale": userLimitAmountForSale,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user_accountant_key": userAccountantKey,
        "user_company_name": userCompanyName,
        "user_tax_code": userTaxCode,
        "user_address_1": userAddress1,
        "user_address_2": userAddress2,
        "user_address_3": userAddress3,
        "user_logo": userLogo,
        "user_debit_type": userDebitType,
        "user_price_list_main_type": userPriceListMainType,
        "user_price_list_change_type": userPriceListChangeType,
        "user_remaining_limit": userRemainingLimit,
        "user_price_list_change_date": userPriceListChangeDate,
        "position_name": positionName,
      };
}

class Recharge {
  int rechargeId;
  int userId;
  int? amount;
  String? note;
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
  String statusLabel;
  String typeLabel;

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
    required this.statusLabel,
    required this.typeLabel,
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
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "type": type,
        "code": code,
        "admin_note": adminNote,
        "status_label": statusLabel,
        "type_label": typeLabel,
      };
}
