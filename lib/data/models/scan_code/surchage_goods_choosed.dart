class SurchageGoodsChoosed {
  int surchargeGoodsID;
  int count;
  double price;

  SurchageGoodsChoosed({
    required this.surchargeGoodsID,
    required this.count,
    required this.price,
  });

  factory SurchageGoodsChoosed.fromJson(Map<String, dynamic> json) =>
      SurchageGoodsChoosed(
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
