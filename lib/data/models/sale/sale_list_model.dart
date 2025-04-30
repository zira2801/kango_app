// To parse this JSON data, do
//
//     final saleListModel = saleListModelFromJson(jsonString);

import 'dart:convert';

SaleListModel saleListModelFromJson(String str) =>
    SaleListModel.fromJson(json.decode(str));

String saleListModelToJson(SaleListModel data) => json.encode(data.toJson());

class SaleListModel {
  int status;
  Data data;

  SaleListModel({
    required this.status,
    required this.data,
  });

  factory SaleListModel.fromJson(Map<String, dynamic> json) => SaleListModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  int currentPage;
  List<SaleItemData> data;
  String? firstPageUrl;
  int? from;

  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  dynamic prevPageUrl;
  int? to;
  int? total;

  Data({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        currentPage: json["current_page"],
        data: List<SaleItemData>.from(
            json["data"].map((x) => SaleItemData.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class SaleItemData {
  int? userId;
  String? userName; // Changed to nullable
  String? userCode; // Changed to nullable
  String? userApiKey; // Changed to nullable
  int? positionId;
  int? branchId;
  String? userContactName; // Changed to nullable
  String? userPhone; // Changed to nullable
  String? userAddress; // Changed to nullable
  dynamic userLatitude;
  dynamic userLongitude;
  dynamic userSignature;
  int? userLimitAmountForSale;
  int? activeFlg;
  int? userPendingApproval;
  int? deleteFlg;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic userAccountantKey;
  String? userCompanyName; // Already nullable
  dynamic userTaxCode;
  dynamic userAddress1;
  dynamic userAddress2;
  dynamic userAddress3;
  dynamic userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  int? userRemainingLimit;
  dynamic userPriceListChangeDate;
  int? userKpiId;
  int? userIsFreeTime;

  SaleItemData({
    this.userId,
    this.userName,
    this.userCode,
    this.userApiKey,
    this.positionId,
    this.branchId,
    this.userContactName,
    this.userPhone,
    this.userAddress,
    this.userLatitude,
    this.userLongitude,
    this.userSignature,
    this.userLimitAmountForSale,
    this.activeFlg,
    this.userPendingApproval,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.userAccountantKey,
    this.userCompanyName,
    this.userTaxCode,
    this.userAddress1,
    this.userAddress2,
    this.userAddress3,
    this.userLogo,
    this.userDebitType,
    this.userPriceListMainType,
    this.userPriceListChangeType,
    this.userRemainingLimit,
    this.userPriceListChangeDate,
    this.userKpiId,
    this.userIsFreeTime,
  });

  factory SaleItemData.fromJson(Map<String, dynamic> json) => SaleItemData(
        userId: json["user_id"] as int?,
        userName: json["user_name"] as String?,
        userCode: json["user_code"] as String?,
        userApiKey: json["user_api_key"] as String?,
        positionId: json["position_id"] as int?,
        branchId: json["branch_id"] as int?,
        userContactName: json["user_contact_name"] as String?,
        userPhone: json["user_phone"] as String?,
        userAddress: json["user_address"] as String?,
        userLatitude: json["user_latitude"],
        userLongitude: json["user_longitude"],
        userSignature: json["user_signature"],
        userLimitAmountForSale: json["user_limit_amount_for_sale"] as int?,
        activeFlg: json["active_flg"] as int?,
        userPendingApproval: json["user_pending_approval"] as int?,
        deleteFlg: json["delete_flg"] as int?,
        createdAt: json["created_at"] != null
            ? DateTime.tryParse(json["created_at"] as String)
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.tryParse(json["updated_at"] as String)
            : null,
        userAccountantKey: json["user_accountant_key"],
        userCompanyName: json["user_company_name"] as String?,
        userTaxCode: json["user_tax_code"],
        userAddress1: json["user_address_1"],
        userAddress2: json["user_address_2"],
        userAddress3: json["user_address_3"],
        userLogo: json["user_logo"],
        userDebitType: json["user_debit_type"],
        userPriceListMainType: json["user_price_list_main_type"],
        userPriceListChangeType: json["user_price_list_change_type"],
        userRemainingLimit: json["user_remaining_limit"] as int?,
        userPriceListChangeDate: json["user_price_list_change_date"],
        userKpiId: json["user_kpi_id"] as int?,
        userIsFreeTime: json["user_is_free_time"] as int?,
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
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
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
        "user_kpi_id": userKpiId,
        "user_is_free_time": userIsFreeTime,
      };
}
