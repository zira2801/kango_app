import 'dart:convert';

InfoOldReceiverModel infoOldReceiverModelFromJson(String str) =>
    InfoOldReceiverModel.fromJson(json.decode(str));

String infoOldReceiverModelToJson(InfoOldReceiverModel data) =>
    json.encode(data.toJson());

class InfoOldReceiverModel {
  final int? status;
  final Receivers? receivers;

  InfoOldReceiverModel({
    this.status,
    this.receivers,
  });

  factory InfoOldReceiverModel.fromJson(Map<String, dynamic>? json) =>
      InfoOldReceiverModel(
        status: json?["status"],
        receivers: json?["receivers"] != null
            ? Receivers.fromJson(json?["receivers"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "receivers": receivers?.toJson(),
      };
}

class Receivers {
  final int? receiverId;
  final int? userId;
  final String? receiverCompanyName;
  final String? receiverContactName;
  final String? receiverTelephone;
  final int? receiverCountryId;
  final int? receiverStateId;
  final int? receiverCityId;
  final String? receiverPostalCode;
  final String? receiverAddress1;
  final dynamic receiverAddress2;
  final dynamic receiverAddress3;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Receivers({
    this.receiverId,
    this.userId,
    this.receiverCompanyName,
    this.receiverContactName,
    this.receiverTelephone,
    this.receiverCountryId,
    this.receiverStateId,
    this.receiverCityId,
    this.receiverPostalCode,
    this.receiverAddress1,
    this.receiverAddress2,
    this.receiverAddress3,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
  });

  factory Receivers.fromJson(Map<String, dynamic>? json) => Receivers(
        receiverId: json?["receiver_id"],
        userId: json?["user_id"],
        receiverCompanyName: json?["receiver_company_name"],
        receiverContactName: json?["receiver_contact_name"],
        receiverTelephone: json?["receiver_telephone"],
        receiverCountryId:
            json?["receiver_country_id"] ?? 0, // nếu null, mặc định là 0
        receiverStateId:
            json?["receiver_state_id"] ?? 0, // nếu null, mặc định là 0
        receiverCityId: json?["receiver_city_id"],
        receiverPostalCode: json?["receiver_postal_code"],
        receiverAddress1: json?["receiver_address_1"],
        receiverAddress2: json?["receiver_address_2"],
        receiverAddress3: json?["receiver_address_3"],
        activeFlg: json?["active_flg"],
        deleteFlg: json?["delete_flg"],
        createdAt: json?["created_at"] != null
            ? DateTime.parse(json?["created_at"])
            : null,
        updatedAt: json?["updated_at"] != null
            ? DateTime.parse(json?["updated_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "receiver_id": receiverId,
        "user_id": userId,
        "receiver_company_name": receiverCompanyName,
        "receiver_contact_name": receiverContactName,
        "receiver_telephone": receiverTelephone,
        "receiver_country_id": receiverCountryId,
        "receiver_state_id": receiverStateId,
        "receiver_city_id": receiverCityId,
        "receiver_postal_code": receiverPostalCode,
        "receiver_address_1": receiverAddress1,
        "receiver_address_2": receiverAddress2,
        "receiver_address_3": receiverAddress3,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
