// To parse this JSON data, do
//
//     final listTypeTicketModel = listTypeTicketModelFromJson(jsonString);

import 'dart:convert';

ListTypeTicketModel listTypeTicketModelFromJson(String str) =>
    ListTypeTicketModel.fromJson(json.decode(str));

String listTypeTicketModelToJson(ListTypeTicketModel data) =>
    json.encode(data.toJson());

class ListTypeTicketModel {
  int status;
  bool isUseTicket;
  Map<String, String> tiketKinds;

  ListTypeTicketModel({
    required this.status,
    required this.isUseTicket,
    required this.tiketKinds,
  });

  factory ListTypeTicketModel.fromJson(Map<String, dynamic> json) =>
      ListTypeTicketModel(
        status: json["status"],
        isUseTicket: json["is_use_ticket"],
        tiketKinds: Map.from(json["tiket_kinds"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "is_use_ticket": isUseTicket,
        "tiket_kinds":
            Map.from(tiketKinds).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
