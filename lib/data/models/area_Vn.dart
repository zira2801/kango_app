// To parse this JSON data, do
//
//     final areaVnModel = areaVnModelFromJson(jsonString);

import 'dart:convert';

AreaVnModel areaVnModelFromJson(String str) =>
    AreaVnModel.fromJson(json.decode(str));

String areaVnModelToJson(AreaVnModel data) => json.encode(data.toJson());

class AreaVnModel {
  int status;
  Areas areas;

  AreaVnModel({
    required this.status,
    required this.areas,
  });

  factory AreaVnModel.fromJson(Map<String, dynamic> json) => AreaVnModel(
        status: json["status"],
        areas: Areas.fromJson(json["areas"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "areas": areas.toJson(),
      };
}

class Areas {
  List<String> cities;
  List<String> districts;
  List<String> wards;

  Areas({
    required this.cities,
    required this.districts,
    required this.wards,
  });

  factory Areas.fromJson(Map<String, dynamic> json) => Areas(
        cities: List<String>.from(json["cities"].map((x) => x)),
        districts: List<String>.from(json["districts"].map((x) => x)),
        wards: List<String>.from(json["wards"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "cities": List<dynamic>.from(cities.map((x) => x)),
        "districts": List<dynamic>.from(districts.map((x) => x)),
        "wards": List<dynamic>.from(wards.map((x) => x)),
      };
}
