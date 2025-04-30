// To parse this JSON data, do
//
//     final deliveryServiceModel = deliveryServiceModelFromJson(jsonString);

import 'dart:convert';

DeliveryServiceModel deliveryServiceModelFromJson(String str) =>
    DeliveryServiceModel.fromJson(json.decode(str));

String deliveryServiceModelToJson(DeliveryServiceModel data) =>
    json.encode(data.toJson());

class DeliveryServiceModel {
  int status;
  List<Service> services;

  DeliveryServiceModel({
    required this.status,
    required this.services,
  });

  factory DeliveryServiceModel.fromJson(Map<String, dynamic> json) =>
      DeliveryServiceModel(
        status: json["status"],
        services: List<Service>.from(
            json["services"].map((x) => Service.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "services": List<dynamic>.from(services.map((x) => x.toJson())),
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
