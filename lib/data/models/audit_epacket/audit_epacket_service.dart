import 'dart:convert';

AuditEpacketService auditepacketServiceModelFromJson(String str) =>
    AuditEpacketService.fromJson(json.decode(str));

String auditepacketServiceModelToJson(AuditEpacketService data) =>
    json.encode(data.toJson());

class AuditEpacketService {
  final int status;
  final List<DataService> services;
  AuditEpacketService({required this.status, required this.services});
  factory AuditEpacketService.fromJson(Map<String, dynamic> json) {
    return AuditEpacketService(
      status: json['status'],
      services: (json['data'] as List)
          .map((item) => DataService.fromJson(item))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
        "status": status,
        "shipments": services.map((item) => item.toJson()).toList(),
      };
}

class DataService {
  final int id;
  final String serviceName;

  DataService({
    required this.id,
    required this.serviceName,
  });

  factory DataService.fromJson(Map<String, dynamic> json) {
    return DataService(
      id: json['service_id'],
      serviceName: json['service_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': id,
      'service_name': serviceName,
    };
  }
}
