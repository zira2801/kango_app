// To parse this JSON data, do
//
//     final listTypeServiceModel = listTypeServiceModelFromJson(jsonString);

import 'dart:convert';

ListTypeServiceModel listTypeServiceModelFromJson(String str) =>
    ListTypeServiceModel.fromJson(json.decode(str));

String listTypeServiceModelToJson(ListTypeServiceModel data) =>
    json.encode(data.toJson());

class ListTypeServiceModel {
  int status;
  Map<String, String> serviceTypes;

  ListTypeServiceModel({
    required this.status,
    required this.serviceTypes,
  });

  factory ListTypeServiceModel.fromJson(Map<String, dynamic> json) =>
      ListTypeServiceModel(
        status: json["status"],
        serviceTypes: Map.from(json["service_types"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "service_types": Map.from(serviceTypes)
            .map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
