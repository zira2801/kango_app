// To parse this JSON data, do
//
//     final listAllSurchageGoodsModel = listAllSurchageGoodsModelFromJson(jsonString);

import 'dart:convert';

ListAllSurchageGoodsModel listAllSurchageGoodsModelFromJson(String str) =>
    ListAllSurchageGoodsModel.fromJson(json.decode(str));

String listAllSurchageGoodsModelToJson(ListAllSurchageGoodsModel data) =>
    json.encode(data.toJson());

class ListAllSurchageGoodsModel {
  int status;
  List<SurchageGood> surchageGoods;

  ListAllSurchageGoodsModel({
    required this.status,
    required this.surchageGoods,
  });

  factory ListAllSurchageGoodsModel.fromJson(Map<String, dynamic> json) =>
      ListAllSurchageGoodsModel(
        status: json["status"],
        surchageGoods: List<SurchageGood>.from(
            json["surchage_goods"].map((x) => SurchageGood.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "surchage_goods":
            List<dynamic>.from(surchageGoods.map((x) => x.toJson())),
      };
}

class SurchageGood {
  int surchargeGoodsId;
  String surchargeGoodsName;
  String surchargeGoodsType;
  int surchargeGoodsPrice;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  SurchageGood({
    required this.surchargeGoodsId,
    required this.surchargeGoodsName,
    required this.surchargeGoodsType,
    required this.surchargeGoodsPrice,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurchageGood.fromJson(Map<String, dynamic> json) => SurchageGood(
        surchargeGoodsId: json["surcharge_goods_id"],
        surchargeGoodsName: json["surcharge_goods_name"],
        surchargeGoodsType: json["surcharge_goods_type"],
        surchargeGoodsPrice: json["surcharge_goods_price"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "surcharge_goods_id": surchargeGoodsId,
        "surcharge_goods_name": surchargeGoodsName,
        "surcharge_goods_type": surchargeGoodsType,
        "surcharge_goods_price": surchargeGoodsPrice,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
