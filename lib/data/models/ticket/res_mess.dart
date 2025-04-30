// To parse this JSON data, do
//
//     final resMessTicketModel = resMessTicketModelFromJson(jsonString);

import 'dart:convert';

ResMessTicketModel resMessTicketModelFromJson(String str) =>
    ResMessTicketModel.fromJson(json.decode(str));

String resMessTicketModelToJson(ResMessTicketModel data) =>
    json.encode(data.toJson());

class ResMessTicketModel {
  int status;
  String ticketMessageContent;
  String createdAt;

  ResMessTicketModel({
    required this.status,
    required this.ticketMessageContent,
    required this.createdAt,
  });

  factory ResMessTicketModel.fromJson(Map<String, dynamic> json) =>
      ResMessTicketModel(
        status: json["status"],
        ticketMessageContent: json["ticket_message_content"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "ticket_message_content": ticketMessageContent,
        "created_at": createdAt,
      };
}
