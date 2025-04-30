// To parse this JSON data, do
//
//     final branchResponse = branchResponseFromJson(jsonString);

import 'dart:convert';

BranchResponse branchResponseFromJson(String str) =>
    BranchResponse.fromJson(json.decode(str));

String branchResponseToJson(BranchResponse data) => json.encode(data.toJson());

class BranchResponse {
  int? status;
  List<BranchKango> branchs;

  BranchResponse({
    required this.status,
    required this.branchs,
  });

  factory BranchResponse.fromJson(Map<String, dynamic> json) => BranchResponse(
        status: json["status"],
        branchs: List<BranchKango>.from(
            json["branchs"].map((x) => BranchKango.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "branchs": List<dynamic>.from(branchs.map((x) => x.toJson())),
      };
}

class BranchKango {
  int branchId;
  String branchName;
  String branchDescription;
  String? branchLatitude;
  String? branchLongitude;
  int? activeFlg;
  int? deleteFlg;
  String? createdAt;
  String? updatedAt;

  BranchKango({
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

  factory BranchKango.fromJson(Map<String, dynamic> json) => BranchKango(
        branchId: json["branch_id"],
        branchName: json["branch_name"],
        branchDescription: json["branch_description"],
        branchLatitude: json["branch_latitude"],
        branchLongitude: json["branch_longitude"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
        "branch_description": branchDescription,
        "branch_latitude": branchLatitude,
        "branch_longitude": branchLongitude,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
