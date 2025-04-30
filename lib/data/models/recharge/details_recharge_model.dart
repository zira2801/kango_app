// To parse this JSON data, do
//
//     final detailsDataRechargeModel = detailsDataRechargeModelFromJson(jsonString);

import 'dart:convert';

DetailsDataRechargeModel detailsDataRechargeModelFromJson(String str) =>
    DetailsDataRechargeModel.fromJson(json.decode(str));

String detailsDataRechargeModelToJson(DetailsDataRechargeModel data) =>
    json.encode(data.toJson());

class DetailsDataRechargeModel {
  int status;
  Data data;
  String message;

  DetailsDataRechargeModel({
    required this.status,
    required this.data,
    required this.message,
  });

  factory DetailsDataRechargeModel.fromJson(Map<String, dynamic> json) =>
      DetailsDataRechargeModel(
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
  Recharge? recharge;
  Admin? user;
  List<Admin>? admin;

  Data({
    required this.recharge,
    required this.user,
    required this.admin,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        recharge: json["recharge"] != null
            ? Recharge.fromJson(json["recharge"])
            : null,
        user: json['user'] != null ? Admin.fromJson(json["user"]) : null,
        admin: json["admin"] is List
            ? List<Admin>.from(json["admin"].map((x) => Admin.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "recharge": recharge!.toJson(),
        "user": user!.toJson(),
        "admin": admin != null
            ? List<dynamic>.from(admin!.map((x) => x.toJson()))
            : [],
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
  String userAddress;
  String userLatitude;
  String userLongitude;
  dynamic userSignature;
  int userLimitAmountForSale;
  int activeFlg;
  int userPendingApproval;
  int deleteFlg;
  DateTime? createdAt;
  DateTime? updatedAt;
  String userAccountantKey;
  String userCompanyName;
  String userTaxCode;
  String userAddress1;
  String userAddress2;
  String userAddress3;
  String userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userPriceListChangeDate;
  int userRemainingLimit;
  dynamic userKpiId;
  int userIsFreeTime;
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
    required this.userLatitude,
    required this.userLongitude,
    required this.userSignature,
    required this.userLimitAmountForSale,
    required this.activeFlg,
    required this.userPendingApproval,
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
    required this.userPriceListChangeDate,
    required this.userRemainingLimit,
    required this.userKpiId,
    required this.userIsFreeTime,
    this.positionName,
  });

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        userId: json["user_id"] ?? 0,
        userName: json["user_name"] ?? '',
        userCode: json["user_code"] ?? '',
        userApiKey: json["user_api_key"] ?? '',
        positionId: json["position_id"] ?? 0,
        branchId: json["branch_id"] ?? 0,
        userContactName: json["user_contact_name"] ?? '',
        userPhone: json["user_phone"] ?? '',
        userAddress: json["user_address"] ?? '',
        userLatitude: json["user_latitude"] ?? '',
        userLongitude: json["user_longitude"] ?? '',
        userSignature: json["user_signature"] ?? '',
        userLimitAmountForSale: json["user_limit_amount_for_sale"] ?? 0,
        activeFlg: json["active_flg"] ?? 0,
        userPendingApproval: json["user_pending_approval"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        userAccountantKey: json["user_accountant_key"] ?? '',
        userCompanyName: json["user_company_name"] ?? '',
        userTaxCode: json["user_tax_code"] ?? '',
        userAddress1: json["user_address_1"] ?? '',
        userAddress2: json["user_address_2"] ?? '',
        userAddress3: json["user_address_3"] ?? '',
        userLogo: json["user_logo"] ?? '',
        userDebitType: json["user_debit_type"] ?? '',
        userPriceListMainType: json["user_price_list_main_type"] ?? '',
        userPriceListChangeType: json["user_price_list_change_type"] ?? '',
        userPriceListChangeDate: json["user_price_list_change_date"] ?? '',
        userRemainingLimit: json["user_remaining_limit"] ?? 0,
        userKpiId: json["user_kpi_id"] ?? '',
        userIsFreeTime: json["user_is_free_time"] ?? 0,
        positionName: json["position_name"] ?? '',
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
        "user_latitude": userLatitude,
        "user_longitude": userLongitude,
        "user_signature": userSignature,
        "user_limit_amount_for_sale": userLimitAmountForSale,
        "active_flg": activeFlg,
        "user_pending_approval": userPendingApproval,
        "delete_flg": deleteFlg,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
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
        "user_price_list_change_date": userPriceListChangeDate,
        "user_remaining_limit": userRemainingLimit,
        "user_kpi_id": userKpiId,
        "user_is_free_time": userIsFreeTime,
        "position_name": positionName,
      };
}

class Recharge {
  int rechargeId;
  int userId;
  int amount;
  dynamic note;
  String image;
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
    required this.priceOther,
    required this.statusLabel,
    required this.typeLabel,
  });

  factory Recharge.fromJson(Map<String, dynamic> json) => Recharge(
      rechargeId: json["recharge_id"] ?? 0,
      userId: json["user_id"] ?? 0,
      amount: json["amount"] ?? 0,
      note: json["note"],
      image: json["image"],
      status: json["status"] ?? 0,
      adminId: json["admin_id"] ?? 0,
      activeFlg: json["active_flg"] ?? 0,
      deleteFlg: json["delete_flg"] ?? 0,
      createdAt: json["created_at"] != null
          ? DateTime.parse(json["created_at"])
          : DateTime.now(),
      updatedAt: json["updated_at"] != null
          ? DateTime.parse(json["updated_at"])
          : DateTime.now(),
      type: json["type"] ?? 0,
      code: json["code"] ?? '',
      adminNote: json["admin_note"],
      priceOther: json["price_other"],
      statusLabel: json["status_label"] ?? '',
      typeLabel: json["type_label"] ?? '');

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
        "status_label": statusLabel,
        "type_label": typeLabel,
      };
}
