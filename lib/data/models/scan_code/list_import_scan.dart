import 'dart:convert';

ListImportScanModel listImportScanModelFromJson(String str) =>
    ListImportScanModel.fromJson(json.decode(str));

String listImportScanModelToJson(ListImportScanModel data) =>
    json.encode(data.toJson());

class ListImportScanModel {
  int status;
  List<DataItemImportScan> data;

  ListImportScanModel({
    required this.status,
    required this.data,
  });

  factory ListImportScanModel.fromJson(Map<String, dynamic> json) =>
      ListImportScanModel(
        status: json["status"],
        data: List<DataItemImportScan>.from(
            json["data"].map((x) => DataItemImportScan.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DataItemImportScan {
  String receiverContactName;
  String senderContactName;
  int packageId;
  int shipmentId;
  String packageCode;
  num packageQuantity; // Sửa từ int -> num
  num packageType;
  String? packageDescription;
  num packageLength;
  num packageWidth;
  num packageHeight;
  num packageWeight;
  String packageHawbCode;
  num packageConvertedWeight;
  num packageChargedWeight;
  String? packageTrackingCode;
  dynamic carrierCode;
  String packageStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String userName;
  String scanByName;
  String countryName;
  String serviceName;
  int scanBy;
  int historyScanId;
  DateTime scanAt;
  String statusLabel;

  DataItemImportScan({
    required this.receiverContactName,
    required this.senderContactName,
    required this.packageId,
    required this.shipmentId,
    required this.packageCode,
    required this.packageQuantity,
    required this.packageType,
    required this.packageDescription,
    required this.packageLength,
    required this.packageWidth,
    required this.packageHeight,
    required this.packageWeight,
    required this.packageHawbCode,
    required this.packageConvertedWeight,
    required this.packageChargedWeight,
    required this.packageTrackingCode,
    required this.carrierCode,
    required this.packageStatus,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.userName,
    required this.scanByName,
    required this.countryName,
    required this.serviceName,
    required this.scanBy,
    required this.historyScanId,
    required this.scanAt,
    required this.statusLabel,
  });

  factory DataItemImportScan.fromJson(Map<String, dynamic> json) =>
      DataItemImportScan(
        receiverContactName: json["receiver_contact_name"],
        senderContactName: json["sender_contact_name"],
        packageId: json["package_id"],
        shipmentId: json["shipment_id"],
        packageCode: json["package_code"],
        packageQuantity: (json["package_quantity"] ?? 0).toDouble(),
        packageType: (json["package_type"] ?? 0).toDouble(),
        packageDescription: json["package_description"],
        packageLength: (json["package_length"] ?? 0).toDouble(),
        packageWidth: (json["package_width"] ?? 0).toDouble(),
        packageHeight: (json["package_height"] ?? 0).toDouble(),
        packageWeight: (json["package_weight"] ?? 0).toDouble(),
        packageHawbCode: json["package_hawb_code"],
        packageConvertedWeight:
            (json["package_converted_weight"] ?? 0).toDouble(),
        packageChargedWeight: (json["package_charged_weight"] ?? 0).toDouble(),
        packageTrackingCode: json["package_tracking_code"],
        carrierCode: json["carrier_code"],
        packageStatus: json["package_status"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        userName: json["user_name"],
        scanByName: json["scan_by_name"],
        countryName: json["country_name"],
        serviceName: json["service_name"],
        scanBy: json["scan_by"],
        historyScanId: json["history_scan_id"],
        scanAt: DateTime.parse(json["scan_at"]),
        statusLabel: json["status_label"],
      );

  Map<String, dynamic> toJson() => {
        "receiver_contact_name": receiverContactName,
        "sender_contact_name": senderContactName,
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
        "package_status": packageStatus,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user_name": userName,
        "scan_by_name": scanByName,
        "country_name": countryName,
        "service_name": serviceName,
        "scan_by": scanBy,
        "history_scan_id": historyScanId,
        "scan_at": scanAt.toIso8601String(),
        "status_label": statusLabel,
      };
}
