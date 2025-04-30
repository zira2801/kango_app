// To parse this JSON data, do
//
//     final detailsShipmentToUpdateModel = detailsShipmentToUpdateModelFromJson(jsonString);

import 'dart:convert';

DetailsShipmentToUpdateModel detailsShipmentToUpdateModelFromJson(String str) =>
    DetailsShipmentToUpdateModel.fromJson(json.decode(str));

String detailsShipmentToUpdateModelToJson(DetailsShipmentToUpdateModel data) =>
    json.encode(data.toJson());

class DetailsShipmentToUpdateModel {
  int status;
  Shipment shipment;
  Address address;
  List<Receiver> receivers;
  List<CountryShipmentToUpdate> countries;
  List<Branch> branchs;
  List<String> packageTypes;
  List<String> invoiceExportsAs;
  List<String> invoiceUnits;

  DetailsShipmentToUpdateModel({
    required this.status,
    required this.shipment,
    required this.address,
    required this.receivers,
    required this.countries,
    required this.branchs,
    required this.packageTypes,
    required this.invoiceExportsAs,
    required this.invoiceUnits,
  });

  factory DetailsShipmentToUpdateModel.fromJson(Map<String, dynamic> json) =>
      DetailsShipmentToUpdateModel(
        status: json["status"],
        shipment: Shipment.fromJson(json["shipment"]),
        address: Address.fromJson(json["address"]),
        receivers: List<Receiver>.from(
            json["receivers"].map((x) => Receiver.fromJson(x))),
        countries: List<CountryShipmentToUpdate>.from(
            json["countries"].map((x) => CountryShipmentToUpdate.fromJson(x))),
        branchs:
            List<Branch>.from(json["branchs"].map((x) => Branch.fromJson(x))),
        packageTypes: List<String>.from(json["package_types"].map((x) => x)),
        invoiceExportsAs:
            List<String>.from(json["invoice_exports_as"].map((x) => x)),
        invoiceUnits: List<String>.from(json["invoice_units"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "shipment": shipment.toJson(),
        "address": address.toJson(),
        "receivers": List<dynamic>.from(receivers.map((x) => x.toJson())),
        "countries": List<dynamic>.from(countries.map((x) => x.toJson())),
        "branchs": List<dynamic>.from(branchs.map((x) => x.toJson())),
        "package_types": List<dynamic>.from(packageTypes.map((x) => x)),
        "invoice_exports_as":
            List<dynamic>.from(invoiceExportsAs.map((x) => x)),
        "invoice_units": List<dynamic>.from(invoiceUnits.map((x) => x)),
      };
}

class Address {
  List<String> cities;
  List<String> districts;
  List<String> wards;

  Address({
    required this.cities,
    required this.districts,
    required this.wards,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        cities: List<String>.from(json["cities"].map((x) => x)),
        districts: List<String>.from(json["districts"].map((x) => x)),
        wards: List<String>.from(json["wards"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "cities": List<dynamic>.from(cities.map((x) => x)),
        "districts": List<dynamic>.from(districts.map((x) => x)),
        "wards": List<dynamic>.from(wards.map((x) => x)),
      };
}

class Branch {
  int branchId;
  String branchName;

  Branch({
    required this.branchId,
    required this.branchName,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        branchId: json["branch_id"],
        branchName: json["branch_name"],
      );

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "branch_name": branchName,
      };
}

class CountryShipmentToUpdate {
  int countryId;
  String countryName;

  CountryShipmentToUpdate({
    required this.countryId,
    required this.countryName,
  });

  factory CountryShipmentToUpdate.fromJson(Map<String, dynamic> json) =>
      CountryShipmentToUpdate(
        countryId: json["country_id"],
        countryName: json["country_name"],
      );

  Map<String, dynamic> toJson() => {
        "country_id": countryId,
        "country_name": countryName,
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

class Shipment {
  int shipmentId;
  String shipmentCode;
  int shipmentServiceId;
  int shipmentSignatureFlg;
  int shipmentBranchId;
  String? shipmentReferenceCode;
  String shipmentGoodsName;
  dynamic shipmentValue;
  int shipmentExportAs;
  int userId;
  int? receiverId;
  String? senderCompanyName;
  String? senderContactName;
  String? senderTelephone;
  int senderCity;
  dynamic senderDistrict;
  dynamic senderWard;
  String? senderAddress;
  String? receiverCompanyName;
  String? receiverContactName;
  String? receiverTelephone;
  int receiverCountryId;
  dynamic receiverStateId;
  String? receiverStateName;
  dynamic receiverCityId;
  String? receiverPostalCode;
  String? receiverAddress1;
  String? receiverAddress2;
  String? receiverAddress3;
  List<Package> packages;
  List<Invoice> invoices;

  Shipment({
    required this.shipmentId,
    required this.shipmentCode,
    required this.shipmentServiceId,
    required this.shipmentSignatureFlg,
    required this.shipmentBranchId,
    required this.shipmentReferenceCode,
    required this.shipmentGoodsName,
    required this.shipmentValue,
    required this.shipmentExportAs,
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
    required this.packages,
    required this.invoices,
  });

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        shipmentId: json["shipment_id"],
        shipmentCode: json["shipment_code"],
        shipmentServiceId: json["shipment_service_id"],
        shipmentSignatureFlg: json["shipment_signature_flg"],
        shipmentBranchId: json["shipment_branch_id"],
        shipmentReferenceCode: json["shipment_reference_code"],
        shipmentGoodsName: json["shipment_goods_name"],
        shipmentValue: json["shipment_value"],
        shipmentExportAs: json["shipment_export_as"],
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
        packages: List<Package>.from(
            json["packages"].map((x) => Package.fromJson(x))),
        invoices: List<Invoice>.from(
            json["invoices"].map((x) => Invoice.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "shipment_id": shipmentId,
        "shipment_code": shipmentCode,
        "shipment_service_id": shipmentServiceId,
        "shipment_signature_flg": shipmentSignatureFlg,
        "shipment_branch_id": shipmentBranchId,
        "shipment_reference_code": shipmentReferenceCode,
        "shipment_goods_name": shipmentGoodsName,
        "shipment_value": shipmentValue,
        "shipment_export_as": shipmentExportAs,
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
        "packages": List<dynamic>.from(packages.map((x) => x.toJson())),
        "invoices": List<dynamic>.from(invoices.map((x) => x.toJson())),
      };
}

class Invoice {
  int? invoiceId;
  int? shipmentId;
  String? invoiceGoodsDetails;
  dynamic invoiceQuantity;
  dynamic invoiceUnit;
  dynamic invoicePrice;
  dynamic invoiceTotalPrice;

  Invoice({
    required this.invoiceId,
    required this.shipmentId,
    required this.invoiceGoodsDetails,
    required this.invoiceQuantity,
    required this.invoiceUnit,
    required this.invoicePrice,
    required this.invoiceTotalPrice,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        invoiceId: json["invoice_id"],
        shipmentId: json["shipment_id"],
        invoiceGoodsDetails: json["invoice_goods_details"],
        invoiceQuantity: json["invoice_quantity"],
        invoiceUnit: json["invoice_unit"],
        invoicePrice: json["invoice_price"],
        invoiceTotalPrice: json["invoice_total_price"],
      );

  Map<String, dynamic> toJson() => {
        "invoice_id": invoiceId,
        "shipment_id": shipmentId,
        "invoice_goods_details": invoiceGoodsDetails,
        "invoice_quantity": invoiceQuantity,
        "invoice_unit": invoiceUnit,
        "invoice_price": invoicePrice,
        "invoice_total_price": invoiceTotalPrice,
      };
}

class Package {
  int? packageId;
  int? shipmentId;
  dynamic packageQuantity;
  dynamic packageType;
  dynamic packageLength;
  dynamic packageWidth;
  dynamic packageHeight;
  dynamic packageWeight;

  Package({
    required this.packageId,
    required this.shipmentId,
    required this.packageQuantity,
    required this.packageType,
    required this.packageLength,
    required this.packageWidth,
    required this.packageHeight,
    required this.packageWeight,
  });

  factory Package.fromJson(Map<String, dynamic> json) => Package(
        packageId: json["package_id"],
        shipmentId: json["shipment_id"],
        packageQuantity: json["package_quantity"],
        packageType: json["package_type"],
        packageLength: json["package_length"],
        packageWidth: json["package_width"],
        packageHeight: json["package_height"],
        packageWeight: json["package_weight"],
      );

  Map<String, dynamic> toJson() => {
        "package_id": packageId,
        "shipment_id": shipmentId,
        "package_quantity": packageQuantity,
        "package_type": packageType,
        "package_length": packageLength,
        "package_width": packageWidth,
        "package_height": packageHeight,
        "package_weight": packageWeight,
      };
}
