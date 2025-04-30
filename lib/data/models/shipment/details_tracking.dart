// To parse this JSON data, do
//
//     final detailsTrackingModel = detailsTrackingModelFromJson(jsonString);

import 'dart:convert';

DetailsTrackingModel detailsTrackingModelFromJson(String str) =>
    DetailsTrackingModel.fromJson(json.decode(str));

String detailsTrackingModelToJson(DetailsTrackingModel data) =>
    json.encode(data.toJson());

class DetailsTrackingModel {
  int status;
  Data data;

  DetailsTrackingModel({
    required this.status,
    required this.data,
  });

  factory DetailsTrackingModel.fromJson(Map<String, dynamic> json) =>
      DetailsTrackingModel(
        status: json["status"],
        data: Data.fromJson(json["data"]), // Line 25 where error occurs
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
      };
}

class Data {
  final Tracking? tracking;
  final String code;
  final ShipmentDetailsTracking shipment;
  final PackageDetailsTracking package;
  final List<dynamic> packageTypes;
  final TrackingHeader? trackingHeader;
  final RightLocation? rightLocation;
  final List<TrackingLocal>? trackingLocal;
  Data({
    required this.tracking,
    required this.code,
    required this.shipment,
    required this.package,
    required this.packageTypes,
    this.trackingHeader,
    this.rightLocation,
    this.trackingLocal,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        tracking: json["tracking"] != null && json["tracking"] is Map
            ? Tracking.fromJson(json["tracking"] as Map<String, dynamic>)
            : Tracking(), // hoặc null tùy vào logic của bạn
        code: json["code"],
        shipment: ShipmentDetailsTracking.fromJson(json["shipment"]),
        package: PackageDetailsTracking.fromJson(json["package"]),
        packageTypes: List<dynamic>.from(json["package_types"].map((x) => x)),
        trackingHeader:
            json["tracking_header"] != null && json["tracking_header"] is Map
                ? TrackingHeader.fromJson(
                    json["tracking_header"] as Map<String, dynamic>)
                : null, // hoặc null tùy vào logic của bạn
        rightLocation:
            json["right_location"] != null && json["right_location"] is Map
                ? RightLocation.fromJson(
                    json["right_location"] as Map<String, dynamic>)
                : null, // hoặc null tùy vào logic của bạn
        trackingLocal: json["tracking_local"] != null &&
                json["tracking_local"] is List
            ? List<TrackingLocal>.from(
                json["tracking_local"].map((x) => TrackingLocal.fromJson(x)))
            : null, // hoặc null tùy vào logic của bạn
      );

  Map<String, dynamic> toJson() => {
        "tracking": tracking, // Remove the .tracktry access
        "code": code,
        "shipment": shipment.toJson(),
        "package": package.toJson(),
        "package_types": List<dynamic>.from(packageTypes.map((x) => x)),
      };
}

class PackageDetailsTracking {
  int packageId;
  int shipmentId;
  dynamic packageCode;
  dynamic packageQuantity;
  int packageType;
  dynamic packageDescription;
  dynamic packageLength;
  dynamic packageWidth;
  dynamic packageHeight;
  double packageWeight;
  dynamic packageHawbCode;
  dynamic packageConvertedWeight;
  double packageChargedWeight;
  dynamic packageTrackingCode;
  dynamic carrierCode;
  dynamic packageImage;
  dynamic bagCode;
  dynamic smTracktryId;
  dynamic branchConnect;
  dynamic packageStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  PackageDetailsTracking({
    required this.packageId,
    required this.shipmentId,
    required this.packageCode,
    required this.packageQuantity,
    required this.packageType,
    required this.packageDescription,
    required this.packageLength,
    required this.packageWidth,
    required this.packageHeight,
    required this.packageWeight,
    required this.packageHawbCode,
    required this.packageConvertedWeight,
    required this.packageChargedWeight,
    required this.packageTrackingCode,
    required this.carrierCode,
    required this.packageImage,
    required this.bagCode,
    required this.smTracktryId,
    required this.branchConnect,
    required this.packageStatus,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageDetailsTracking.fromJson(Map<String, dynamic> json) =>
      PackageDetailsTracking(
        packageId: json["package_id"],
        shipmentId: json["shipment_id"],
        packageCode: json["package_code"],
        packageQuantity: json["package_quantity"],
        packageType: json["package_type"],
        packageDescription: json["package_description"],
        packageLength: json["package_length"],
        packageWidth: json["package_width"],
        packageHeight: json["package_height"],
        packageWeight: json["package_weight"]?.toDouble(),
        packageHawbCode: json["package_hawb_code"],
        packageConvertedWeight: json["package_converted_weight"],
        packageChargedWeight: json["package_charged_weight"]?.toDouble(),
        packageTrackingCode: json["package_tracking_code"],
        carrierCode: json["carrier_code"],
        packageImage: json["package_image"],
        bagCode: json["bag_code"],
        smTracktryId: json["sm_tracktry_id"],
        branchConnect: json["branch_connect"],
        packageStatus: json["package_status"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "package_id": packageId,
        "shipment_id": shipmentId,
        "package_code": packageCode,
        "package_quantity": packageQuantity,
        "package_type": packageType,
        "package_description": packageDescription,
        "package_length": packageLength,
        "package_width": packageWidth,
        "package_height": packageHeight,
        "package_weight": packageWeight,
        "package_hawb_code": packageHawbCode,
        "package_converted_weight": packageConvertedWeight,
        "package_charged_weight": packageChargedWeight,
        "package_tracking_code": packageTrackingCode,
        "carrier_code": carrierCode,
        "package_image": packageImage,
        "bag_code": bagCode,
        "sm_tracktry_id": smTracktryId,
        "branch_connect": branchConnect,
        "package_status": packageStatus,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

// Tracking Header model
class TrackingHeader {
  final String packageTrackingDate;
  final String packageTrackingAddress;
  final String packageTrackingNote;

  TrackingHeader({
    required this.packageTrackingDate,
    required this.packageTrackingAddress,
    required this.packageTrackingNote,
  });

  factory TrackingHeader.fromJson(Map<String, dynamic> json) {
    return TrackingHeader(
      packageTrackingDate: json['package_tracking_date'],
      packageTrackingAddress: json['package_tracking_address'],
      packageTrackingNote: json['package_tracking_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_tracking_date': packageTrackingDate,
      'package_tracking_address': packageTrackingAddress,
      'package_tracking_note': packageTrackingNote,
    };
  }
}

class TrackingLocal {
  final int? packageTrackingId;
  final String? packageCode;
  final DateTime packageTrackingDate;
  final String packageTrackingAddress;
  final String packageTrackingNote;
  final int? packageTrackingStatus;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? createKind;

  TrackingLocal({
    this.packageTrackingId,
    this.packageCode,
    required this.packageTrackingDate,
    required this.packageTrackingAddress,
    required this.packageTrackingNote,
    this.packageTrackingStatus,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.createKind,
  });

  factory TrackingLocal.fromJson(Map<String, dynamic> json) {
    return TrackingLocal(
      packageTrackingId: json['package_tracking_id'],
      packageCode: json['package_code'],
      packageTrackingDate: DateTime.parse(json['package_tracking_date']),
      packageTrackingAddress: json['package_tracking_address'],
      packageTrackingNote: json['package_tracking_note'],
      packageTrackingStatus: json['package_tracking_status'],
      activeFlg: json['active_flg'],
      deleteFlg: json['delete_flg'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createKind: json['create_kind'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_tracking_id': packageTrackingId,
      'package_code': packageCode,
      'package_tracking_date': packageTrackingDate.toIso8601String(),
      'package_tracking_address': packageTrackingAddress,
      'package_tracking_note': packageTrackingNote,
      'package_tracking_status': packageTrackingStatus,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'create_kind': createKind,
    };
  }

  // Helper method to format tracking date
  String getFormattedTrackingDate() {
    return "${packageTrackingDate.year}-${packageTrackingDate.month.toString().padLeft(2, '0')}-${packageTrackingDate.day.toString().padLeft(2, '0')} ${packageTrackingDate.hour.toString().padLeft(2, '0')}:${packageTrackingDate.minute.toString().padLeft(2, '0')}";
  }
}

class RightLocation {
  final TrackingHeader? labelCreated;
  final TrackingHeader? weHaveYourParcel;
  final TrackingHeader? inTransit;
  final TrackingHeader? ortherLocal;
  final TrackingHeader? checkDelivered;

  RightLocation({
    this.labelCreated,
    this.weHaveYourParcel,
    this.inTransit,
    this.ortherLocal,
    this.checkDelivered,
  });

  factory RightLocation.fromJson(Map<String, dynamic> json) {
    return RightLocation(
      labelCreated: json['label_created'] != null
          ? TrackingHeader.fromJson(json['label_created'])
          : null,
      weHaveYourParcel: json['we_have_your_parcel'] != null
          ? TrackingHeader.fromJson(json['we_have_your_parcel'])
          : null,
      inTransit: json['in_transit'] != null
          ? TrackingHeader.fromJson(json['in_transit'])
          : null,
      ortherLocal: json['orther_local'] != null
          ? TrackingHeader.fromJson(json['orther_local'])
          : null,
      checkDelivered: json['check_delivered'] != null
          ? TrackingHeader.fromJson(json['check_delivered'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label_created': labelCreated?.toJson(),
      'we_have_your_parcel': weHaveYourParcel?.toJson(),
      'in_transit': inTransit?.toJson(),
      'orther_local': ortherLocal?.toJson(),
      'check_delivered': checkDelivered?.toJson(),
    };
  }
}

class Service {
  final int serviceId;
  final String serviceName;
  final String serviceKind;
  final dynamic serviceVolumetricMass;
  final int serviceApplicableWeight;
  final int activeFlg;
  final int deleteFlg;
  final String createdAt;
  final String updatedAt;
  final int promotionFlg;
  final String? serviceCode;
  final String? serviceNote;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceKind,
    required this.serviceVolumetricMass,
    required this.serviceApplicableWeight,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.promotionFlg,
    this.serviceCode,
    this.serviceNote,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'],
      serviceName: json['service_name'],
      serviceKind: json['service_kind'],
      serviceVolumetricMass: json["service_volumetric_mass"] is String
          ? int.tryParse(json["service_volumetric_mass"])
          : json["service_volumetric_mass"],
      serviceApplicableWeight: json['service_applicable_weight'],
      activeFlg: json['active_flg'],
      deleteFlg: json['delete_flg'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      promotionFlg: json['promotion_flg'],
      serviceCode: json['service_code'],
      serviceNote: json['service_note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'service_kind': serviceKind,
      'service_volumetric_mass': serviceVolumetricMass,
      'service_applicable_weight': serviceApplicableWeight,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'promotion_flg': promotionFlg,
      'service_code': serviceCode,
      'service_note': serviceNote,
    };
  }
}

class ShipmentDetailsTracking {
  int shipmentId;
  dynamic shipmentCode;
  int shipmentServiceId;
  int shipmentSignatureFlg;
  int shipmentBranchId;
  dynamic shipmentReferenceCode;
  int shipmentStatus;
  dynamic shipmentGoodsName;
  dynamic shipmentValue;
  dynamic shipmentExportAs;
  dynamic shipmentAmountTransport;
  dynamic shipmentAmountTotalCustomer;
  dynamic shipmentAmountSurcharge;
  dynamic shipmentAmountInsurance;
  dynamic shipmentAmountVat;
  dynamic shipmentDomesticCharges;
  dynamic shipmentCollectionFee;
  dynamic shipmentPaidBy;
  dynamic shipmentAmountOriginal;
  dynamic shipmentAmountInsuranceValue;
  dynamic shipmentAmountProfit;
  dynamic shipmentAmountOperatingCosts;
  dynamic shipmentAmountDiscount;
  dynamic shipmentFileLabel;
  dynamic shipmentFileProofOfPayment;
  dynamic shipmentPaymentMethod;
  dynamic shipmentIosscode;
  dynamic shipmentPaymentStatus;
  dynamic shipmentAmountService;
  dynamic shipmentDebitId;
  dynamic shipmentFinalAmount;
  int userId;
  dynamic receiverId;
  dynamic senderCompanyName;
  dynamic senderContactName;
  dynamic senderTelephone;
  dynamic senderCity;
  dynamic senderDistrict;
  dynamic senderWard;
  dynamic senderAddress;
  dynamic serderLatitude;
  dynamic senderLongitude;
  dynamic receiverCompanyName;
  dynamic receiverContactName;
  dynamic receiverTelephone;
  dynamic receiverCountryId;
  dynamic receiverStateId;
  dynamic receiverCityId;
  dynamic receiverPostalCode;
  dynamic receiverAddress1;
  dynamic receiverAddress2;
  dynamic receiverAddress3;
  int saveReceiverFlg;
  dynamic shipmentCloseBill;
  dynamic shipmentHawbCode;
  dynamic receiverSmsName;
  dynamic receiverSmsPhone;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic shipmentCheckCreateLabel;
  dynamic orderPickupId;
  dynamic fwdId;
  dynamic accountantStatus;
  dynamic accountantCancelNote;
  dynamic documentId;
  dynamic oldData;
  ReceiverCountry receiverCountry;
  ServiceDetailsTracking service;
  List<PackageDetailsTracking> packages;

  ShipmentDetailsTracking({
    required this.shipmentId,
    required this.shipmentCode,
    required this.shipmentServiceId,
    required this.shipmentSignatureFlg,
    required this.shipmentBranchId,
    required this.shipmentReferenceCode,
    required this.shipmentStatus,
    required this.shipmentGoodsName,
    required this.shipmentValue,
    required this.shipmentExportAs,
    required this.shipmentAmountTransport,
    required this.shipmentAmountTotalCustomer,
    required this.shipmentAmountSurcharge,
    required this.shipmentAmountInsurance,
    required this.shipmentAmountVat,
    required this.shipmentDomesticCharges,
    required this.shipmentCollectionFee,
    required this.shipmentPaidBy,
    required this.shipmentAmountOriginal,
    required this.shipmentAmountInsuranceValue,
    required this.shipmentAmountProfit,
    required this.shipmentAmountOperatingCosts,
    required this.shipmentAmountDiscount,
    required this.shipmentFileLabel,
    required this.shipmentFileProofOfPayment,
    required this.shipmentPaymentMethod,
    required this.shipmentIosscode,
    required this.shipmentPaymentStatus,
    required this.shipmentAmountService,
    required this.shipmentDebitId,
    required this.shipmentFinalAmount,
    required this.userId,
    required this.receiverId,
    required this.senderCompanyName,
    required this.senderContactName,
    required this.senderTelephone,
    required this.senderCity,
    required this.senderDistrict,
    required this.senderWard,
    required this.senderAddress,
    required this.serderLatitude,
    required this.senderLongitude,
    required this.receiverCompanyName,
    required this.receiverContactName,
    required this.receiverTelephone,
    required this.receiverCountryId,
    required this.receiverStateId,
    required this.receiverCityId,
    required this.receiverPostalCode,
    required this.receiverAddress1,
    required this.receiverAddress2,
    required this.receiverAddress3,
    required this.saveReceiverFlg,
    required this.shipmentCloseBill,
    required this.shipmentHawbCode,
    required this.receiverSmsName,
    required this.receiverSmsPhone,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.shipmentCheckCreateLabel,
    required this.orderPickupId,
    required this.fwdId,
    required this.accountantStatus,
    required this.accountantCancelNote,
    required this.documentId,
    required this.oldData,
    required this.receiverCountry,
    required this.service,
    required this.packages,
  });

  factory ShipmentDetailsTracking.fromJson(Map<String, dynamic> json) =>
      ShipmentDetailsTracking(
        shipmentId: json["shipment_id"],
        shipmentCode: json["shipment_code"],
        shipmentServiceId: json["shipment_service_id"],
        shipmentSignatureFlg: json["shipment_signature_flg"],
        shipmentBranchId: json["shipment_branch_id"],
        shipmentReferenceCode: json["shipment_reference_code"],
        shipmentStatus: json["shipment_status"],
        shipmentGoodsName: json["shipment_goods_name"],
        shipmentValue: json["shipment_value"],
        shipmentExportAs: json["shipment_export_as"],
        shipmentAmountTransport: json["shipment_amount_transport"],
        shipmentAmountTotalCustomer: json["shipment_amount_total_customer"],
        shipmentAmountSurcharge: json["shipment_amount_surcharge"],
        shipmentAmountInsurance: json["shipment_amount_insurance"],
        shipmentAmountVat: json["shipment_amount_vat"],
        shipmentDomesticCharges: json["shipment_domestic_charges"],
        shipmentCollectionFee: json["shipment_collection_fee"],
        shipmentPaidBy: json["shipment_paid_by"],
        shipmentAmountOriginal: json["shipment_amount_original"],
        shipmentAmountInsuranceValue: json["shipment_amount_insurance_value"],
        shipmentAmountProfit: json["shipment_amount_profit"],
        shipmentAmountOperatingCosts: json["shipment_amount_operating_costs"],
        shipmentAmountDiscount: json["shipment_amount_discount"],
        shipmentFileLabel: json["shipment_file_label"],
        shipmentFileProofOfPayment: json["shipment_file_proof_of_payment"],
        shipmentPaymentMethod: json["shipment_payment_method"],
        shipmentIosscode: json["shipment_iosscode"],
        shipmentPaymentStatus: json["shipment_payment_status"],
        shipmentAmountService: json["shipment_amount_service"],
        shipmentDebitId: json["shipment_debit_id"],
        shipmentFinalAmount: json["shipment_final_amount"],
        userId: json["user_id"],
        receiverId: json["receiver_id"],
        senderCompanyName: json["sender_company_name"],
        senderContactName: json["sender_contact_name"],
        senderTelephone: json["sender_telephone"],
        senderCity: json["sender_city"],
        senderDistrict: json["sender_district"],
        senderWard: json["sender_ward"],
        senderAddress: json["sender_address"],
        serderLatitude: json["serder_latitude"],
        senderLongitude: json["sender_longitude"],
        receiverCompanyName: json["receiver_company_name"],
        receiverContactName: json["receiver_contact_name"],
        receiverTelephone: json["receiver_telephone"],
        receiverCountryId: json["receiver_country_id"],
        receiverStateId: json["receiver_state_id"],
        receiverCityId: json["receiver_city_id"],
        receiverPostalCode: json["receiver_postal_code"],
        receiverAddress1: json["receiver_address_1"],
        receiverAddress2: json["receiver_address_2"],
        receiverAddress3: json["receiver_address_3"],
        saveReceiverFlg: json["save_receiver_flg"],
        shipmentCloseBill: json["shipment_close_bill"],
        shipmentHawbCode: json["shipment_hawb_code"],
        receiverSmsName: json["receiver_sms_name"],
        receiverSmsPhone: json["receiver_sms_phone"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        shipmentCheckCreateLabel: json["shipment_check_create_label"],
        orderPickupId: json["order_pickup_id"],
        fwdId: json["fwd_id"],
        accountantStatus: json["accountant_status"],
        accountantCancelNote: json["accountant_cancel_note"],
        documentId: json["document_id"],
        oldData: json["old_data"],
        receiverCountry: ReceiverCountry.fromJson(json["receiver_country"]),
        service: ServiceDetailsTracking.fromJson(json["service"]),
        packages: List<PackageDetailsTracking>.from(
            json["packages"].map((x) => PackageDetailsTracking.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "shipment_id": shipmentId,
        "shipment_code": shipmentCode,
        "shipment_service_id": shipmentServiceId,
        "shipment_signature_flg": shipmentSignatureFlg,
        "shipment_branch_id": shipmentBranchId,
        "shipment_reference_code": shipmentReferenceCode,
        "shipment_status": shipmentStatus,
        "shipment_goods_name": shipmentGoodsName,
        "shipment_value": shipmentValue,
        "shipment_export_as": shipmentExportAs,
        "shipment_amount_transport": shipmentAmountTransport,
        "shipment_amount_total_customer": shipmentAmountTotalCustomer,
        "shipment_amount_surcharge": shipmentAmountSurcharge,
        "shipment_amount_insurance": shipmentAmountInsurance,
        "shipment_amount_vat": shipmentAmountVat,
        "shipment_domestic_charges": shipmentDomesticCharges,
        "shipment_collection_fee": shipmentCollectionFee,
        "shipment_paid_by": shipmentPaidBy,
        "shipment_amount_original": shipmentAmountOriginal,
        "shipment_amount_insurance_value": shipmentAmountInsuranceValue,
        "shipment_amount_profit": shipmentAmountProfit,
        "shipment_amount_operating_costs": shipmentAmountOperatingCosts,
        "shipment_amount_discount": shipmentAmountDiscount,
        "shipment_file_label": shipmentFileLabel,
        "shipment_file_proof_of_payment": shipmentFileProofOfPayment,
        "shipment_payment_method": shipmentPaymentMethod,
        "shipment_iosscode": shipmentIosscode,
        "shipment_payment_status": shipmentPaymentStatus,
        "shipment_amount_service": shipmentAmountService,
        "shipment_debit_id": shipmentDebitId,
        "shipment_final_amount": shipmentFinalAmount,
        "user_id": userId,
        "receiver_id": receiverId,
        "sender_company_name": senderCompanyName,
        "sender_contact_name": senderContactName,
        "sender_telephone": senderTelephone,
        "sender_city": senderCity,
        "sender_district": senderDistrict,
        "sender_ward": senderWard,
        "sender_address": senderAddress,
        "serder_latitude": serderLatitude,
        "sender_longitude": senderLongitude,
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
        "save_receiver_flg": saveReceiverFlg,
        "shipment_close_bill": shipmentCloseBill,
        "shipment_hawb_code": shipmentHawbCode,
        "receiver_sms_name": receiverSmsName,
        "receiver_sms_phone": receiverSmsPhone,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "shipment_check_create_label": shipmentCheckCreateLabel,
        "order_pickup_id": orderPickupId,
        "fwd_id": fwdId,
        "accountant_status": accountantStatus,
        "accountant_cancel_note": accountantCancelNote,
        "document_id": documentId,
        "old_data": oldData,
        "receiver_country": receiverCountry.toJson(),
        "service": service.toJson(),
        "packages": List<dynamic>.from(packages.map((x) => x.toJson())),
      };
}

class ReceiverCountry {
  int countryId;
  String? countryName;
  String? countryCode;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  ReceiverCountry({
    required this.countryId,
    required this.countryName,
    required this.countryCode,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReceiverCountry.fromJson(Map<String, dynamic> json) =>
      ReceiverCountry(
        countryId: json["country_id"],
        countryName: json["country_name"],
        countryCode: json["country_code"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "country_id": countryId,
        "country_name": countryName,
        "country_code": countryCode,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class ServiceDetailsTracking {
  int serviceId;
  String? serviceName;
  String? serviceKind;
  String? serviceCode;
  String? serviceNote;
  dynamic serviceVolumetricMass;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  int promotionFlg;

  ServiceDetailsTracking({
    required this.serviceId,
    required this.serviceName,
    required this.serviceKind,
    required this.serviceVolumetricMass,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.promotionFlg,
    required this.serviceCode,
    required this.serviceNote,
  });

  factory ServiceDetailsTracking.fromJson(Map<String, dynamic> json) =>
      ServiceDetailsTracking(
        serviceId: json["service_id"],
        serviceName: json["service_name"],
        serviceKind: json["service_kind"],
        serviceVolumetricMass: json["service_volumetric_mass"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        promotionFlg: json["promotion_flg"],
        serviceCode: json["service_code"],
        serviceNote: json["service_note"],
      );

  Map<String, dynamic> toJson() => {
        "service_id": serviceId,
        "service_name": serviceName,
        "service_kind": serviceKind,
        "service_volumetric_mass": serviceVolumetricMass,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "promotion_flg": promotionFlg,
        "service_code": serviceCode,
        "service_note": serviceNote,
      };
}

class Tracking {
  final bool status;
  final String message;
  final List<TrackingInfo> tracktry;
  final List<Checkpoint> checkpoints;

  Tracking({
    this.status = false, // giá trị mặc định
    this.message = '', // giá trị mặc định
    this.tracktry = const [], // giá trị mặc định là list rỗng
    this.checkpoints = const [], // giá trị mặc định là list rỗng
  });

  factory Tracking.fromJson(Map<String, dynamic> json) {
    // Kiểm tra null và ép kiểu an toàn
    return Tracking(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      tracktry: (json['tracktry'] is List)
          ? List<TrackingInfo>.from(
              (json['tracktry'] as List).map((x) => TrackingInfo.fromJson(x)))
          : [],
      checkpoints: (json['checkpoints'] is List)
          ? List<Checkpoint>.from(
              (json['checkpoints'] as List).map((x) => Checkpoint.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'tracktry': tracktry.map((x) => x.toJson()).toList(),
      'checkpoints': checkpoints.map((x) => x.toJson()).toList(),
    };
  }
}

class TrackingInfo {
  final String? id;
  final String? trackingNumber;
  final String? carrierCode;
  final String? status;
  final String? createdAt;
  final String? updatedAt;
  final String? orderCreateTime;
  final String? customerEmail;
  final String? title;
  final String? orderId;
  final String? comment;
  final String? customerName;
  final bool? archived;
  final String? originalCountry;
  final int? itemTimeLength;
  final int? stayTimeLength;
  final String? serviceCode;
  final dynamic statusInfo;
  final OriginInfo? originInfo;
  final DestinationInfo? destinationInfo;
  final String? lastEvent;
  final String? lastUpdateTime;

  TrackingInfo({
    this.id,
    this.trackingNumber,
    this.carrierCode,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.orderCreateTime,
    this.customerEmail,
    this.title,
    this.orderId,
    this.comment,
    this.customerName,
    this.archived,
    this.originalCountry,
    this.itemTimeLength,
    this.stayTimeLength,
    this.serviceCode,
    this.statusInfo,
    this.originInfo,
    this.destinationInfo,
    this.lastEvent,
    this.lastUpdateTime,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    return TrackingInfo(
      id: json['id'],
      trackingNumber: json['tracking_number'],
      carrierCode: json['carrier_code'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      orderCreateTime: json['order_create_time'],
      customerEmail: json['customer_email'],
      title: json['title'],
      orderId: json['order_id'],
      comment: json['comment'],
      customerName: json['customer_name'],
      archived: json['archived'],
      originalCountry: json['original_country'],
      itemTimeLength: json['itemTimeLength'],
      stayTimeLength: json['stayTimeLength'],
      serviceCode: json['service_code'],
      statusInfo: json['status_info'],
      originInfo: json['origin_info'] != null
          ? OriginInfo.fromJson(json['origin_info'])
          : null,
      destinationInfo: json['destination_info'] != null
          ? DestinationInfo.fromJson(json['destination_info'])
          : null,
      lastEvent: json['lastEvent'],
      lastUpdateTime: json['lastUpdateTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'carrier_code': carrierCode,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'order_create_time': orderCreateTime,
      'customer_email': customerEmail,
      'title': title,
      'order_id': orderId,
      'comment': comment,
      'customer_name': customerName,
      'archived': archived,
      'original_country': originalCountry,
      'itemTimeLength': itemTimeLength,
      'stayTimeLength': stayTimeLength,
      'service_code': serviceCode,
      'status_info': statusInfo,
      'origin_info': originInfo?.toJson(),
      'destination_info': destinationInfo?.toJson(),
      'lastEvent': lastEvent,
      'lastUpdateTime': lastUpdateTime,
    };
  }
}

class OriginInfo {
  final String? referenceNumber;
  final String? itemReceived;
  final String? itemDispatched;
  final String? departfromAirport;
  final String? arrivalfromAbroad;
  final String? customsClearance;
  final String? destinationArrived;
  final String? weblink;
  final String? phone;
  final String? carrierCode;
  final List<Checkpoint>? trackinfo;

  OriginInfo({
    this.referenceNumber,
    this.itemReceived,
    this.itemDispatched,
    this.departfromAirport,
    this.arrivalfromAbroad,
    this.customsClearance,
    this.destinationArrived,
    this.weblink,
    this.phone,
    this.carrierCode,
    this.trackinfo,
  });

  factory OriginInfo.fromJson(Map<String, dynamic> json) {
    return OriginInfo(
      referenceNumber: json['ReferenceNumber'],
      itemReceived: json['ItemReceived'],
      itemDispatched: json['ItemDispatched'],
      departfromAirport: json['DepartfromAirport'],
      arrivalfromAbroad: json['ArrivalfromAbroad'],
      customsClearance: json['CustomsClearance'],
      destinationArrived: json['DestinationArrived'],
      weblink: json['weblink'],
      phone: json['phone'],
      carrierCode: json['carrier_code'],
      trackinfo: (json['trackinfo'] as List?)
          ?.map((e) => Checkpoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ReferenceNumber': referenceNumber,
      'ItemReceived': itemReceived,
      'ItemDispatched': itemDispatched,
      'DepartfromAirport': departfromAirport,
      'ArrivalfromAbroad': arrivalfromAbroad,
      'CustomsClearance': customsClearance,
      'DestinationArrived': destinationArrived,
      'weblink': weblink,
      'phone': phone,
      'carrier_code': carrierCode,
      'trackinfo': trackinfo?.map((e) => e.toJson()).toList(),
    };
  }
}

class DestinationInfo {
  final String? itemReceived;
  final String? itemDispatched;
  final String? departfromAirport;
  final String? arrivalfromAbroad;
  final String? customsClearance;
  final String? destinationArrived;
  final String? weblink;
  final String? phone;
  final String? carrierCode;
  final List<TrackingInfo>? trackinfo;

  DestinationInfo({
    this.itemReceived,
    this.itemDispatched,
    this.departfromAirport,
    this.arrivalfromAbroad,
    this.customsClearance,
    this.destinationArrived,
    this.weblink,
    this.phone,
    this.carrierCode,
    this.trackinfo,
  });

  factory DestinationInfo.fromJson(Map<String, dynamic> json) {
    return DestinationInfo(
      itemReceived: json['ItemReceived'],
      itemDispatched: json['ItemDispatched'],
      departfromAirport: json['DepartfromAirport'],
      arrivalfromAbroad: json['ArrivalfromAbroad'],
      customsClearance: json['CustomsClearance'],
      destinationArrived: json['DestinationArrived'],
      weblink: json['weblink'],
      phone: json['phone'],
      carrierCode: json['carrier_code'],
      trackinfo: (json['trackinfo'] as List?)
          ?.map((e) => TrackingInfo.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemReceived': itemReceived,
      'ItemDispatched': itemDispatched,
      'DepartfromAirport': departfromAirport,
      'ArrivalfromAbroad': arrivalfromAbroad,
      'CustomsClearance': customsClearance,
      'DestinationArrived': destinationArrived,
      'weblink': weblink,
      'phone': phone,
      'carrier_code': carrierCode,
      'trackinfo': trackinfo?.map((e) => e.toJson()).toList(),
    };
  }
}

class Checkpoint {
  final String? statusDescription;
  final String? date;
  final String? details;
  final String? checkpointStatus;
  final String? substatus;

  Checkpoint({
    this.statusDescription,
    this.date,
    this.details,
    this.checkpointStatus,
    this.substatus,
  });

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    return Checkpoint(
      statusDescription: json['StatusDescription'],
      date: json['Date'],
      details: json['Details'],
      checkpointStatus: json['checkpoint_status'],
      substatus: json['substatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StatusDescription': statusDescription,
      'Date': date,
      'Details': details,
      'checkpoint_status': checkpointStatus,
      'substatus': substatus,
    };
  }
}

class Coordinate {
  dynamic latitude;
  dynamic longitude;

  Coordinate({
    this.latitude,
    this.longitude,
  });

  factory Coordinate.fromJson(Map<String, dynamic> json) => Coordinate(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
      };
}
