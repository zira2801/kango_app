// To parse this JSON data, do
//
//     final allUnitShipmentModel = allUnitShipmentModelFromJson(jsonString);

import 'dart:convert';

AllUnitShipmentModel allUnitShipmentModelFromJson(String str) =>
    AllUnitShipmentModel.fromJson(json.decode(str));

String allUnitShipmentModelToJson(AllUnitShipmentModel data) =>
    json.encode(data.toJson());

class AllUnitShipmentModel {
  int status;
  Data data;

  AllUnitShipmentModel({
    required this.status,
    required this.data,
  });

  factory AllUnitShipmentModel.fromJson(Map<String, dynamic> json) =>
      AllUnitShipmentModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  List<String> packageTypes;
  List<String> invoiceExportsAs;
  List<String> invoiceUnits;

  Data({
    required this.packageTypes,
    required this.invoiceExportsAs,
    required this.invoiceUnits,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        packageTypes: List<String>.from(json["package_types"].map((x) => x)),
        invoiceExportsAs:
            List<String>.from(json["invoice_exports_as"].map((x) => x)),
        invoiceUnits: List<String>.from(json["invoice_units"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "package_types": List<dynamic>.from(packageTypes.map((x) => x)),
        "invoice_exports_as":
            List<dynamic>.from(invoiceExportsAs.map((x) => x)),
        "invoice_units": List<dynamic>.from(invoiceUnits.map((x) => x)),
      };
}
