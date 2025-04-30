// To parse this JSON data, do
//
//     final detailsTicketModel = detailsTicketModelFromJson(jsonString);

import 'dart:convert';

DetailsTicketModel detailsTicketModelFromJson(String str) =>
    DetailsTicketModel.fromJson(json.decode(str));

String detailsTicketModelToJson(DetailsTicketModel data) =>
    json.encode(data.toJson());

class DetailsTicketModel {
  int status;
  Data data;

  DetailsTicketModel({
    required this.status,
    required this.data,
  });

  factory DetailsTicketModel.fromJson(Map<String, dynamic> json) =>
      DetailsTicketModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  int ticketId;
  int userId;
  String ticketTitle;
  int ticketKind;
  String ticketTransactionCode;
  int ticketStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  List<TicketMessage> ticketMessages;

  Data({
    required this.ticketId,
    required this.userId,
    required this.ticketTitle,
    required this.ticketKind,
    required this.ticketTransactionCode,
    required this.ticketStatus,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.ticketMessages,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        ticketId: json["ticket_id"],
        userId: json["user_id"],
        ticketTitle: json["ticket_title"],
        ticketKind: json["ticket_kind"],
        ticketTransactionCode: json["ticket_transaction_code"],
        ticketStatus: json["ticket_status"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        ticketMessages: List<TicketMessage>.from(
            json["ticket_messages"].map((x) => TicketMessage.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ticket_id": ticketId,
        "user_id": userId,
        "ticket_title": ticketTitle,
        "ticket_kind": ticketKind,
        "ticket_transaction_code": ticketTransactionCode,
        "ticket_status": ticketStatus,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "ticket_messages":
            List<dynamic>.from(ticketMessages.map((x) => x.toJson())),
      };
}

class TicketMessage {
  int? ticketMessageId;
  int? ticketId;
  int? senderId;
  int? answerId;
  String ticketMessageContent;
  int? ticketType;
  int? activeFlg;
  int? deleteFlg;
  String createdAt;
  String? updatedAt;

  TicketMessage({
    this.ticketMessageId,
    this.ticketId,
    this.senderId,
    this.answerId,
    required this.ticketMessageContent,
    this.ticketType,
    this.activeFlg,
    this.deleteFlg,
    required this.createdAt,
    this.updatedAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
        ticketMessageId: json["ticket_message_id"],
        ticketId: json["ticket_id"],
        senderId: json["sender_id"],
        answerId: json["answer_id"],
        ticketMessageContent: json["ticket_message_content"],
        ticketType: json["ticket_type"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "ticket_message_id": ticketMessageId,
        "ticket_id": ticketId,
        "sender_id": senderId,
        "answer_id": answerId,
        "ticket_message_content": ticketMessageContent,
        "ticket_type": ticketType,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
