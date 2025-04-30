// To parse this JSON data, do
//
//     final listHistoryTicketModel = listHistoryTicketModelFromJson(jsonString);

import 'dart:convert';

ListHistoryTicketModel listHistoryTicketModelFromJson(String str) =>
    ListHistoryTicketModel.fromJson(json.decode(str));

String listHistoryTicketModelToJson(ListHistoryTicketModel data) =>
    json.encode(data.toJson());

class ListHistoryTicketModel {
  int status;
  Data data;

  ListHistoryTicketModel({
    required this.status,
    required this.data,
  });

  factory ListHistoryTicketModel.fromJson(Map<String, dynamic> json) =>
      ListHistoryTicketModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  DataByStatus pending;
  DataByStatus processing;
  DataByStatus done;

  Data({
    required this.pending,
    required this.processing,
    required this.done,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        pending: DataByStatus.fromJson(json["pending"]),
        processing: DataByStatus.fromJson(json["processing"]),
        done: DataByStatus.fromJson(json["done"]),
      );

  Map<String, dynamic> toJson() => {
        "pending": pending.toJson(),
        "processing": processing.toJson(),
        "done": done.toJson(),
      };
}

class DataByStatus {
  int currentPage;
  List<DetailsItemTicket> data;
  String firstPageUrl;
  int? from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int? to;
  int total;

  DataByStatus({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory DataByStatus.fromJson(Map<String, dynamic> json) => DataByStatus(
        currentPage: json["current_page"],
        data: List<DetailsItemTicket>.from(
            json["data"].map((x) => DetailsItemTicket.fromJson(x))),
        firstPageUrl: json["first_page_url"],
        from: json["from"],
        lastPage: json["last_page"],
        lastPageUrl: json["last_page_url"],
        links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
        nextPageUrl: json["next_page_url"],
        path: json["path"],
        perPage: json["per_page"],
        prevPageUrl: json["prev_page_url"],
        to: json["to"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "first_page_url": firstPageUrl,
        "from": from,
        "last_page": lastPage,
        "last_page_url": lastPageUrl,
        "links": List<dynamic>.from(links.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
        "path": path,
        "per_page": perPage,
        "prev_page_url": prevPageUrl,
        "to": to,
        "total": total,
      };
}

class DetailsItemTicket {
  int ticketId;
  int userId;
  String ticketTitle;
  int ticketKind;
  String? ticketTransactionCode;
  int ticketStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  DetailsItemTicket({
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
  });

  factory DetailsItemTicket.fromJson(Map<String, dynamic> json) =>
      DetailsItemTicket(
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
      };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
        url: json["url"],
        label: json["label"],
        active: json["active"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "label": label,
        "active": active,
      };
}
