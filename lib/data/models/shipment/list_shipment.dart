// To parse this JSON data, do
//
//     final listShipmentModel = listShipmentModelFromJson(jsonString);

import 'dart:convert';

ListShipmentModel listShipmentModelFromJson(String str) =>
    ListShipmentModel.fromJson(json.decode(str));

String listShipmentModelToJson(ListShipmentModel data) =>
    json.encode(data.toJson());

class ListShipmentModel {
  int status;
  Shipments shipments;

  ListShipmentModel({
    required this.status,
    required this.shipments,
  });

  factory ListShipmentModel.fromJson(Map<String, dynamic> json) =>
      ListShipmentModel(
        status: json["status"] ?? 0,
        shipments: json["shipments"] != null
            ? Shipments.fromJson(json["shipments"])
            : Shipments(currentPage: 0, data: []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "shipments": shipments.toJson(),
      };
}

class Shipments {
  int currentPage;
  List<ShipmentItemData> data;

  Shipments({
    required this.currentPage,
    required this.data,
  });

  factory Shipments.fromJson(Map<String, dynamic> json) => Shipments(
        currentPage: json["current_page"],
        data: List<ShipmentItemData>.from(
            json["data"].map((x) => ShipmentItemData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "current_page": currentPage,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ShipmentItemData {
  int shipmentId;
  String shipmentCode;
  dynamic shipmentServiceId;
  dynamic shipmentSignatureFlg;
  dynamic shipmentBranchId;
  dynamic shipmentReferenceCode;
  dynamic shipmentStatus;
  String? shipmentGoodsName;
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
  dynamic shipmentFileLabel;
  dynamic shipmentFileProofOfPayment;
  dynamic shipmentPaymentMethod;
  dynamic shipmentIosscode;
  dynamic shipmentPaymentStatus;
  dynamic shipmentAmountService;
  dynamic shipmentDebitId;
  dynamic shipmentFinalAmount;
  dynamic userId;
  dynamic receiverId;
  String? senderCompanyName;
  String? senderContactName;
  String? senderTelephone;
  dynamic senderCity;
  dynamic senderDistrict;
  dynamic senderWard;
  String? senderAddress;
  String? serderLatitude;
  String? senderLongitude;
  String? receiverCompanyName;
  String? receiverContactName;
  String? receiverTelephone;
  dynamic receiverCountryId;
  dynamic receiverStateId;
  dynamic receiverCityId;
  String? receiverPostalCode;
  String? receiverAddress1;
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
  int shipmentCheckCreateLabel;
  dynamic orderPickupId;
  dynamic fwdId;
  int accountantStatus;
  dynamic accountantCancelNote;
  dynamic documentId;
  Service service;
  Branch branch;
  Country country;
  List<Package> packageOfShipmentItemData;
  User user;

  ShipmentItemData({
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
    required this.service,
    required this.branch,
    required this.country,
    required this.packageOfShipmentItemData,
    required this.user,
  });

  factory ShipmentItemData.fromJson(Map<String, dynamic> json) =>
      ShipmentItemData(
        shipmentId: json["shipment_id"] ?? 0,
        shipmentCode: json["shipment_code"] ?? "",
        shipmentServiceId: json["shipment_service_id"] ?? 0,
        shipmentSignatureFlg: json["shipment_signature_flg"] ?? 0,
        shipmentBranchId: json["shipment_branch_id"] ?? 0,
        shipmentReferenceCode: json["shipment_reference_code"] ?? "",
        shipmentStatus: json["shipment_status"] ?? 0,
        shipmentGoodsName: json["shipment_goods_name"] ?? "",
        shipmentValue: json["shipment_value"] ?? 0,
        shipmentExportAs: json["shipment_export_as"] ?? 0,
        shipmentAmountTransport: json["shipment_amount_transport"] ?? 0,
        shipmentAmountTotalCustomer:
            json["shipment_amount_total_customer"] ?? 0,
        shipmentAmountSurcharge: json["shipment_amount_surcharge"] ?? 0,
        shipmentAmountInsurance: json["shipment_amount_insurance"] ?? 0,
        shipmentAmountVat: json["shipment_amount_vat"] ?? 0,
        shipmentDomesticCharges: json["shipment_domestic_charges"] ?? 0,
        shipmentCollectionFee: json["shipment_collection_fee"] ?? 0,
        shipmentPaidBy: json["shipment_paid_by"] ?? 0,
        shipmentAmountOriginal: json["shipment_amount_original"] ?? 0,
        shipmentAmountInsuranceValue:
            json["shipment_amount_insurance_value"] ?? 0,
        shipmentAmountProfit: json["shipment_amount_profit"] ?? 0,
        shipmentAmountOperatingCosts:
            json["shipment_amount_operating_costs"] ?? 0,
        shipmentFileLabel: json["shipment_file_label"] ?? "",
        shipmentFileProofOfPayment:
            json["shipment_file_proof_of_payment"] ?? "",
        shipmentPaymentMethod: json["shipment_payment_method"] ?? 0,
        shipmentIosscode: json["shipment_iosscode"] ?? "",
        shipmentPaymentStatus: json["shipment_payment_status"] ?? 0,
        shipmentAmountService: json["shipment_amount_service"] ?? 0,
        shipmentDebitId: json["shipment_debit_id"] ?? 0,
        shipmentFinalAmount: json["shipment_final_amount"] ?? 0,
        userId: json["user_id"] ?? 0,
        receiverId: json["receiver_id"] ?? 0,
        senderCompanyName: json["sender_company_name"] ?? "",
        senderContactName: json["sender_contact_name"] ?? "",
        senderTelephone: json["sender_telephone"] ?? "",
        senderCity: json["sender_city"] ?? "",
        senderDistrict: json["sender_district"] ?? "",
        senderWard: json["sender_ward"] ?? "",
        senderAddress: json["sender_address"] ?? "",
        serderLatitude: json["serder_latitude"] ?? "",
        senderLongitude: json["sender_longitude"] ?? "",
        receiverCompanyName: json["receiver_company_name"] ?? "",
        receiverContactName: json["receiver_contact_name"] ?? "",
        receiverTelephone: json["receiver_telephone"] ?? "",
        receiverCountryId: json["receiver_country_id"] ?? 0,
        receiverStateId: json["receiver_state_id"] ?? 0,
        receiverCityId: json["receiver_city_id"] ?? 0,
        receiverPostalCode: json["receiver_postal_code"] ?? "",
        receiverAddress1: json["receiver_address_1"] ?? "",
        receiverAddress2: json["receiver_address_2"] ?? "",
        receiverAddress3: json["receiver_address_3"] ?? "",
        saveReceiverFlg: json["save_receiver_flg"] ?? 0,
        shipmentCloseBill: json["shipment_close_bill"] ?? 0,
        shipmentHawbCode: json["shipment_hawb_code"] ?? "",
        receiverSmsName: json["receiver_sms_name"] ?? "",
        receiverSmsPhone: json["receiver_sms_phone"] ?? "",
        activeFlg: json["active_flg"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
        shipmentCheckCreateLabel: json["shipment_check_create_label"] ?? 0,
        orderPickupId: json["order_pickup_id"] ?? 0,
        fwdId: json["fwd_id"] ?? 0,
        accountantStatus: json["accountant_status"] ?? 0,
        accountantCancelNote: json["accountant_cancel_note"] ?? "",
        documentId: json["document_id"] ?? 0,
        service: json["service"] != null
            ? Service.fromJson(json["service"])
            : Service(
                serviceId: 0,
                serviceName: "",
                serviceKind: "",
                serviceVolumetricMass: 0,
                activeFlg: 0,
                deleteFlg: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                promotionFlg: 0,
                serviceCode: "",
                serviceNote: "",
              ),
        branch: json["branch"] != null
            ? Branch.fromJson(json["branch"])
            : Branch(
                branchId: 0,
                branchName: "",
                branchDescription: "",
                branchLatitude: "",
                branchLongitude: "",
                activeFlg: 0,
                deleteFlg: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        country: json["country"] != null
            ? Country.fromJson(json["country"])
            : Country(
                countryId: 0,
                countryName: "",
                countryCode: "",
                activeFlg: 0,
                deleteFlg: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
        packageOfShipmentItemData: json["packages"] != null
            ? List<Package>.from(
                json["packages"].map((x) => Package.fromJson(x)))
            : [],
        user: json["user"] != null
            ? User.fromJson(json["user"])
            : User(
                userId: 0,
                userName: "",
                userCode: "",
                userApiKey: "",
                positionId: 0,
                branchId: 0,
                userContactName: "",
                userPhone: "",
                userAddress: "",
                userLatitude: "",
                userLongitude: "",
                userSignature: "",
                userLimitAmountForSale: 0,
                activeFlg: 0,
                userPendingApproval: 0,
                deleteFlg: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                userAccountantKey: "",
                userCompanyName: "",
                userTaxCode: "",
                userAddress1: "",
                userAddress2: "",
                userAddress3: "",
                userLogo: "",
                userDebitType: 0,
                userPriceListMainType: 0,
                userPriceListChangeType: 0,
                userPriceListChangeDate: "",
                userRemainingLimit: 0,
                userKpiId: 0,
                userIsFreeTime: 0,
              ),
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
        "service": service.toJson(),
        "branch": branch.toJson(),
        "country": country.toJson(),
        "packages": List<dynamic>.from(
            packageOfShipmentItemData.map((x) => x.toJson())),
        "user": user.toJson(),
      };
}

class Branch {
  int branchId;
  String? branchName;
  String? branchDescription;
  String? branchLatitude;
  String? branchLongitude;
  int? activeFlg; // Changed from dynamic to int?
  int? deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  Branch({
    required this.branchId,
    required this.branchName,
    required this.branchDescription,
    required this.branchLatitude,
    required this.branchLongitude,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        branchId: json["branch_id"] ?? 0,
        branchName: json["branch_name"] ?? "",
        branchDescription: json["branch_description"] ?? "",
        branchLatitude: json["branch_latitude"] ?? "",
        branchLongitude: json["branch_longitude"] ?? "",
        activeFlg: json["active_flg"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
        "branch_description": branchDescription,
        "branch_latitude": branchLatitude,
        "branch_longitude": branchLongitude,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class Country {
  int countryId;
  String? countryName;
  String? countryCode;
  dynamic activeFlg;
  dynamic deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  Country({
    required this.countryId,
    required this.countryName,
    required this.countryCode,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
        countryId: json["country_id"] ?? 0,
        countryName: json["country_name"] ?? "",
        countryCode: json["country_code"] ?? "",
        activeFlg: json["active_flg"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
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

class Package {
  int packageId;
  int shipmentId;
  String packageCode;
  int packageQuantity;
  int packageType;
  String? packageDescription;
  dynamic packageLength;
  dynamic packageWidth;
  dynamic packageHeight;
  dynamic packageWeight;
  String? packageHawbCode;
  dynamic packageConvertedWeight;
  dynamic packageChargedWeight;
  dynamic packageTrackingCode;
  dynamic carrierCode;
  dynamic packageImage;
  dynamic bagCode;
  dynamic smTracktryId;
  dynamic branchConnect;
  String? packageStatus;
  dynamic activeFlg;
  dynamic deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  Package({
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

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        packageId: json["package_id"] ?? 0,
        shipmentId: json["shipment_id"] ?? 0,
        packageCode: json["package_code"] ?? "",
        packageQuantity: json["package_quantity"] ?? 0,
        packageType: json["package_type"] ?? 0,
        packageDescription: json["package_description"] ?? "",
        packageLength: json["package_length"] ?? 0,
        packageWidth: json["package_width"] ?? 0,
        packageHeight: json["package_height"] ?? 0,
        packageWeight: json["package_weight"] ?? 0,
        packageHawbCode: json["package_hawb_code"] ?? "",
        packageConvertedWeight: json["package_converted_weight"] ?? 0,
        packageChargedWeight: json["package_charged_weight"] ?? 0,
        packageTrackingCode: json["package_tracking_code"] ?? "",
        carrierCode: json["carrier_code"] ?? "",
        packageImage: json["package_image"] ?? "",
        bagCode: json["bag_code"] ?? "",
        smTracktryId: json["sm_tracktry_id"] ?? 0,
        branchConnect: json["branch_connect"] ?? "",
        packageStatus: json["package_status"] ?? "",
        activeFlg: json["active_flg"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
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

class Service {
  int serviceId;
  String? serviceName;
  String? serviceKind;
  dynamic serviceVolumetricMass;
  dynamic activeFlg;
  dynamic deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic promotionFlg;
  dynamic serviceCode;
  dynamic serviceNote;

  Service({
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

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        serviceId: json["service_id"] ?? 0,
        serviceName: json["service_name"] ?? "",
        serviceKind: json["service_kind"] ?? "",
        serviceVolumetricMass: json["service_volumetric_mass"] ?? 0,
        activeFlg: json["active_flg"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
        promotionFlg: json["promotion_flg"] ?? 0,
        serviceCode: json["service_code"] ?? "",
        serviceNote: json["service_note"] ?? "",
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

class User {
  int userId;
  String? userName;
  String? userCode;
  String? userApiKey;
  int positionId;
  int branchId;
  String? userContactName;
  String? userPhone;
  String? userAddress;
  dynamic userLatitude;
  dynamic userLongitude;
  dynamic userSignature;
  dynamic userLimitAmountForSale;
  dynamic activeFlg;
  dynamic userPendingApproval;
  dynamic deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String? userAccountantKey;
  String? userCompanyName;
  dynamic userTaxCode;
  dynamic userAddress1;
  dynamic userAddress2;
  dynamic userAddress3;
  dynamic userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userPriceListChangeDate;
  dynamic userRemainingLimit;
  dynamic userKpiId;
  dynamic userIsFreeTime;

  User({
    required this.userId,
    required this.userName,
    required this.userCode,
    required this.userApiKey,
    required this.positionId,
    required this.branchId,
    required this.userContactName,
    required this.userPhone,
    required this.userAddress,
    required this.userLatitude,
    required this.userLongitude,
    required this.userSignature,
    required this.userLimitAmountForSale,
    required this.activeFlg,
    required this.userPendingApproval,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.userAccountantKey,
    required this.userCompanyName,
    required this.userTaxCode,
    required this.userAddress1,
    required this.userAddress2,
    required this.userAddress3,
    required this.userLogo,
    required this.userDebitType,
    required this.userPriceListMainType,
    required this.userPriceListChangeType,
    required this.userPriceListChangeDate,
    required this.userRemainingLimit,
    required this.userKpiId,
    required this.userIsFreeTime,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"] ?? 0,
        userName: json["user_name"] ?? "",
        userCode: json["user_code"] ?? "",
        userApiKey: json["user_api_key"] ?? "",
        positionId: json["position_id"] ?? 0,
        branchId: json["branch_id"] ?? 0,
        userContactName: json["user_contact_name"] ?? "",
        userPhone: json["user_phone"] ?? "",
        userAddress: json["user_address"] ?? "",
        userLatitude: json["user_latitude"] ?? "",
        userLongitude: json["user_longitude"] ?? "",
        userSignature: json["user_signature"] ?? "",
        userLimitAmountForSale: json["user_limit_amount_for_sale"] ?? 0,
        activeFlg: json["active_flg"] ?? 0,
        userPendingApproval: json["user_pending_approval"] ?? 0,
        deleteFlg: json["delete_flg"] ?? 0,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : DateTime.now(),
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : DateTime.now(),
        userAccountantKey: json["user_accountant_key"] ?? "",
        userCompanyName: json["user_company_name"] ?? "",
        userTaxCode: json["user_tax_code"] ?? "",
        userAddress1: json["user_address_1"] ?? "",
        userAddress2: json["user_address_2"] ?? "",
        userAddress3: json["user_address_3"] ?? "",
        userLogo: json["user_logo"] ?? "",
        userDebitType: json["user_debit_type"] ?? 0,
        userPriceListMainType: json["user_price_list_main_type"] ?? 0,
        userPriceListChangeType: json["user_price_list_change_type"] ?? 0,
        userPriceListChangeDate: json["user_price_list_change_date"] ?? "",
        userRemainingLimit: json["user_remaining_limit"] ?? 0,
        userKpiId: json["user_kpi_id"] ?? 0,
        userIsFreeTime: json["user_is_free_time"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_name": userName,
        "user_code": userCode,
        "user_api_key": userApiKey,
        "position_id": positionId,
        "branch_id": branchId,
        "user_contact_name": userContactName,
        "user_phone": userPhone,
        "user_address": userAddress,
        "user_latitude": userLatitude,
        "user_longitude": userLongitude,
        "user_signature": userSignature,
        "user_limit_amount_for_sale": userLimitAmountForSale,
        "active_flg": activeFlg,
        "user_pending_approval": userPendingApproval,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "user_accountant_key": userAccountantKey,
        "user_company_name": userCompanyName,
        "user_tax_code": userTaxCode,
        "user_address_1": userAddress1,
        "user_address_2": userAddress2,
        "user_address_3": userAddress3,
        "user_logo": userLogo,
        "user_debit_type": userDebitType,
        "user_price_list_main_type": userPriceListMainType,
        "user_price_list_change_type": userPriceListChangeType,
        "user_price_list_change_date": userPriceListChangeDate,
        "user_remaining_limit": userRemainingLimit,
        "user_kpi_id": userKpiId,
        "user_is_free_time": userIsFreeTime,
      };
}
