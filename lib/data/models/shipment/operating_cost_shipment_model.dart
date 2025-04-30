// To parse this JSON data, do
//
//     final operatingCostShipmentModel = operatingCostShipmentModelFromJson(jsonString);

import 'dart:convert';

OperatingCostShipmentModel operatingCostShipmentModelFromJson(String str) =>
    OperatingCostShipmentModel.fromJson(json.decode(str));

String operatingCostShipmentModelToJson(OperatingCostShipmentModel data) =>
    json.encode(data.toJson());

class OperatingCostShipmentModel {
  int status;
  List<OperatingCostNew> operatingCosts;
  ChildShipmentOperatingCostModel shipment;

  OperatingCostShipmentModel({
    required this.status,
    required this.operatingCosts,
    required this.shipment,
  });

  factory OperatingCostShipmentModel.fromJson(Map<String, dynamic> json) =>
      OperatingCostShipmentModel(
        status: json["status"],
        operatingCosts: List<OperatingCostNew>.from(
            json["operating_costs"].map((x) => OperatingCostNew.fromJson(x))),
        shipment: ChildShipmentOperatingCostModel.fromJson(json["shipment"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "operating_costs":
            List<dynamic>.from(operatingCosts.map((x) => x.toJson())),
        "shipment": shipment.toJson(),
      };
}

class OperatingCostNew {
  int operatingCostId;
  int? parentOperatingCostId;
  String operatingCostName;
  dynamic operatingCostAmount;
  String? operatingCostDescription;
  int operatingCostType;
  dynamic operatingCostPackageNumberFlg;
  dynamic operatingCostDefaultFlg;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  List<OperatingCostNew>? childOperatingCost;
  dynamic shipmentOperatingCostId;
  dynamic shipmentOperatingCostAmount;
  dynamic shipmentOperatingCostQuantity;

  OperatingCostNew({
    required this.operatingCostId,
    required this.parentOperatingCostId,
    required this.operatingCostName,
    required this.operatingCostAmount,
    required this.operatingCostDescription,
    required this.operatingCostType,
    required this.operatingCostPackageNumberFlg,
    required this.operatingCostDefaultFlg,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    this.childOperatingCost,
    this.shipmentOperatingCostId,
    this.shipmentOperatingCostAmount,
    this.shipmentOperatingCostQuantity,
  });

  factory OperatingCostNew.fromJson(Map<String, dynamic> json) =>
      OperatingCostNew(
        operatingCostId: json["operating_cost_id"],
        parentOperatingCostId: json["parent_operating_cost_id"],
        operatingCostName: json["operating_cost_name"],
        operatingCostAmount: json["operating_cost_amount"],
        operatingCostDescription: json["operating_cost_description"],
        operatingCostType: json["operating_cost_type"],
        operatingCostPackageNumberFlg:
            json["operating_cost_package_number_flg"],
        operatingCostDefaultFlg: json["operating_cost_default_flg"],
        activeFlg: json["active_flg"],
        deleteFlg: json["delete_flg"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        childOperatingCost: json["child_operating_cost"] == null
            ? []
            : List<OperatingCostNew>.from(json["child_operating_cost"]!
                .map((x) => OperatingCostNew.fromJson(x))),
        shipmentOperatingCostId: json["shipment_operating_cost_id"],
        shipmentOperatingCostAmount: json["shipment_operating_cost_amount"],
        shipmentOperatingCostQuantity: json["shipment_operating_cost_quantity"],
      );

  Map<String, dynamic> toJson() => {
        "operating_cost_id": operatingCostId,
        "parent_operating_cost_id": parentOperatingCostId,
        "operating_cost_name": operatingCostName,
        "operating_cost_amount": operatingCostAmount,
        "operating_cost_description": operatingCostDescription,
        "operating_cost_type": operatingCostType,
        "operating_cost_package_number_flg": operatingCostPackageNumberFlg,
        "operating_cost_default_flg": operatingCostDefaultFlg,
        "active_flg": activeFlg,
        "delete_flg": deleteFlg,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "child_operating_cost": childOperatingCost == null
            ? []
            : List<dynamic>.from(childOperatingCost!.map((x) => x.toJson())),
        "shipment_operating_cost_id": shipmentOperatingCostId,
        "shipment_operating_cost_amount": shipmentOperatingCostAmount,
        "shipment_operating_cost_quantity": shipmentOperatingCostQuantity,
      };
}

class ChildShipmentOperatingCostModel {
  int shipmentId;
  String? shipmentCode;
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
  String? shipmentFileLabel;
  dynamic shipmentFileProofOfPayment;
  dynamic shipmentPaymentMethod;
  dynamic shipmentIosscode;
  dynamic shipmentPaymentStatus;
  dynamic shipmentAmountService;
  dynamic shipmentDebitId;
  dynamic shipmentFinalAmount;
  int userId;
  dynamic receiverId;
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
  dynamic receiverCountryId;
  dynamic receiverStateId;
  dynamic receiverCityId;
  String? receiverPostalCode;
  String? receiverAddress1;
  String? receiverAddress2;
  String? receiverAddress3;
  dynamic saveReceiverFlg;
  dynamic shipmentCloseBill;
  dynamic shipmentHawbCode;
  String? receiverSmsName;
  String? receiverSmsPhone;
  int activeFlg;
  int deleteFlg;
  DateTime createdAt;
  DateTime updatedAt;
  dynamic shipmentCheckCreateLabel;
  List<Package> packages;

  ChildShipmentOperatingCostModel({
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
    required this.packages,
  });

  factory ChildShipmentOperatingCostModel.fromJson(Map<String, dynamic> json) =>
      ChildShipmentOperatingCostModel(
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
        packages: List<Package>.from(
            json["packages"].map((x) => Package.fromJson(x))),
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
        "packages": List<dynamic>.from(packages.map((x) => x.toJson())),
      };
}

class Package {
  int packageId;
  int shipmentId;
  String? packageCode;
  dynamic packageQuantity;
  dynamic packageType;
  String? packageDescription;
  dynamic packageLength;
  dynamic packageWidth;
  dynamic packageHeight;
  dynamic packageWeight;
  String? packageHawbCode;
  dynamic packageConvertedWeight;
  dynamic packageChargedWeight;
  String? packageTrackingCode;
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
        packageId: json["package_id"],
        shipmentId: json["shipment_id"],
        packageCode: json["package_code"],
        packageQuantity: json["package_quantity"],
        packageType: json["package_type"],
        packageDescription: json["package_description"],
        packageLength: json["package_length"],
        packageWidth: json["package_width"],
        packageHeight: json["package_height"],
        packageWeight: json["package_weight"],
        packageHawbCode: json["package_hawb_code"],
        packageConvertedWeight: json["package_converted_weight"],
        packageChargedWeight: json["package_charged_weight"],
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
