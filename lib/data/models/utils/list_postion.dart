// To parse this JSON data, do
//
//     final positionListModel = positionListModelFromJson(jsonString);

import 'dart:convert';

PositionListModel positionListModelFromJson(String str) =>
    PositionListModel.fromJson(json.decode(str));

String positionListModelToJson(PositionListModel data) =>
    json.encode(data.toJson());

class PositionListModel {
  List<Position> positions;

  PositionListModel({
    required this.positions,
  });

  factory PositionListModel.fromJson(Map<String, dynamic> json) =>
      PositionListModel(
        positions: List<Position>.from(
            json["positions"].map((x) => Position.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "positions": List<dynamic>.from(positions.map((x) => x.toJson())),
      };
}

class Position {
  int positionId;
  String positionName;

  Position({
    required this.positionId,
    required this.positionName,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        positionId: json["position_id"],
        positionName: json["position_name"],
      );

  Map<String, dynamic> toJson() => {
        "position_id": positionId,
        "position_name": positionName,
      };
}

// To parse this JSON data, do
//
//     final branchesListModel = branchesListModelFromJson(jsonString);

BranchesListModel branchesListModelFromJson(String str) =>
    BranchesListModel.fromJson(json.decode(str));

String branchesListModelToJson(BranchesListModel data) =>
    json.encode(data.toJson());

class BranchesListModel {
  List<Branch> branches;

  BranchesListModel({
    required this.branches,
  });

  factory BranchesListModel.fromJson(Map<String, dynamic> json) =>
      BranchesListModel(
        branches:
            List<Branch>.from(json["branches"].map((x) => Branch.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "branches": List<dynamic>.from(branches.map((x) => x.toJson())),
      };
}

class Branch {
  int branchId;
  String branchName;

  Branch({
    required this.branchId,
    required this.branchName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        branchId: json["branch_id"],
        branchName: json["branch_name"],
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
      };
}
