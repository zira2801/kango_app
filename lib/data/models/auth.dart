// To parse this JSON data, do
//
//     final authModel = authModelFromJson(jsonString);

import 'dart:convert';

AuthModel authModelFromJson(String str) => AuthModel.fromJson(json.decode(str));

String authModelToJson(AuthModel data) => json.encode(data.toJson());

class AuthModel {
  int status;
  String message;
  String token;
  dynamic tokenExpiresAt;
  Data data;
  bool isShipper;
  List<SystemSetting> systemSettings;
  AuthModel({
    required this.status,
    required this.message,
    required this.token,
    required this.tokenExpiresAt,
    required this.data,
    required this.isShipper,
    required this.systemSettings,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
        status: json["status"],
        message: json["message"],
        token: json["token"],
        tokenExpiresAt: json["token_expires_at"],
        data: Data.fromJson(
          json["data"],
        ),
        isShipper: json["is_shipper"],
        systemSettings: json["system_settings"] != null
            ? List<SystemSetting>.from(
                json["system_settings"].map((x) => SystemSetting.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "token": token,
        "token_expires_at": tokenExpiresAt,
        "data": data.toJson(),
        "is_shipper": isShipper,
        "system_settings":
            List<dynamic>.from(systemSettings.map((x) => x.toJson())),
      };
}

class SystemSetting {
  String title;
  int kind;
  String name;
  dynamic data;
  String? model;
  String? positionId;
  List<String>? positionIds;
  String? value;

  SystemSetting({
    required this.title,
    required this.kind,
    required this.name,
    this.data,
    this.model,
    this.positionId,
    this.positionIds,
    this.value,
  });

  factory SystemSetting.fromJson(Map<String, dynamic> json) => SystemSetting(
        title: json["title"],
        kind: json["kind"],
        name: json["name"],
        data: json["data"],
        model: json["model"],
        positionId: json["position_id"],
        positionIds: json["position_ids"] != null
            ? List<String>.from(json["position_ids"].map((x) => x))
            : null, // Add null safety here
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "kind": kind,
        "name": name,
        "data": data,
        "model": model,
        "position_id": positionId,
        "position_ids": positionIds == null
            ? []
            : List<dynamic>.from(positionIds!.map((x) => x)),
        "value": value,
      };
}

class Data {
  int userId;
  String userName;
  String userCode;
  String userApiKey;
  int positionId;
  int branchId;
  String userContactName;
  String userPhone;
  String userAddress;
  String? userLongitude;
  String? userLatitude;
  dynamic userSignature;
  dynamic userLimitAmountForSale;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic userAccountantKey;
  dynamic userCompanyName;
  dynamic userTaxCode;
  dynamic userAddress1;
  dynamic userAddress2;
  dynamic userAddress3;
  dynamic userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userPriceListChangeDate;
  dynamic userRemainingLimit;

  Data({
    required this.userId,
    required this.userName,
    required this.userCode,
    required this.userApiKey,
    required this.positionId,
    required this.branchId,
    required this.userContactName,
    required this.userPhone,
    required this.userAddress,
    required this.userLongitude,
    required this.userLatitude,
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
    required this.userPriceListChangeDate,
    required this.userRemainingLimit,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        userName: json["user_name"],
        userCode: json["user_code"],
        userApiKey: json["user_api_key"],
        positionId: json["position_id"],
        branchId: json["branch_id"],
        userContactName: json["user_contact_name"],
        userPhone: json["user_phone"],
        userAddress: json["user_address"],
        userLatitude: json["user_latitude"],
        userLongitude: json["user_longitude"],
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
        userPriceListChangeDate: json["user_price_list_change_date"],
        userRemainingLimit: json["user_remaining_limit"],
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
        "user_price_list_change_date": userPriceListChangeDate,
        "user_remaining_limit": userRemainingLimit,
      };
}
