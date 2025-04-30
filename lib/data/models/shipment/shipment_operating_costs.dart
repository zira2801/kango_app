class ChildOperatingCost {
  int operatingCostId;
  String operatingCostName;
  dynamic operatingCostAmount;
  dynamic shipmentOperatingCostId;
  int? shipmentOperatingCostAmount;
  // int operatingCostDefaultFlg;
  dynamic shipmentOperatingCostQuantity;

  ChildOperatingCost({
    required this.operatingCostId,
    required this.operatingCostName,
    required this.operatingCostAmount,
    // required this.operatingCostDefaultFlg,
    required this.shipmentOperatingCostId,
    this.shipmentOperatingCostAmount,
    this.shipmentOperatingCostQuantity,
  });

  factory ChildOperatingCost.fromJson(Map<String, dynamic> json) {
    return ChildOperatingCost(
      operatingCostId: json['operating_cost_id'],
      operatingCostName: json['operating_cost_name'],
      operatingCostAmount: json['operating_cost_amount'],
      // operatingCostDefaultFlg: json['operating_cost_default_flg'],
      shipmentOperatingCostId: json['shipment_operating_cost_id'],
      shipmentOperatingCostAmount: json['shipment_operating_cost_amount'],
      shipmentOperatingCostQuantity: json['shipment_operating_cost_quantity'],
    );
  }
}

class OperatingCost {
  int operatingCostId;
  String operatingCostName;
  String? operatingCostDescription;
  int operatingCostType;
  int operatingCostPackageNumberFlg;
  List<ChildOperatingCost> childOperatingCost;

  OperatingCost({
    required this.operatingCostId,
    required this.operatingCostName,
    required this.operatingCostType,
    this.operatingCostDescription,
    required this.childOperatingCost,
    required this.operatingCostPackageNumberFlg,
  });

  factory OperatingCost.fromJson(Map<String, dynamic> json) {
    return OperatingCost(
      operatingCostId: json['operating_cost_id'],
      operatingCostName: json['operating_cost_name'],
      operatingCostDescription: json['operating_cost_description'],
      operatingCostType: json['operating_cost_type'],
      operatingCostPackageNumberFlg: json['operating_cost_package_number_flg'],
      childOperatingCost: (json['child_operating_cost'] as List)
          .map((i) => ChildOperatingCost.fromJson(i))
          .toList(),
    );
  }
}
