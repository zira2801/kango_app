import 'dart:convert';

MAWBTrackingModel mawbTrackingModelFromJson(String str) =>
    MAWBTrackingModel.fromJson(json.decode(str));

String mawbTrackingModelToJson(MAWBTrackingModel data) =>
    json.encode(data.toJson());

class MAWBTrackingModel {
  int status;
  List<ShipmentTracktry> shipmentsTracktry;

  MAWBTrackingModel({
    required this.status,
    required this.shipmentsTracktry,
  });

  factory MAWBTrackingModel.fromJson(Map<String, dynamic> json) =>
      MAWBTrackingModel(
        status: json["status"],
        shipmentsTracktry: List<ShipmentTracktry>.from(
            json["shipments_tracktry"]
                .map((x) => ShipmentTracktry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "shipments_tracktry":
            List<dynamic>.from(shipmentsTracktry.map((x) => x.toJson())),
      };
}

class ShipmentTracktry {
  int smTracktryId;
  String awbCode;
  String hawbNo;
  String service;
  List<String> serviceIds;
  int branchId;
  String airline;
  dynamic partner;
  String dest;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  int trackingStatus;
  String load;
  String flight;
  DateTime eta;
  DateTime etd;
  dynamic trackingStatusLabel;
  Branch branch;

  ShipmentTracktry({
    required this.smTracktryId,
    required this.awbCode,
    required this.hawbNo,
    required this.service,
    required this.serviceIds,
    required this.branchId,
    required this.airline,
    required this.partner,
    required this.dest,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.trackingStatus,
    required this.load,
    required this.flight,
    required this.eta,
    required this.etd,
    required this.trackingStatusLabel,
    required this.branch,
  });

  factory ShipmentTracktry.fromJson(Map<String, dynamic> json) =>
      ShipmentTracktry(
        smTracktryId: json["sm_tracktry_id"],
        awbCode: json["awb_code"],
        hawbNo: json["hawb_no"],
        service: json["service"],
        serviceIds: List<String>.from(json["service_ids"]
            .toString()
            .replaceAll("[", "")
            .replaceAll("]", "")
            .replaceAll("\"", "")
            .split(",")),
        branchId: json["branch_id"],
        airline: json["airline"],
        partner: json["partner"],
        dest: json["dest"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        trackingStatus: json["tracking_status"],
        load: json["load"],
        flight: json["flight"],
        eta: DateTime.parse(json["eta"]),
        etd: DateTime.parse(json["etd"]),
        trackingStatusLabel: json["tracking_status_label"],
        branch: Branch.fromJson(json["branch"]),
      );

  Map<String, dynamic> toJson() => {
        "sm_tracktry_id": smTracktryId,
        "awb_code": awbCode,
        "hawb_no": hawbNo,
        "service": service,
        "service_ids": serviceIds,
        "branch_id": branchId,
        "airline": airline,
        "partner": partner,
        "dest": dest,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "tracking_status": trackingStatus,
        "load": load,
        "flight": flight,
        "eta": eta.toIso8601String(),
        "etd": etd.toIso8601String(),
        "tracking_status_label": trackingStatusLabel,
        "branch": branch.toJson(),
      };
}

class Branch {
  int branchId;
  String branchName;
  String branchDescription;
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
