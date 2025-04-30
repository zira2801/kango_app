// To parse this JSON data, do
//
//     final detailsOrderPickUpModel = detailsOrderPickUpModelFromJson(jsonString);

import 'dart:convert';

DetailsOrderPickUpModel detailsOrderPickUpModelFromJson(String str) =>
    DetailsOrderPickUpModel.fromJson(json.decode(str));

String detailsOrderPickUpModelToJson(DetailsOrderPickUpModel data) =>
    json.encode(data.toJson());

class DetailsOrderPickUpModel {
  int status;
  Data data;
  List<String> orderPickupStatus;

  DetailsOrderPickUpModel({
    required this.status,
    required this.data,
    required this.orderPickupStatus,
  });

  factory DetailsOrderPickUpModel.fromJson(Map<String, dynamic> json) =>
      DetailsOrderPickUpModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        orderPickupStatus:
            List<String>.from(json["order_pickup_status"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "order_pickup_status":
            List<dynamic>.from(orderPickupStatus.map((x) => x)),
      };
}

class Data {
  int orderPickupId;
  int userId;
  String? orderPickupName;
  int? fwdId;
  int? userReceiverId;
  int branchId;
  String orderPickupCode;
  String orderPickupAwb;
  String? orderPickupAddress;
  int? shipperLocationId;
  String latitude;
  String longitude;
  String? orderPickupPhone;
  String? orderPickupNote;
  String? orderPickupCancelDes;
  int orderPickupType;
  DateTime orderPickupDateTime;
  dynamic orderPickupNumberPackages;
  dynamic orderPickupGrossWeight;
  String? orderPickupImage;
  dynamic orderPickupDateTimeMethod;
  dynamic orderPickupMethod;
  dynamic orderPickupStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  Branch branch;
  Fwd? user;
  Fwd? shipper;
  Fwd? fwd;
  Fwd? userCreated;
  Fwd? sale;

  Data({
    required this.orderPickupId,
    required this.userId,
    required this.orderPickupName,
    required this.fwdId,
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
    required this.orderPickupCancelDes,
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
    required this.shipper,
    required this.fwd,
    required this.userCreated,
    required this.sale,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        orderPickupId: json["order_pickup_id"],
        userId: json["user_id"],
        orderPickupName: json["order_pickup_name"],
        fwdId: json["fwd_id"],
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
        orderPickupCancelDes: json["order_pickup_cancel_des"],
        orderPickupType: json["order_pickup_type"],
        orderPickupDateTime: DateTime.parse(json["order_pickup_date_time"]),
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
        user: json["user"] != null ? Fwd.fromJson(json["user"]) : null,
        shipper: json["shipper"] != null ? Fwd.fromJson(json["shipper"]) : null,
        fwd: json["fwd"] != null ? Fwd.fromJson(json["fwd"]) : null,
        sale: json["sale"] != null ? Fwd.fromJson(json["sale"]) : null,
        userCreated: json["userCreated"] != null
            ? Fwd.fromJson(json["userCreated"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "order_pickup_id": orderPickupId,
        "user_id": userId,
        "order_pickup_name": orderPickupName,
        "fwd_id": fwdId,
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
        "order_pickup_cancel_des": orderPickupCancelDes,
        "order_pickup_type": orderPickupType,
        "order_pickup_date_time": orderPickupDateTime.toIso8601String(),
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
        "user": user?.toJson(),
        "shipper": shipper?.toJson(),
        "fwd": fwd?.toJson(),
        "sale": sale?.toJson(),
        "user_created": userCreated?.toJson(),
      };
}

class Branch {
  int branchId;
  String? branchName;
  String? branchDescription;
  String branchLatitude;
  String branchLongitude;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  Branch({
    required this.branchId,
    required this.branchName,
    required this.branchDescription,
    required this.branchLatitude,
    required this.branchLongitude,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        branchId: json["branch_id"],
        branchName: json["branch_name"],
        branchDescription: json["branch_description"],
        branchLatitude: json["branch_latitude"],
        branchLongitude: json["branch_longitude"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
        "branch_description": branchDescription,
        "branch_latitude": branchLatitude,
        "branch_longitude": branchLongitude,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Fwd {
  int userId;
  String userName;
  String userCode;
  String userApiKey;
  int positionId;
  int branchId;
  String userContactName;
  String userPhone;
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
  String? userCompanyName;
  String? userTaxCode;
  String? userAddress1;
  String? userAddress2;
  String? userAddress3;
  String? userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userRemainingLimit;
  dynamic userPriceListChangeDate;
  dynamic userKpiId;
  int userIsFreeTime;
  int? shipperLocationId;
  int? shipperId;
  String? shipperLongitude;
  String? shipperLatitude;
  String? locationAddress;
  int? shipStatus;
  String? password;
  dynamic rememberToken;

  Fwd({
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
    this.shipperLocationId,
    this.shipperId,
    this.shipperLongitude,
    this.shipperLatitude,
    this.locationAddress,
    this.shipStatus,
    this.password,
    this.rememberToken,
  });

  factory Fwd.fromJson(Map<String, dynamic> json) => Fwd(
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
        userRemainingLimit: json["user_remaining_limit"],
        userPriceListChangeDate: json["user_price_list_change_date"],
        userKpiId: json["user_kpi_id"],
        userIsFreeTime: json["user_is_free_time"],
        shipperLocationId: json["shipper_location_id"],
        shipperId: json["shipper_id"],
        shipperLongitude: json["shipper_longitude"],
        shipperLatitude: json["shipper_latitude"],
        locationAddress: json["location_address"],
        shipStatus: json["ship_status"],
        password: json["password"],
        rememberToken: json["remember_token"],
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
        "user_remaining_limit": userRemainingLimit,
        "user_price_list_change_date": userPriceListChangeDate,
        "user_kpi_id": userKpiId,
        "user_is_free_time": userIsFreeTime,
        "shipper_location_id": shipperLocationId,
        "shipper_id": shipperId,
        "shipper_longitude": shipperLongitude,
        "shipper_latitude": shipperLatitude,
        "location_address": locationAddress,
        "ship_status": shipStatus,
        "password": password,
        "remember_token": rememberToken,
      };
}
