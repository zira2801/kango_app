// To parse this JSON data, do
//
//     final areaModel = areaModelFromJson(jsonString);

import 'dart:convert';

AreaModel areaModelFromJson(String str) => AreaModel.fromJson(json.decode(str));

String areaModelToJson(AreaModel data) => json.encode(data.toJson());

class AreaModel {
  int status;
  Areas areas;

  AreaModel({
    required this.status,
    required this.areas,
  });

  factory AreaModel.fromJson(Map<String, dynamic> json) => AreaModel(
        status: json["status"],
        areas: Areas.fromJson(json["areas"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "areas": areas.toJson(),
      };
}

class Areas {
  List<Country> countries;
  List<StateName> states;
  List<City> cities;

  Areas({
    required this.countries,
    required this.states,
    required this.cities,
  });

  factory Areas.fromJson(Map<String, dynamic> json) => Areas(
        countries: List<Country>.from(
            json["countries"].map((x) => Country.fromJson(x))),
        states: List<StateName>.from(
            json["states"].map((x) => StateName.fromJson(x))),
        cities: List<City>.from(json["cities"].map((x) => City.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "countries": List<dynamic>.from(countries.map((x) => x.toJson())),
        "states": List<dynamic>.from(states.map((x) => x.toJson())),
        "cities": List<dynamic>.from(cities.map((x) => x.toJson())),
      };
}

class City {
  int cityId;
  String cityName;
  dynamic cityCode;
  dynamic cityPostCode;

  City({
    required this.cityId,
    required this.cityName,
    required this.cityCode,
    required this.cityPostCode,
  });

  factory City.fromJson(Map<String, dynamic> json) => City(
        cityId: json["city_id"],
        cityName: json["city_name"],
        cityCode: json["city_code"],
        cityPostCode: json["city_post_code"],
      );

  Map<String, dynamic> toJson() => {
        "city_id": cityId,
        "city_name": cityName,
        "city_code": cityCode,
        "city_post_code": cityPostCode,
      };
}

class Country {
  int countryId;
  String countryName;
  String countryCode;

  Country({
    required this.countryId,
    required this.countryName,
    required this.countryCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        countryId: json["country_id"],
        countryName: json["country_name"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "country_id": countryId,
        "country_name": countryName,
        "country_code": countryCode,
      };
}

class StateName {
  int stateId;
  String stateName;
  String stateCode;
  dynamic statePostCode;

  StateName({
    required this.stateId,
    required this.stateName,
    required this.stateCode,
    required this.statePostCode,
  });

  factory StateName.fromJson(Map<String, dynamic> json) => StateName(
        stateId: json["state_id"],
        stateName: json["state_name"],
        stateCode: json["state_code"],
        statePostCode: json["state_post_code"],
      );

  Map<String, dynamic> toJson() => {
        "state_id": stateId,
        "state_name": stateName,
        "state_code": stateCode,
        "state_post_code": statePostCode,
      };
}
