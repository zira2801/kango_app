// To parse this JSON data, do
//
//     final inforAccountModel = inforAccountModelFromJson(jsonString);

import 'dart:convert';

InforAccountModel inforAccountModelFromJson(String str) =>
    InforAccountModel.fromJson(json.decode(str));

String inforAccountModelToJson(InforAccountModel data) =>
    json.encode(data.toJson());

class InforAccountModel {
  int status;
  Data data;

  InforAccountModel({
    required this.status,
    required this.data,
  });

  factory InforAccountModel.fromJson(Map<String, dynamic> json) =>
      InforAccountModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
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
  dynamic userSignature;
  dynamic userLimitAmountForSale;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String? userAccountantKey;
  String? userCompanyName;
  String? userTaxCode;
  int? userAddress1;
  int? userAddress2;
  int? userAddress3;
  String? userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userPriceListChangeDate;
  dynamic userRemainingLimit;
  String nameAvatar;
  int userIsFreeTime;

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
    required this.nameAvatar,
    required this.userIsFreeTime,
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
        nameAvatar: json["name_avatar"],
        userIsFreeTime: json["user_is_free_time"],
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
        "user_price_list_change_date": userPriceListChangeDate,
        "user_remaining_limit": userRemainingLimit,
        "name_avatar": nameAvatar,
        "user_is_free_time": userIsFreeTime,
      };
}
