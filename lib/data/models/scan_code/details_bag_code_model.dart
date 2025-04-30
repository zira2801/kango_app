// To parse this JSON data, do
//
//     final scanDetailsBagCodeModel = scanDetailsBagCodeModelFromJson(jsonString);

import 'dart:convert';

ScanDetailsBagCodeModel scanDetailsBagCodeModelFromJson(String str) =>
    ScanDetailsBagCodeModel.fromJson(json.decode(str));

String scanDetailsBagCodeModelToJson(ScanDetailsBagCodeModel data) =>
    json.encode(data.toJson());

class ScanDetailsBagCodeModel {
  int status;
  Data data;

  ScanDetailsBagCodeModel({
    required this.status,
    required this.data,
  });

  factory ScanDetailsBagCodeModel.fromJson(Map<String, dynamic> json) =>
      ScanDetailsBagCodeModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  String packageCode;
  String count_scan;
  String bagCode;
  String awbCode;
  int weight;
  String size;

  Data({
    required this.packageCode,
    required this.count_scan,
    required this.bagCode,
    required this.awbCode,
    required this.weight,
    required this.size,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        packageCode: json["package_code"],
        count_scan: json["count_scan"],
        bagCode: json["bag_code"],
        awbCode: json["awb_code"],
        weight: json["weight"],
        size: json["size"],
      );

  Map<String, dynamic> toJson() => {
        "package_code": packageCode,
        "count_scan": count_scan,
        "bag_code": bagCode,
        "awb_code": awbCode,
        "weight": weight,
        "size": size,
      };
}
