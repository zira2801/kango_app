// To parse this JSON data, do
//
//     final listOldReceiverModel = listOldReceiverModelFromJson(jsonString);

import 'dart:convert';

ListOldReceiverModel listOldReceiverModelFromJson(String str) =>
    ListOldReceiverModel.fromJson(json.decode(str));

String listOldReceiverModelToJson(ListOldReceiverModel data) =>
    json.encode(data.toJson());

class ListOldReceiverModel {
  int status;
  List<Receiver> receivers;

  ListOldReceiverModel({
    required this.status,
    required this.receivers,
  });

  factory ListOldReceiverModel.fromJson(Map<String, dynamic> json) =>
      ListOldReceiverModel(
        status: json["status"],
        receivers: List<Receiver>.from(
            json["receivers"].map((x) => Receiver.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "receivers": List<dynamic>.from(receivers.map((x) => x.toJson())),
      };
}

class Receiver {
  int receiverId;
  String receiverContactName;

  Receiver({
    required this.receiverId,
    required this.receiverContactName,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
        receiverId: json["receiver_id"],
        receiverContactName: json["receiver_contact_name"],
      );

  Map<String, dynamic> toJson() => {
        "receiver_id": receiverId,
        "receiver_contact_name": receiverContactName,
      };
}
