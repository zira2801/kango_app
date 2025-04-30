// To parse this JSON data, do
//
//     final scanBagCodeModel = scanBagCodeModelFromJson(jsonString);

import 'dart:convert';

ScanBagCodeModel scanBagCodeModelFromJson(String str) =>
    ScanBagCodeModel.fromJson(json.decode(str));

String scanBagCodeModelToJson(ScanBagCodeModel data) =>
    json.encode(data.toJson());

class ScanBagCodeModel {
  int status;
  Data data;

  ScanBagCodeModel({
    required this.status,
    required this.data,
  });

  factory ScanBagCodeModel.fromJson(Map<String, dynamic> json) =>
      ScanBagCodeModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  int mawb;
  String name;
  String bagCode;

  Data({
    required this.mawb,
    required this.name,
    required this.bagCode,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        mawb: json["mawb"],
        name: json["name"],
        bagCode: json["bag_code"],
      );

  Map<String, dynamic> toJson() => {
        "mawb": mawb,
        "name": name,
        "bag_code": bagCode,
      };
}
