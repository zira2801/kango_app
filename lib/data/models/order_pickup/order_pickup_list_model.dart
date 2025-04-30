// To parse this JSON data, do
//
//     final orderPickUpListModel = orderPickUpListModelFromJson(jsonString);

import 'dart:convert';

OrderPickUpListModel orderPickUpListModelFromJson(String str) =>
    OrderPickUpListModel.fromJson(json.decode(str));

String orderPickUpListModelToJson(OrderPickUpListModel data) =>
    json.encode(data.toJson());

class OrderPickUpListModel {
  int status;
  OrdersPickup ordersPickup;
  bool isEdit;

  OrderPickUpListModel({
    required this.status,
    required this.ordersPickup,
    required this.isEdit,
  });

  factory OrderPickUpListModel.fromJson(Map<String, dynamic> json) =>
      OrderPickUpListModel(
        status: json["status"],
        ordersPickup: OrdersPickup.fromJson(json["orders_pickup"]),
        isEdit: json["is_edit"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "orders_pickup": ordersPickup.toJson(),
        "is_edit": isEdit,
      };
}

class OrdersPickup {
  int currentPage;
  List<OrdersPickupItemData> data;

  OrdersPickup({
    required this.currentPage,
    required this.data,
  });

  factory OrdersPickup.fromJson(Map<String, dynamic> json) => OrdersPickup(
        currentPage: json["current_page"],
        data: List<OrdersPickupItemData>.from(
            json["data"].map((x) => OrdersPickupItemData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class OrdersPickupItemData {
  int orderPickupId;
  int userId;
  String orderPickupName;
  dynamic userReceiverId;
  int branchId;
  final int? fwd;
  String orderPickupCode;
  String orderPickupAwb;
  String orderPickupAddress;
  int? shipperLocationId;
  String latitude;
  String longitude;
  String orderPickupPhone;
  String? orderPickupNote;
  int orderPickupType;
  String? orderPickupDateTime;
  dynamic orderPickupNumberPackages;
  dynamic orderPickupGrossWeight;
  String? orderPickupImage;
  dynamic orderPickupDateTimeMethod;
  int orderPickupMethod;
  int orderPickupStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  Branch branch;
  User user;

  OrdersPickupItemData({
    required this.orderPickupId,
    required this.userId,
    required this.fwd,
    required this.orderPickupName,
    required this.userReceiverId,
    required this.branchId,
    required this.orderPickupCode,
    required this.orderPickupAwb,
    required this.orderPickupAddress,
    required this.shipperLocationId,
    required this.latitude,
    required this.longitude,
    required this.orderPickupPhone,
    required this.orderPickupNote,
    required this.orderPickupType,
    required this.orderPickupDateTime,
    required this.orderPickupNumberPackages,
    required this.orderPickupGrossWeight,
    required this.orderPickupImage,
    required this.orderPickupDateTimeMethod,
    required this.orderPickupMethod,
    required this.orderPickupStatus,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.branch,
    required this.user,
  });

  factory OrdersPickupItemData.fromJson(Map<String, dynamic> json) =>
      OrdersPickupItemData(
        orderPickupId: json["order_pickup_id"],
        userId: json["user_id"],
        fwd: json["fwd_id"],
        orderPickupName: json["order_pickup_name"],
        userReceiverId: json["user_receiver_id"],
        branchId: json["branch_id"],
        orderPickupCode: json["order_pickup_code"],
        orderPickupAwb: json["order_pickup_awb"],
        orderPickupAddress: json["order_pickup_address"],
        shipperLocationId: json["shipper_location_id"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        orderPickupPhone: json["order_pickup_phone"],
        orderPickupNote: json["order_pickup_note"],
        orderPickupType: json["order_pickup_type"],
        orderPickupDateTime: json["order_pickup_date_time"],
        orderPickupNumberPackages: json["order_pickup_number_packages"],
        orderPickupGrossWeight: json["order_pickup_gross_weight"],
        orderPickupImage: json["order_pickup_image"],
        orderPickupDateTimeMethod: json["order_pickup_date_time_method"],
        orderPickupMethod: json["order_pickup_method"],
        orderPickupStatus: json["order_pickup_status"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        branch: Branch.fromJson(json["branch"]),
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "order_pickup_id": orderPickupId,
        "user_id": userId,
        "user_receiver_id": userReceiverId,
        "branch_id": branchId,
        "order_pickup_code": orderPickupCode,
        "order_pickup_awb": orderPickupAwb,
        "order_pickup_address": orderPickupAddress,
        "shipper_location_id": shipperLocationId,
        "latitude": latitude,
        "longitude": longitude,
        "order_pickup_phone": orderPickupPhone,
        "order_pickup_note": orderPickupNote,
        "order_pickup_type": orderPickupType,
        "order_pickup_date_time": orderPickupDateTime,
        "order_pickup_number_packages": orderPickupNumberPackages,
        "order_pickup_gross_weight": orderPickupGrossWeight,
        "order_pickup_image": orderPickupImage,
        "order_pickup_date_time_method": orderPickupDateTimeMethod,
        "order_pickup_method": orderPickupMethod,
        "order_pickup_status": orderPickupStatus,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "branch": branch.toJson(),
        "user": user.toJson(),
      };
}

class Branch {
  int branchId;
  String? branchName;
  String? branchDescription;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  Branch({
    required this.branchId,
    required this.branchName,
    required this.branchDescription,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        branchId: json["branch_id"],
        branchName: json["branch_name"],
        branchDescription: json["branch_description"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
        "branch_description": branchDescription,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class User {
  int userId;
  String userName;
  String userCode;
  String userApiKey;
  int positionId;
  int branchId;
  String userContactName;
  String userPhone;
  String userAddress;
  String? userSignature;
  dynamic userLimitAmountForSale;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String? userAccountantKey;
  String? userCompanyName;
  String? userTaxCode;
  String? userAddress1;
  String? userAddress2;
  String? userAddress3;
  String? userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userPriceListChangeDate;
  dynamic userRemainingLimit;

  User({
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
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
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
      };
}
