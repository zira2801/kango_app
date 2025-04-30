// To parse this JSON data, do
//
//     final listMawbCodeModel = listMawbCodeModelFromJson(jsonString);

import 'dart:convert';

ListMawbCodeModel listMawbCodeModelFromJson(String str) =>
    ListMawbCodeModel.fromJson(json.decode(str));

String listMawbCodeModelToJson(ListMawbCodeModel data) =>
    json.encode(data.toJson());

class ListMawbCodeModel {
  int status;
  List<ShipmentsTracktry> shipmentsTracktry;

  ListMawbCodeModel({
    required this.status,
    required this.shipmentsTracktry,
  });

  factory ListMawbCodeModel.fromJson(Map<String, dynamic> json) =>
      ListMawbCodeModel(
        status: json["status"],
        shipmentsTracktry: List<ShipmentsTracktry>.from(
            json["shipments_tracktry"]
                .map((x) => ShipmentsTracktry.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "shipments_tracktry":
            List<dynamic>.from(shipmentsTracktry.map((x) => x.toJson())),
      };
}

class ShipmentsTracktry {
  int smTracktryId;
  String awbCode;
  String hawbNo;
  String service;
  String serviceIds;
  int branchId;
  String airline;
  dynamic partner;
  String dest;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String branchName;

  ShipmentsTracktry({
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
    required this.branchName,
  });

  factory ShipmentsTracktry.fromJson(Map<String, dynamic> json) =>
      ShipmentsTracktry(
        smTracktryId: json["sm_tracktry_id"],
        awbCode: json["awb_code"],
        hawbNo: json["hawb_no"],
        service: json["service"],
        serviceIds: json["service_ids"],
        branchId: json["branch_id"],
        airline: json["airline"],
        partner: json["partner"],
        dest: json["dest"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        branchName: json["branch_name"],
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
        "branch_name": branchName,
      };
}
