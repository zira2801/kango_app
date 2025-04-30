import 'dart:convert';

AuditEpacketResponse auditepacketModelFromJson(String str) =>
    AuditEpacketResponse.fromJson(json.decode(str));

String auditepacketModelToJson(AuditEpacketResponse data) =>
    json.encode(data.toJson());

class AuditEpacketResponse {
  final int status;
  final Shipments shipments;
  AuditEpacketResponse({required this.status, required this.shipments});
  factory AuditEpacketResponse.fromJson(Map<String, dynamic> json) {
    return AuditEpacketResponse(
        status: json['status'],
        shipments: Shipments.fromJson(json['shipments']));
  }
  Map<String, dynamic> toJson() => {
        "status": status,
        "shipments": shipments.toJson(),
      };
}

class Shipments {
  final int currentPage;
  final List<ShipmentAuditEpacket> data;

  Shipments({
    required this.currentPage,
    required this.data,
  });

  factory Shipments.fromJson(Map<String, dynamic> json) {
    return Shipments(
      currentPage: json['current_page'],
      data: (json['data'] as List)
          .map((item) => ShipmentAuditEpacket.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class ShipmentAuditEpacket {
  final int shipmentId;
  final String shipmentCode;
  final int shipmentServiceId;
  final int shipmentStatus;
  final String shipmentGoodsName;
  final double shipmentValue;
  final double shipmentAmountTotalCustomer;
  final double shipmentAmountTransport;
  final double shipmentAmountInsurance;
  final double shipmentAmountVat;
  final double shipmentAmountOperatingCosts;
  final double shipmentAmountDiscount;
  final double shipmentAmountServiceActual;
  final double shipmentTotalAmountActual;
  final double shipmentFinalAmount;
  final int shipmentPaymentMethod;
  final int shipmentPaymentStatus;
  final String? shipmentNote;
  final int userId;
  final String senderCompanyName;
  final String senderContactName;
  final String senderTelephone;
  final String senderAddress;
  final String receiverCompanyName;
  final String receiverContactName;
  final String receiverTelephone;
  final String receiverAddress1;
  final String receiverAddress2;
  final String receiverAddress3;
  final String createdAt;
  final String updatedAt;
  final int activeFlg;
  final int deleteFlg;
  final String completedDate;

  ShipmentAuditEpacket({
    required this.shipmentId,
    required this.shipmentCode,
    required this.shipmentServiceId,
    required this.shipmentStatus,
    required this.shipmentGoodsName,
    required this.shipmentValue,
    required this.shipmentAmountTotalCustomer,
    required this.shipmentAmountTransport,
    required this.shipmentAmountInsurance,
    required this.shipmentAmountVat,
    required this.shipmentAmountOperatingCosts,
    required this.shipmentAmountDiscount,
    required this.shipmentAmountServiceActual,
    required this.shipmentTotalAmountActual,
    required this.shipmentFinalAmount,
    required this.shipmentPaymentMethod,
    required this.shipmentPaymentStatus,
    this.shipmentNote,
    required this.userId,
    required this.senderCompanyName,
    required this.senderContactName,
    required this.senderTelephone,
    required this.senderAddress,
    required this.receiverCompanyName,
    required this.receiverContactName,
    required this.receiverTelephone,
    required this.receiverAddress1,
    required this.receiverAddress2,
    required this.receiverAddress3,
    required this.createdAt,
    required this.updatedAt,
    required this.activeFlg,
    required this.deleteFlg,
    required this.completedDate,
  });

  /// Chuyển đổi từ JSON sang Object
  factory ShipmentAuditEpacket.fromJson(Map<String, dynamic> json) {
    return ShipmentAuditEpacket(
      shipmentId: json['shipment_id'],
      shipmentCode: json['shipment_code'],
      shipmentServiceId: json['shipment_service_id'],
      shipmentStatus: json['shipment_status'],
      shipmentGoodsName: json['shipment_goods_name'],
      shipmentValue: (json['shipment_value'] ?? 0).toDouble(),
      shipmentAmountTotalCustomer:
          (json['shipment_amount_total_customer'] ?? 0).toDouble(),
      shipmentAmountTransport:
          (json['shipment_amount_transport'] ?? 0).toDouble(),
      shipmentAmountInsurance:
          (json['shipment_amount_insurance'] ?? 0).toDouble(),
      shipmentAmountVat: (json['shipment_amount_vat'] ?? 0).toDouble(),
      shipmentAmountOperatingCosts:
          (json['shipment_amount_operating_costs'] ?? 0).toDouble(),
      shipmentAmountDiscount:
          (json['shipment_amount_discount'] ?? 0).toDouble(),
      shipmentAmountServiceActual:
          (json['shipment_amount_service_actual'] ?? 0).toDouble(),
      shipmentTotalAmountActual:
          (json['shipment_total_amount_actual'] ?? 0).toDouble(),
      shipmentFinalAmount: (json['shipment_final_amount'] ?? 0).toDouble(),
      shipmentPaymentMethod: json['shipment_payment_method'],
      shipmentPaymentStatus: json['shipment_payment_status'],
      shipmentNote: json['shipment_note'],
      userId: json['user_id'],
      senderCompanyName: json['sender_company_name'],
      senderContactName: json['sender_contact_name'],
      senderTelephone: json['sender_telephone'],
      senderAddress: json['sender_address'],
      receiverCompanyName: json['receiver_company_name'],
      receiverContactName: json['receiver_contact_name'],
      receiverTelephone: json['receiver_telephone'],
      receiverAddress1: json['receiver_address_1'],
      receiverAddress2: json['receiver_address_2'],
      receiverAddress3: json['receiver_address_3'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      activeFlg: json['active_flg'],
      deleteFlg: json['delete_flg'],
      completedDate: json['completed_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shipment_id': shipmentId,
      'shipment_code': shipmentCode,
      'shipment_service_id': shipmentServiceId,
      'shipment_status': shipmentStatus,
      'shipment_goods_name': shipmentGoodsName,
      'shipment_value': shipmentValue,
      'shipment_amount_total_customer': shipmentAmountTotalCustomer,
      'shipment_amount_transport': shipmentAmountTransport,
      'shipment_amount_insurance': shipmentAmountInsurance,
      'shipment_amount_vat': shipmentAmountVat,
      'shipment_amount_operating_costs': shipmentAmountOperatingCosts,
      "shipment_amount_discount": shipmentAmountDiscount,
      "shipment_amount_service_actual": shipmentAmountServiceActual,
      "shipment_total_amount_actual": shipmentTotalAmountActual,
      'shipment_final_amount': shipmentFinalAmount,
      'shipment_payment_method': shipmentPaymentMethod,
      'shipment_payment_status': shipmentPaymentStatus,
      'shipment_note': shipmentNote,
      'user_id': userId,
      'sender_company_name': senderCompanyName,
      'sender_contact_name': senderContactName,
      'sender_telephone': senderTelephone,
      'sender_address': senderAddress,
      'receiver_company_name': receiverCompanyName,
      'receiver_contact_name': receiverContactName,
      'receiver_telephone': receiverTelephone,
      'receiver_address_1': receiverAddress1,
      'receiver_address_2': receiverAddress2,
      'receiver_address_3': receiverAddress3,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'completed_date': completedDate,
    };
  }

  @override
  String toString() {
    return 'Shipment{shipmentId: $shipmentId, shipmentCode: $shipmentCode, status: $createdAt}';
  }
}
