// To parse this JSON data, do
//
//     final listShipperFreeModel = listShipperFreeModelFromJson(jsonString);

import 'dart:convert';

ListShipperFreeModel listShipperFreeModelFromJson(String str) =>
    ListShipperFreeModel.fromJson(json.decode(str));

String listShipperFreeModelToJson(ListShipperFreeModel data) =>
    json.encode(data.toJson());

class ListShipperFreeModel {
  int status;
  Shippers shippers;

  ListShipperFreeModel({
    required this.status,
    required this.shippers,
  });

  factory ListShipperFreeModel.fromJson(Map<String, dynamic> json) =>
      ListShipperFreeModel(
        status: json["status"],
        shippers: Shippers.fromJson(json["shippers"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "shippers": shippers.toJson(),
      };
}

class Shippers {
  int currentPage;
  List<ShipperFreeItemData> data;

  Shippers({
    required this.currentPage,
    required this.data,
  });

  factory Shippers.fromJson(Map<String, dynamic> json) => Shippers(
        currentPage: json["current_page"],
        data: List<ShipperFreeItemData>.from(
            json["data"].map((x) => ShipperFreeItemData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ShipperFreeItemData {
  int userId;
  String? userName;
  String? userCode;
  String? userApiKey;
  int positionId;
  int branchId;
  String? userContactName;
  String? userPhone;
  String? userAddress;
  String? userLatitude;
  String? userLongitude;
  dynamic userSignature;
  dynamic userLimitAmountForSale;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String? userAccountantKey;
  UserCompanyName userCompanyName;
  String? userTaxCode;
  String? userAddress1;
  String? userAddress2;
  String? userAddress3;
  dynamic userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userRemainingLimit;
  dynamic userPriceListChangeDate;
  dynamic userKpiId;
  int userIsFreeTime;

  ShipperFreeItemData({
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
    required this.userKpiId,
    required this.userIsFreeTime,
  });

  factory ShipperFreeItemData.fromJson(Map<String, dynamic> json) =>
      ShipperFreeItemData(
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
        userCompanyName: userCompanyNameValues.map[json["user_company_name"]]!,
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
        userKpiId: json["user_kpi_id"],
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
        "user_latitude": userLatitude,
        "user_longitude": userLongitude,
        "user_signature": userSignature,
        "user_limit_amount_for_sale": userLimitAmountForSale,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user_accountant_key": userAccountantKey,
        "user_company_name": userCompanyNameValues.reverse[userCompanyName],
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
        "user_kpi_id": userKpiId,
        "user_is_free_time": userIsFreeTime,
      };
}

enum UserCompanyName { KANGO_EXPRESS }

final userCompanyNameValues =
    EnumValues({"KANGO EXPRESS": UserCompanyName.KANGO_EXPRESS});

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
