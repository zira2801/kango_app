// To parse this JSON data, do
//
//     final detailsPackageScanCodeModel = detailsPackageScanCodeModelFromJson(jsonString);

import 'dart:convert';

DetailsPackageScanCodeModel detailsPackageScanCodeModelFromJson(String str) =>
    DetailsPackageScanCodeModel.fromJson(json.decode(str));

String detailsPackageScanCodeModelToJson(DetailsPackageScanCodeModel data) =>
    json.encode(data.toJson());

class DetailsPackageScanCodeModel {
  int status;
  String count_scan;
  Package package;
  String shipment_code;
  DetailsPackageScanCodeModel({
    required this.status,
    required this.count_scan,
    required this.package,
    required this.shipment_code,
  });

  factory DetailsPackageScanCodeModel.fromJson(Map<String, dynamic> json) =>
      DetailsPackageScanCodeModel(
        status: (json["status"] is double)
            ? (json["status"] as double).toInt() // Cast double to int
            : json["status"] as int, // Ensure it's treated as an int
        count_scan: json["count_scan"] ?? "",
        package: Package.fromJson(json["package"]),
        shipment_code: json["shipment_code"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "count_scan": count_scan,
        "package": package.toJson(),
        "shipment_code": shipment_code,
      };
}

class Package {
  int packageId;
  int shipmentId;
  String packageCode;
  int packageQuantity;
  int packageType;
  String? packageDescription;
  int packageLength;
  int? packageLengthActual;
  int packageWidth;
  int? packageWidthActual;
  int packageHeight;
  int? packageHeightActual;
  int packageWeight;
  int? packageWeightActual;
  String packageHawbCode;
  double packageConvertedWeight; // Đổi sang double
  double? packageConvertedWeightActual;
  int packageChargedWeight;
  int? packageChargedWeightActual;
  String? packageTrackingCode;
  int packagePrice;
  int? packagePriceActual;
  int packageApprove;
  int? processingStaffId;
  dynamic carrierCode;
  String? packageImage;
  String? bagCode;
  dynamic smTracktryId;
  dynamic branchConnect;
  String packageStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  Package({
    required this.packageId,
    required this.shipmentId,
    required this.packageCode,
    required this.packageQuantity,
    required this.packageType,
    required this.packageDescription,
    required this.packageLength,
    this.packageLengthActual,
    required this.packageWidth,
    this.packageWidthActual,
    required this.packageHeight,
    this.packageHeightActual,
    required this.packageWeight,
    this.packageWeightActual,
    required this.packageHawbCode,
    required this.packageConvertedWeight,
    this.packageConvertedWeightActual,
    required this.packageChargedWeight,
    this.packageChargedWeightActual,
    this.packageTrackingCode,
    required this.packagePrice,
    this.packagePriceActual,
    required this.packageApprove,
    this.processingStaffId,
    this.carrierCode,
    this.packageImage,
    this.bagCode,
    this.smTracktryId,
    this.branchConnect,
    required this.packageStatus,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        packageId: json["package_id"],
        shipmentId: json["shipment_id"],
        packageCode:
            json["package_code"] ?? "", // Cung cấp giá trị mặc định nếu là null
        packageQuantity: (json["package_quantity"] is double)
            ? json["package_quantity"].toInt()
            : json["package_quantity"],
        packageType: json["package_type"],
        packageDescription: json["package_description"] ??
            "", // Cung cấp giá trị mặc định nếu là null
        packageLength: (json["package_length"] is double)
            ? json["package_length"].toInt()
            : json["package_length"],
        packageWidth: (json["package_width"] is double)
            ? json["package_width"].toInt()
            : json["package_width"],
        packageHeight: (json["package_height"] is double)
            ? json["package_height"].toInt()
            : json["package_height"],
        packageWeight: (json["package_weight"] is double)
            ? json["package_weight"].toInt()
            : json["package_weight"],
        packageHawbCode: json["package_hawb_code"] ??
            "", // Cung cấp giá trị mặc định nếu là null
        packageConvertedWeight: (json["package_converted_weight"] is int)
            ? (json["package_converted_weight"] as int)
                .toDouble() // ✅ Đảm bảo luôn là double
            : json["package_converted_weight"],

        packageChargedWeight: (json["package_charged_weight"] is double)
            ? json["package_charged_weight"].toInt()
            : json["package_charged_weight"],
        packageTrackingCode: json["package_tracking_code"] ??
            "", // Cung cấp giá trị mặc định nếu là null
        carrierCode: json["carrier_code"],
        /* smTracktryId:
            json.containsKey("sm_tracktry_id") ? json["sm_tracktry_id"] : "",*/

        branchConnect: json["branch_connect"],
        packageStatus: json["package_status"] ??
            "", // Cung cấp giá trị mặc định nếu là null
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        packagePrice: json["package_price"] ?? 0,
        packageApprove: json["package_approve"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "package_id": packageId,
        "shipment_id": shipmentId,
        "package_code": packageCode,
        "package_quantity": packageQuantity,
        "package_type": packageType,
        "package_description": packageDescription,
        "package_length": packageLength,
        "package_width": packageWidth,
        "package_height": packageHeight,
        "package_weight": packageWeight,
        "package_hawb_code": packageHawbCode,
        "package_converted_weight": packageConvertedWeight,
        "package_charged_weight": packageChargedWeight,
        "package_tracking_code": packageTrackingCode,
        "carrier_code": carrierCode,
        "sm_tracktry_id": smTracktryId,
        "branch_connect": branchConnect,
        "package_status": packageStatus,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
