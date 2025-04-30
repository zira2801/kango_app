class SurchageGoodsChoose {
  int surchargeGoodsID;
  int count;
  double price;

  SurchageGoodsChoose({
    required this.surchargeGoodsID,
    required this.count,
    required this.price,
  });

  factory SurchageGoodsChoose.fromJson(Map<String, dynamic> json) =>
      SurchageGoodsChoose(
        surchargeGoodsID: json["surcharge_goods_id"],
        count: json["count"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "package_id": surchargeGoodsID,
        "shipment_id": count,
        "package_quantity": price,
      };
}
