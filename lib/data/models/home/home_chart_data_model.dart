// To parse this JSON data, do
//
//     final homeChartDataModel = homeChartDataModelFromJson(jsonString);

import 'dart:convert';

HomeChartDataModel homeChartDataModelFromJson(String str) =>
    HomeChartDataModel.fromJson(json.decode(str));

String homeChartDataModelToJson(HomeChartDataModel data) =>
    json.encode(data.toJson());

class HomeChartDataModel {
  int status;
  Data data;
  User user;
  dynamic totalNumberBill;
  dynamic totalWeight;
  dynamic totalPrice;
  dynamic totalPriceCustomer;
  dynamic totalCreated;
  dynamic totalImported;
  dynamic totalExported;
  dynamic totalReturned;
  dynamic perCreated;
  dynamic perImported;
  dynamic perExported;
  dynamic perReturned;

  HomeChartDataModel({
    required this.status,
    required this.data,
    required this.user,
    this.totalNumberBill,
    this.totalWeight,
    this.totalPrice,
    this.totalPriceCustomer,
    this.totalCreated,
    this.totalImported,
    this.totalExported,
    this.totalReturned,
    this.perCreated,
    this.perImported,
    this.perExported,
    this.perReturned,
  });

  factory HomeChartDataModel.fromJson(Map<String, dynamic> json) =>
      HomeChartDataModel(
        status: json["status"] ?? 0, // Giá trị mặc định 0 nếu null
        data: json["data"] != null
            ? Data.fromJson(json["data"])
            : Data(categories: [], series: []),
        user: json["user"] != null
            ? User.fromJson(json["user"])
            : User(userLimitAmountForSale: 0, userRemainingLimit: 0),
        totalNumberBill: json["total_number_bill"] ?? 0,
        totalWeight: json["total_weight"] ?? 0.0,
        totalPrice: json["total_price"] ?? 0.0,
        totalPriceCustomer: json["total_price_customer"] ?? 0.0,
        totalCreated: json["total_created"] ?? 0,
        totalImported: json["total_imported"] ?? 0,
        totalExported: json["total_exported"] ?? 0,
        totalReturned: json["total_returned"] ?? 0,
        perCreated: json["per_created"] ?? 0.0,
        perImported: json["per_imported"] ?? 0.0,
        perExported: json["per_exported"] ?? 0.0,
        perReturned: json["per_returned"] ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "user": user.toJson(),
        "total_number_bill": totalNumberBill,
        "total_weight": totalWeight,
        "total_price": totalPrice,
        "total_price_customer": totalPriceCustomer,
        "total_created": totalCreated,
        "total_imported": totalImported,
        "total_exported": totalExported,
        "total_returned": totalReturned,
        "per_created": perCreated,
        "per_imported": perImported,
        "per_exported": perExported,
        "per_returned": perReturned,
      };
}

class Data {
  List<String> categories;
  List<Series> series;

  Data({
    required this.categories,
    required this.series,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        categories: json["categories"] != null
            ? List<String>.from(json["categories"].map((x) => x.toString()))
            : [],
        series: json["series"] != null
            ? List<Series>.from(json["series"].map((x) => Series.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x)),
        "series": List<dynamic>.from(series.map((x) => x.toJson())),
      };
}

// The rest of your model classes remain the same
class Series {
  String name;
  List<int> data;

  Series({
    required this.name,
    required this.data,
  });

  factory Series.fromJson(Map<String, dynamic> json) => Series(
        name: json["name"] ?? "Unknown",
        data: json["data"] != null
            ? List<int>.from(json["data"].map((x) => x ?? 0))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "data": List<dynamic>.from(data.map((x) => x)),
      };
}

class User {
  dynamic userLimitAmountForSale;
  dynamic userRemainingLimit;

  User({
    this.userLimitAmountForSale,
    this.userRemainingLimit,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userLimitAmountForSale: json["user_limit_amount_for_sale"] ?? 0,
        userRemainingLimit: json["user_remaining_limit"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "user_limit_amount_for_sale": userLimitAmountForSale,
        "user_remaining_limit": userRemainingLimit,
      };
}
