// To parse this JSON data, do
//
//     final detailsShipmentModel = detailsShipmentModelFromJson(jsonString);

import 'dart:convert';

DetailsShipmentModel detailsShipmentModelFromJson(String str) =>
    DetailsShipmentModel.fromJson(json.decode(str));

String detailsShipmentModelToJson(DetailsShipmentModel data) =>
    json.encode(data.toJson());

class DetailsShipmentModel {
  int status;
  Shipment shipment;
  bool isViewShipmentOperatingCosts;

  DetailsShipmentModel({
    required this.status,
    required this.shipment,
    required this.isViewShipmentOperatingCosts,
  });

  factory DetailsShipmentModel.fromJson(Map<String, dynamic> json) =>
      DetailsShipmentModel(
        status: json["status"],
        shipment: Shipment.fromJson(json["shipment"]),
        isViewShipmentOperatingCosts: json["is_view_shipment_operating_costs"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "shipment": shipment.toJson(),
        "is_view_shipment_operating_costs": isViewShipmentOperatingCosts,
      };
}

class Shipment {
  int shipmentId;
  String shipmentCode;
  int shipmentServiceId;
  int shipmentSignatureFlg;
  int shipmentBranchId;
  dynamic shipmentReferenceCode;
  int shipmentStatus;
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
  String shipmentNote;
  int shipmentPaidBy;
  dynamic shipmentAmountOriginal;
  dynamic shipmentAmountInsuranceValue;
  dynamic shipmentAmountProfit;
  dynamic shipmentAmountOperatingCosts;
  dynamic shipmentFileLabel;
  dynamic shipmentFileProofOfPayment;
  int shipmentPaymentMethod;
  dynamic shipmentIosscode;
  int shipmentPaymentStatus;
  int shipmentCheckedPaymentStatus;
  dynamic shipmentAmountService;
  String? shipmentDebitId;
  dynamic shipmentFinalAmount;
  int userId;
  int? receiverId;
  String? senderCompanyName;
  String? senderContactName;
  String? senderTelephone;
  dynamic senderCity;
  dynamic senderDistrict;
  dynamic senderWard;
  String? senderAddress;
  String? receiverCompanyName;
  String? receiverContactName;
  String? receiverTelephone;

  int receiverCountryId;
  dynamic receiverStateId;
  dynamic receiverStateName;
  dynamic receiverCityId;
  String? receiverPostalCode;
  String? receiverAddress1;
  String? receiverAddress2;
  String? receiverAddress3;
  int saveReceiverFlg;
  dynamic shipmentCloseBill;
  dynamic shipmentHawbCode;
  dynamic receiverSmsName;
  dynamic receiverSmsPhone;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  int? accountantStatus;
  int? shipmentCheckCreateLabel;
  User user;
  Service service;
  Branch branch;
  CountryShipmentDetails country;
  CityShipmentDetails? city;
  List<PackageShipmentDetails> packages;
  List<InvoiceShipmentDetails> invoices;
  List<ShipmentOperatingCost> shipmentOperatingCosts;

  Shipment({
    required this.shipmentId,
    required this.shipmentCode,
    required this.shipmentServiceId,
    required this.shipmentSignatureFlg,
    required this.shipmentBranchId,
    required this.shipmentReferenceCode,
    required this.shipmentStatus,
    required this.shipmentNote,
    required this.shipmentCheckedPaymentStatus,
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
    required this.receiverCompanyName,
    required this.receiverContactName,
    required this.receiverTelephone,
    required this.receiverCountryId,
    required this.receiverStateId,
    required this.receiverStateName,
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
    required this.accountantStatus,
    required this.shipmentCheckCreateLabel,
    required this.user,
    required this.service,
    required this.branch,
    required this.country,
    required this.city,
    required this.packages,
    required this.invoices,
    required this.shipmentOperatingCosts,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        shipmentId: json["shipment_id"],
        shipmentCode: json["shipment_code"],
        shipmentServiceId: json["shipment_service_id"],
        shipmentSignatureFlg: json["shipment_signature_flg"],
        shipmentBranchId: json["shipment_branch_id"],
        shipmentReferenceCode: json["shipment_reference_code"],
        shipmentNote: json["shipment_note"] ?? "",
        shipmentStatus: json["shipment_status"],
        shipmentCheckedPaymentStatus: json["checked_payment_status"],
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
        receiverCompanyName: json["receiver_company_name"],
        receiverContactName: json["receiver_contact_name"],
        receiverTelephone: json["receiver_telephone"],
        receiverCountryId: json["receiver_country_id"],
        receiverStateId: json["receiver_state_id"],
        receiverStateName: json["receiver_state_name"],
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
        accountantStatus: json["accountant_status"],
        shipmentCheckCreateLabel: json["shipment_check_create_label"],
        user: User.fromJson(json["user"]),
        service: Service.fromJson(json["service"]),
        branch: Branch.fromJson(json["branch"]),
        country: CountryShipmentDetails.fromJson(json["country"]),
        city: json["city"] != null
            ? CityShipmentDetails.fromJson(json["city"])
            : null,
        packages: List<PackageShipmentDetails>.from(
            json["packages"].map((x) => PackageShipmentDetails.fromJson(x))),
        invoices: List<InvoiceShipmentDetails>.from(
            json["invoices"].map((x) => InvoiceShipmentDetails.fromJson(x))),
        shipmentOperatingCosts: List<ShipmentOperatingCost>.from(
            json["shipment_operating_costs"]
                .map((x) => ShipmentOperatingCost.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "shipment_id": shipmentId,
        "shipment_code": shipmentCode,
        "shipment_service_id": shipmentServiceId,
        "shipment_signature_flg": shipmentSignatureFlg,
        "shipment_branch_id": shipmentBranchId,
        "shipment_reference_code": shipmentReferenceCode,
        "shipment_status": shipmentStatus,
        "shipment_note": shipmentNote,
        "checked_payment_status": shipmentCheckedPaymentStatus,
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
        "receiver_company_name": receiverCompanyName,
        "receiver_contact_name": receiverContactName,
        "receiver_telephone": receiverTelephone,
        "receiver_country_id": receiverCountryId,
        "receiver_state_id": receiverStateId,
        "receiver_state_name": receiverStateName,
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
        "accountant_status": accountantStatus,
        "shipment_check_create_label": shipmentCheckCreateLabel,
        "user": user.toJson(),
        "service": service.toJson(),
        "branch": branch.toJson(),
        "country": country.toJson(),
        "city": city?.toJson() ?? {},
        "packages": List<dynamic>.from(packages.map((x) => x.toJson())),
        "invoices": List<dynamic>.from(invoices.map((x) => x.toJson())),
        "shipment_operating_costs":
            List<dynamic>.from(shipmentOperatingCosts.map((x) => x.toJson())),
      };
}

class Branch {
  int branchId;
  String? branchName;
  String? branchDescription;
  String? branchLatitude;
  String? branchLongitude;
  int activeFlg;
  int deleteFlg;
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
        branchId: json["branch_id"],
        branchName: json["branch_name"],
        branchDescription: json["branch_description"],
        branchLatitude: json["branch_latitude"],
        branchLongitude: json["branch_longitude"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
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

class CityShipmentDetails {
  int cityId;
  dynamic countryId;
  dynamic stateId;
  String? cityName;
  dynamic cityPostCode;
  String? cityLatitude;
  String? cityLongitude;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  CityShipmentDetails({
    required this.cityId,
    required this.countryId,
    required this.stateId,
    required this.cityName,
    required this.cityPostCode,
    required this.cityLatitude,
    required this.cityLongitude,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CityShipmentDetails.fromJson(Map<String, dynamic> json) =>
      CityShipmentDetails(
        cityId: json["city_id"],
        countryId: json["country_id"],
        stateId: json["state_id"],
        cityName: json["city_name"],
        cityPostCode: json["city_post_code"],
        cityLatitude: json["city_latitude"],
        cityLongitude: json["city_longitude"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "city_id": cityId,
        "country_id": countryId,
        "state_id": stateId,
        "city_name": cityName,
        "city_post_code": cityPostCode,
        "city_latitude": cityLatitude,
        "city_longitude": cityLongitude,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class CountryShipmentDetails {
  int countryId;
  String? countryName;
  String? countryCode;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  CountryShipmentDetails({
    required this.countryId,
    required this.countryName,
    required this.countryCode,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CountryShipmentDetails.fromJson(Map<String, dynamic> json) =>
      CountryShipmentDetails(
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

class InvoiceShipmentDetails {
  int invoiceId;
  int shipmentId;
  String? invoiceCode;
  String? invoiceGoodsDetails;
  dynamic invoiceQuantity;
  dynamic invoiceUnit;
  dynamic invoicePrice;
  dynamic invoiceTotalPrice;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  InvoiceShipmentDetails({
    required this.invoiceId,
    required this.shipmentId,
    required this.invoiceCode,
    required this.invoiceGoodsDetails,
    required this.invoiceQuantity,
    required this.invoiceUnit,
    required this.invoicePrice,
    required this.invoiceTotalPrice,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceShipmentDetails.fromJson(Map<String, dynamic> json) =>
      InvoiceShipmentDetails(
        invoiceId: json["invoice_id"],
        shipmentId: json["shipment_id"],
        invoiceCode: json["invoice_code"],
        invoiceGoodsDetails: json["invoice_goods_details"],
        invoiceQuantity: json["invoice_quantity"],
        invoiceUnit: json["invoice_unit"],
        invoicePrice: json["invoice_price"],
        invoiceTotalPrice: json["invoice_total_price"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "shipment_id": shipmentId,
        "invoice_code": invoiceCode,
        "invoice_goods_details": invoiceGoodsDetails,
        "invoice_quantity": invoiceQuantity,
        "invoice_unit": invoiceUnit,
        "invoice_price": invoicePrice,
        "invoice_total_price": invoiceTotalPrice,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}

class PackageShipmentDetails {
  int packageId;
  int shipmentId;
  String packageCode;
  dynamic packageQuantity;
  dynamic packageType;
  String? packageDescription;
  dynamic packageLength;
  dynamic packageLengthActual; // Added
  dynamic packageWidth;
  dynamic packageWidthActual; // Added
  dynamic packageHeight;
  dynamic packageHeightActual; // Added
  dynamic packageWeight;
  dynamic packageWeightActual; // Added
  String? packageHawbCode;
  dynamic packageConvertedWeight;
  dynamic packageConvertedWeightActual; // Added
  dynamic packageChargedWeight;
  dynamic packageChargedWeightActual; // Added
  dynamic packagePrice; // Added
  dynamic packagePriceActual; // Added
  dynamic packageApprove; // Added
  dynamic processingStaffId; // Added
  String? packageTrackingCode;
  dynamic carrierCode;
  dynamic packageImage;
  dynamic bagCode;
  dynamic smTracktryId;
  dynamic branchConnect;
  String? packageStatus;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;

  PackageShipmentDetails({
    required this.packageId,
    required this.shipmentId,
    required this.packageCode,
    required this.packageQuantity,
    required this.packageType,
    required this.packageDescription,
    required this.packageLength,
    required this.packageLengthActual,
    required this.packageWidth,
    required this.packageWidthActual,
    required this.packageHeight,
    required this.packageHeightActual,
    required this.packageWeight,
    required this.packageWeightActual,
    required this.packageHawbCode,
    required this.packageConvertedWeight,
    required this.packageConvertedWeightActual,
    required this.packageChargedWeight,
    required this.packageChargedWeightActual,
    required this.packagePrice,
    required this.packagePriceActual,
    required this.packageApprove,
    required this.processingStaffId,
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

  factory PackageShipmentDetails.fromJson(Map<String, dynamic> json) =>
      PackageShipmentDetails(
        packageId: json["package_id"],
        shipmentId: json["shipment_id"],
        packageCode: json["package_code"],
        packageQuantity: json["package_quantity"] != null
            ? (json["package_quantity"] is String
                ? int.tryParse(json["package_quantity"])
                : json["package_quantity"])
            : null,
        packageType: json["package_type"],
        packageDescription: json["package_description"],
        packageLength: json["package_length"],
        packageLengthActual: json["package_length_actual"],
        packageWidth: json["package_width"],
        packageWidthActual: json["package_width_actual"],
        packageHeight: json["package_height"],
        packageHeightActual: json["package_height_actual"],
        packageWeight: json["package_weight"],
        packageWeightActual: json["package_weight_actual"],
        packageHawbCode: json["package_hawb_code"],
        packageConvertedWeight: json["package_converted_weight"],
        packageConvertedWeightActual: json["package_converted_weight_actual"],
        packageChargedWeight: json["package_charged_weight"],
        packageChargedWeightActual: json["package_charged_weight_actual"],
        packagePrice: json["package_price"],
        packagePriceActual: json["package_price_actual"],
        packageApprove: json["package_approve"],
        processingStaffId: json["processing_staff_id"] != null
            ? (json["processing_staff_id"] is String
                ? int.tryParse(json["processing_staff_id"])
                : json["processing_staff_id"])
            : null,
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
        "package_length_actual": packageLengthActual,
        "package_width": packageWidth,
        "package_width_actual": packageWidthActual,
        "package_height": packageHeight,
        "package_height_actual": packageHeightActual,
        "package_weight": packageWeight,
        "package_weight_actual": packageWeightActual,
        "package_hawb_code": packageHawbCode,
        "package_converted_weight": packageConvertedWeight,
        "package_converted_weight_actual": packageConvertedWeightActual,
        "package_charged_weight": packageChargedWeight,
        "package_charged_weight_actual": packageChargedWeightActual,
        "package_price": packagePrice,
        "package_price_actual": packagePriceActual,
        "package_approve": packageApprove,
        "processing_staff_id": processingStaffId,
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
  int? transportType;
  dynamic serviceVolumetricMass;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  int? promotionFlg;
  dynamic serviceCode;
  String? serviceNote;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.serviceKind,
    required this.transportType,
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
        serviceId: json["service_id"],
        serviceName: json["service_name"],
        serviceKind: json["service_kind"],
        transportType: json["transport_type"],
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
        "transport_type": transportType,
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

class ShipmentOperatingCost {
  int? shipmentOperatingCostId;
  int shipmentId;
  dynamic operatingCostId;
  dynamic shipmentOperatingCostAmount;
  dynamic shipmentOperatingCostTotalAmount;
  String? shipmentOperatingCostQuantity;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String? operatingCostName;

  ShipmentOperatingCost({
    required this.shipmentOperatingCostId,
    required this.shipmentId,
    required this.operatingCostId,
    required this.shipmentOperatingCostAmount,
    required this.shipmentOperatingCostTotalAmount,
    required this.shipmentOperatingCostQuantity,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.operatingCostName,
  });

  factory ShipmentOperatingCost.fromJson(Map<String, dynamic> json) =>
      ShipmentOperatingCost(
        shipmentOperatingCostId: json["shipment_operating_cost_id"],
        shipmentId: json["shipment_id"],
        operatingCostId: json["operating_cost_id"],
        shipmentOperatingCostAmount: json["shipment_operating_cost_amount"],
        shipmentOperatingCostTotalAmount:
            json["shipment_operating_cost_total_amount"],
        shipmentOperatingCostQuantity: json["shipment_operating_cost_quantity"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        operatingCostName: json["operating_cost_name"],
      );

  Map<String, dynamic> toJson() => {
        "shipment_operating_cost_id": shipmentOperatingCostId,
        "shipment_id": shipmentId,
        "operating_cost_id": operatingCostId,
        "shipment_operating_cost_amount": shipmentOperatingCostAmount,
        "shipment_operating_cost_total_amount":
            shipmentOperatingCostTotalAmount,
        "shipment_operating_cost_quantity": shipmentOperatingCostQuantity,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "operating_cost_name": operatingCostName,
      };
}

class User {
  int userId;
  String userName;
  String? userCode;
  String? userApiKey;
  dynamic positionId;
  int branchId;
  String userContactName;
  String userPhone;
  String userAddress;
  dynamic userLatitude;
  dynamic userLongitude;
  String? userSignature;
  dynamic userLimitAmountForSale;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  String? userAccountantKey;
  String? userCompanyName;
  String? userTaxCode;
  String? userAddress1;
  String? userAddress2;
  String? userAddress3;
  String? userLogo;
  dynamic userDebitType;
  dynamic userPriceListMainType;
  dynamic userPriceListChangeType;
  dynamic userRemainingLimit;
  dynamic userPriceListChangeDate;
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
    required this.userRemainingLimit,
    required this.userPriceListChangeDate,
    required this.userKpiId,
    required this.userIsFreeTime,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json["user_id"],
        userName: json["user_name"],
        userCode: json["user_code"],
        userApiKey: json["user_api_key"],
        positionId: json["position_id"],
        branchId: json["branch_id"],
        userContactName: json["user_contact_name"],
        userPhone: json["user_phone"],
        userAddress: json["user_address"],
        userLatitude: json["user_latitude"],
        userLongitude: json["user_longitude"],
        userSignature: json["user_signature"],
        userLimitAmountForSale: json["user_limit_amount_for_sale"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        userAccountantKey: json["user_accountant_key"],
        userCompanyName: json["user_company_name"],
        userTaxCode: json["user_tax_code"],
        userAddress1: json["user_address_1"],
        userAddress2: json["user_address_2"],
        userAddress3: json["user_address_3"],
        userLogo: json["user_logo"],
        userDebitType: json["user_debit_type"],
        userPriceListMainType: json["user_price_list_main_type"],
        userPriceListChangeType: json["user_price_list_change_type"],
        userRemainingLimit: json["user_remaining_limit"],
        userPriceListChangeDate: json["user_price_list_change_date"],
        userKpiId: json["user_kpi_id"],
        userIsFreeTime: json["user_is_free_time"],
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
        "user_remaining_limit": userRemainingLimit,
        "user_price_list_change_date": userPriceListChangeDate,
        "user_kpi_id": userKpiId,
        "user_is_free_time": userIsFreeTime,
      };
}
