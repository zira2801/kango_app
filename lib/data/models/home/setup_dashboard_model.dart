// To parse this JSON data, do
//
//     final setUpDashBoardModel = setUpDashBoardModelFromJson(jsonString);

import 'dart:convert';

SetUpDashBoardModel setUpDashBoardModelFromJson(String str) =>
    SetUpDashBoardModel.fromJson(json.decode(str));

String setUpDashBoardModelToJson(SetUpDashBoardModel data) =>
    json.encode(data.toJson());

class SetUpDashBoardModel {
  int status;
  List<Position> positions;
  List<Service> services;
  List<String> shipmentStatus;
  FiltersByDate filtersByDate;
  FiltersByType filtersByType;
  List<Branch> branchs;

  SetUpDashBoardModel({
    required this.status,
    required this.positions,
    required this.services,
    required this.shipmentStatus,
    required this.filtersByDate,
    required this.filtersByType,
    required this.branchs,
  });

  factory SetUpDashBoardModel.fromJson(Map<String, dynamic> json) =>
      SetUpDashBoardModel(
        status: json["status"],
        positions: List<Position>.from(
            json["positions"].map((x) => Position.fromJson(x))),
        services: List<Service>.from(
            json["services"].map((x) => Service.fromJson(x))),
        shipmentStatus:
            List<String>.from(json["shipment_status"].map((x) => x)),
        filtersByDate: FiltersByDate.fromJson(json["filters_by_date"]),
        filtersByType: FiltersByType.fromJson(json["filters_by_type"]),
        branchs:
            List<Branch>.from(json["branchs"].map((x) => Branch.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "positions": List<dynamic>.from(positions.map((x) => x.toJson())),
        "services": List<dynamic>.from(services.map((x) => x.toJson())),
        "shipment_status": List<dynamic>.from(shipmentStatus.map((x) => x)),
        "filters_by_date": filtersByDate.toJson(),
        "filters_by_type": filtersByType.toJson(),
        "branchs": List<dynamic>.from(branchs.map((x) => x.toJson())),
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

class FiltersByDate {
  String hhDMY;
  String dMY;
  String mY;
  String y;

  FiltersByDate({
    required this.hhDMY,
    required this.dMY,
    required this.mY,
    required this.y,
  });

  factory FiltersByDate.fromJson(Map<String, dynamic> json) => FiltersByDate(
        hhDMY: json["%Hh %d-%m-%Y"],
        dMY: json["%d-%m-%Y"],
        mY: json["%m-%Y"],
        y: json["%Y"],
      );

  Map<String, dynamic> toJson() => {
        "%Hh %d-%m-%Y": hhDMY,
        "%d-%m-%Y": dMY,
        "%m-%Y": mY,
        "%Y": y,
      };
  Map<String, String> toMap() {
    return {
      "%Hh %d-%m-%Y": hhDMY,
      "%d-%m-%Y": dMY,
      "%m-%Y": mY,
      "%Y": y,
    };
  }
}

class FiltersByType {
  String numberBill;
  String totalWeight;
  String totalPrice;
  String totalPriceCustomer;

  FiltersByType({
    required this.numberBill,
    required this.totalWeight,
    required this.totalPrice,
    required this.totalPriceCustomer,
  });

  factory FiltersByType.fromJson(Map<String, dynamic> json) => FiltersByType(
        numberBill: json["number_bill"],
        totalWeight: json["total_weight"],
        totalPrice: json["total_price"],
        totalPriceCustomer: json["total_price_customer"],
      );

  Map<String, dynamic> toJson() => {
        "number_bill": numberBill,
        "total_weight": totalWeight,
        "total_price": totalPrice,
        "total_price_customer": totalPriceCustomer,
      };

  Map<String, String> toMap() {
    return {
      "number_bill": numberBill,
      "total_weight": totalWeight,
      "total_price": totalPrice,
      "total_price_customer": totalPriceCustomer,
    };
  }
}

class Position {
  String positionName;
  int positionId;
  int countUser;

  Position({
    required this.positionName,
    required this.positionId,
    required this.countUser,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        positionName: json["position_name"],
        positionId: json["position_id"],
        countUser: json["count_user"],
      );

  Map<String, dynamic> toJson() => {
        "position_name": positionName,
        "position_id": positionId,
        "count_user": countUser,
      };
}

class Service {
  int serviceId;
  String serviceName;

  Service({
    required this.serviceId,
    required this.serviceName,
  });

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        serviceId: json["service_id"],
        serviceName: json["service_name"],
      );

  Map<String, dynamic> toJson() => {
        "service_id": serviceId,
        "service_name": serviceName,
      };
}
