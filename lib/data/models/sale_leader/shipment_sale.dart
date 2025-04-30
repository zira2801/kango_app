class ShipmentSaleResponse {
  final int? status;
  final ShipmentsSale shipments;

  ShipmentSaleResponse({
    required this.status,
    required this.shipments,
  });

  factory ShipmentSaleResponse.fromJson(Map<String, dynamic> json) {
    return ShipmentSaleResponse(
      status: json['status'] as int?,
      shipments:
          ShipmentsSale.fromJson(json['shipments'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'shipments': shipments.toJson(),
    };
  }
}

class ShipmentsSale {
  final int? currentPage; // Cho phép null
  final List<ShipmentSaleData> data;

  ShipmentsSale({
    required this.currentPage,
    required this.data,
  });

  factory ShipmentsSale.fromJson(Map<String, dynamic> json) {
    return ShipmentsSale(
      currentPage: json['current_page'] as int?, // Không ép kiểu bắt buộc
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => ShipmentSaleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class ShipmentSaleData {
  final int? shipmentId; // Nullable
  final String shipmentCode;
  final int? shipmentServiceId; // Nullable
  final int? shipmentSignatureFlg; // Nullable
  final int? shipmentBranchId; // Nullable
  final String? shipmentReferenceCode;
  final int? shipmentStatus; // Nullable
  final String shipmentGoodsName;
  final int? shipmentValue; // Nullable
  final int? shipmentExportAs; // Nullable
  final int? shipmentAmountTransport; // Nullable
  final int? shipmentAmountTotalCustomer; // Nullable
  final int? shipmentAmountSurcharge; // Nullable
  final int? shipmentAmountInsurance; // Nullable
  final int? shipmentAmountVat; // Nullable
  final dynamic shipmentAmountFsc;
  final int? shipmentDomesticCharges; // Nullable
  final int? shipmentCollectionFee; // Nullable
  final String shipmentAmountPeak;
  final String shipmentAmountResidential;
  final int? shipmentPaidBy; // Nullable
  final int? shipmentAmountOriginal; // Nullable
  final int? shipmentAmountInsuranceValue; // Nullable
  final int? shipmentAmountProfit; // Nullable
  final int? shipmentAmountOperatingCosts; // Nullable
  final int? shipmentAmountDiscount; // Nullable
  final int? shipmentAmountServiceActual; // Nullable
  final int? shipmentTotalAmountActual; // Nullable
  final String? shipmentNote;
  final String? shipmentFileLabel;
  final String? shipmentFileProofOfPayment;
  final int? shipmentPaymentMethod; // Nullable
  final String? shipmentIosscode;
  final int? shipmentPaymentStatus; // Nullable
  final String? shipmentPaymentDes;
  final int? shipmentPaymentStep; // Nullable
  final String? shipmentPaymentDate;
  final int? shipmentAmountService; // Nullable
  final String? shipmentDebitId;
  final int? checkedPaymentStatus; // Nullable
  final int? shipmentFinalAmount; // Nullable
  final int? userId; // Nullable
  final String? receiverId;
  final String senderCompanyName;
  final String senderContactName;
  final String senderTelephone;
  final int? senderCity; // Nullable
  final int? senderDistrict; // Nullable
  final int? senderWard; // Nullable
  final String senderAddress;
  final String? senderLatitude;
  final String? senderLongitude;
  final String receiverCompanyName;
  final String receiverContactName;
  final String receiverTelephone;
  final int? receiverCountryId; // Nullable
  final int? receiverStateId; // Nullable
  final String receiverStateName;
  final int? receiverCityId; // Nullable
  final String receiverPostalCode;
  final String receiverAddress1;
  final String? receiverAddress2;
  final String? receiverAddress3;
  final int? saveReceiverFlg; // Nullable
  final String? shipmentCloseBill;
  final String? shipmentHawbCode;
  final String? receiverSmsName;
  final String receiverSmsPhone;
  final int? activeFlg; // Nullable
  final int? importApproval; // Nullable
  final int? deleteFlg; // Nullable
  final String createdAt;
  final String updatedAt;
  final int? shipmentCheckCreateLabel; // Nullable
  final String? orderPickupId;
  final String? fwdId;
  final int? accountantStatus; // Nullable
  final String completedDate;
  final String? createdLabelAt;
  final String? accountantCancelNote;
  final String? documentId;
  final int? oldData; // Nullable
  final ServiceSale service;
  final BranchSale branch;
  final CountrySale country;
  final List<PackageSale> packages;
  final List<ShipmentOperatingCostSale> shipmentOperatingCosts;

  ShipmentSaleData({
    required this.shipmentId,
    required this.shipmentCode,
    required this.shipmentServiceId,
    required this.shipmentSignatureFlg,
    required this.shipmentBranchId,
    this.shipmentReferenceCode,
    required this.shipmentStatus,
    required this.shipmentGoodsName,
    required this.shipmentValue,
    required this.shipmentExportAs,
    required this.shipmentAmountTransport,
    required this.shipmentAmountTotalCustomer,
    required this.shipmentAmountSurcharge,
    required this.shipmentAmountInsurance,
    required this.shipmentAmountVat,
    this.shipmentAmountFsc,
    required this.shipmentDomesticCharges,
    required this.shipmentCollectionFee,
    required this.shipmentAmountPeak,
    required this.shipmentAmountResidential,
    required this.shipmentPaidBy,
    required this.shipmentAmountOriginal,
    required this.shipmentAmountInsuranceValue,
    required this.shipmentAmountProfit,
    required this.shipmentAmountOperatingCosts,
    required this.shipmentAmountDiscount,
    required this.shipmentAmountServiceActual,
    required this.shipmentTotalAmountActual,
    this.shipmentNote,
    this.shipmentFileLabel,
    this.shipmentFileProofOfPayment,
    required this.shipmentPaymentMethod,
    this.shipmentIosscode,
    required this.shipmentPaymentStatus,
    this.shipmentPaymentDes,
    required this.shipmentPaymentStep,
    this.shipmentPaymentDate,
    required this.shipmentAmountService,
    this.shipmentDebitId,
    required this.checkedPaymentStatus,
    required this.shipmentFinalAmount,
    required this.userId,
    this.receiverId,
    required this.senderCompanyName,
    required this.senderContactName,
    required this.senderTelephone,
    required this.senderCity,
    required this.senderDistrict,
    required this.senderWard,
    required this.senderAddress,
    this.senderLatitude,
    this.senderLongitude,
    required this.receiverCompanyName,
    required this.receiverContactName,
    required this.receiverTelephone,
    required this.receiverCountryId,
    required this.receiverStateId,
    required this.receiverStateName,
    required this.receiverCityId,
    required this.receiverPostalCode,
    required this.receiverAddress1,
    this.receiverAddress2,
    this.receiverAddress3,
    required this.saveReceiverFlg,
    this.shipmentCloseBill,
    this.shipmentHawbCode,
    this.receiverSmsName,
    required this.receiverSmsPhone,
    required this.activeFlg,
    required this.importApproval,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    required this.shipmentCheckCreateLabel,
    this.orderPickupId,
    this.fwdId,
    required this.accountantStatus,
    required this.completedDate,
    this.createdLabelAt,
    this.accountantCancelNote,
    this.documentId,
    required this.oldData,
    required this.service,
    required this.branch,
    required this.country,
    required this.packages,
    required this.shipmentOperatingCosts,
  });

  factory ShipmentSaleData.fromJson(Map<String, dynamic> json) {
    return ShipmentSaleData(
      shipmentId: json['shipment_id'] as int?,
      shipmentCode: json['shipment_code'] as String,
      shipmentServiceId: json['shipment_service_id'] as int?,
      shipmentSignatureFlg: json['shipment_signature_flg'] as int?,
      shipmentBranchId: json['shipment_branch_id'] as int?,
      shipmentReferenceCode: json['shipment_reference_code'] as String?,
      shipmentStatus: json['shipment_status'] as int?,
      shipmentGoodsName: json['shipment_goods_name'] as String,
      shipmentValue: json['shipment_value'] as int?,
      shipmentExportAs: json['shipment_export_as'] as int?,
      shipmentAmountTransport: json['shipment_amount_transport'] as int?,
      shipmentAmountTotalCustomer:
          json['shipment_amount_total_customer'] as int?,
      shipmentAmountSurcharge: json['shipment_amount_surcharge'] as int?,
      shipmentAmountInsurance: json['shipment_amount_insurance'] as int?,
      shipmentAmountVat: json['shipment_amount_vat'] as int?,
      shipmentAmountFsc: json['shipment_amount_fsc'],
      shipmentDomesticCharges: json['shipment_domestic_charges'] as int?,
      shipmentCollectionFee: json['shipment_collection_fee'] as int?,
      shipmentAmountPeak: json['shipment_amount_peak'] as String,
      shipmentAmountResidential: json['shipment_amount_residential'] as String,
      shipmentPaidBy: json['shipment_paid_by'] as int?,
      shipmentAmountOriginal: json['shipment_amount_original'] as int?,
      shipmentAmountInsuranceValue:
          json['shipment_amount_insurance_value'] as int?,
      shipmentAmountProfit: json['shipment_amount_profit'] as int?,
      shipmentAmountOperatingCosts:
          json['shipment_amount_operating_costs'] as int?,
      shipmentAmountDiscount: json['shipment_amount_discount'] as int?,
      shipmentAmountServiceActual:
          json['shipment_amount_service_actual'] as int?,
      shipmentTotalAmountActual: json['shipment_total_amount_actual'] as int?,
      shipmentNote: json['shipment_note'] as String?,
      shipmentFileLabel: json['shipment_file_label'] as String?,
      shipmentFileProofOfPayment:
          json['shipment_file_proof_of_payment'] as String?,
      shipmentPaymentMethod: json['shipment_payment_method'] as int?,
      shipmentIosscode: json['shipment_iosscode'] as String?,
      shipmentPaymentStatus: json['shipment_payment_status'] as int?,
      shipmentPaymentDes: json['shipment_payment_des'] as String?,
      shipmentPaymentStep: json['shipment_payment_step'] as int?,
      shipmentPaymentDate: json['shipment_payment_date'] as String?,
      shipmentAmountService: json['shipment_amount_service'] as int?,
      shipmentDebitId: json['shipment_debit_id'] as String?,
      checkedPaymentStatus: json['checked_payment_status'] as int?,
      shipmentFinalAmount: json['shipment_final_amount'] as int?,
      userId: json['user_id'] as int?,
      receiverId: json['receiver_id'] as String?,
      senderCompanyName: json['sender_company_name'] as String,
      senderContactName: json['sender_contact_name'] as String,
      senderTelephone: json['sender_telephone'] as String,
      senderCity: json['sender_city'] as int?,
      senderDistrict: json['sender_district'] as int?,
      senderWard: json['sender_ward'] as int?,
      senderAddress: json['sender_address'] as String,
      senderLatitude: json['serder_latitude'] as String?,
      senderLongitude: json['sender_longitude'] as String?,
      receiverCompanyName: json['receiver_company_name'] as String,
      receiverContactName: json['receiver_contact_name'] as String,
      receiverTelephone: json['receiver_telephone'] as String,
      receiverCountryId: json['receiver_country_id'] as int?,
      receiverStateId: json['receiver_state_id'] as int?,
      receiverStateName: json['receiver_state_name'] as String,
      receiverCityId: json['receiver_city_id'] as int?,
      receiverPostalCode: json['receiver_postal_code'] as String,
      receiverAddress1: json['receiver_address_1'] as String,
      receiverAddress2: json['receiver_address_2'] as String?,
      receiverAddress3: json['receiver_address_3'] as String?,
      saveReceiverFlg: json['save_receiver_flg'] as int?,
      shipmentCloseBill: json['shipment_close_bill'] as String?,
      shipmentHawbCode: json['shipment_hawb_code'] as String?,
      receiverSmsName: json['receiver_sms_name'] as String?,
      receiverSmsPhone: json['receiver_sms_phone'] as String,
      activeFlg: json['active_flg'] as int?,
      importApproval: json['import_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      shipmentCheckCreateLabel: json['shipment_check_create_label'] as int?,
      orderPickupId: json['order_pickup_id'] as String?,
      fwdId: json['fwd_id'] as String?,
      accountantStatus: json['accountant_status'] as int?,
      completedDate: json['completed_date'] as String,
      createdLabelAt: json['created_lable_at'] as String?,
      accountantCancelNote: json['accountant_cancel_note'] as String?,
      documentId: json['document_id'] as String?,
      oldData: json['old_data'] as int?,
      service: ServiceSale.fromJson(json['service'] as Map<String, dynamic>),
      branch: BranchSale.fromJson(json['branch'] as Map<String, dynamic>),
      country: CountrySale.fromJson(json['country'] as Map<String, dynamic>),
      packages: (json['packages'] as List<dynamic>? ?? [])
          .map((e) => PackageSale.fromJson(e as Map<String, dynamic>))
          .toList(),
      shipmentOperatingCosts:
          (json['shipment_operating_costs'] as List<dynamic>? ?? [])
              .map((e) =>
                  ShipmentOperatingCostSale.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shipment_id': shipmentId,
      'shipment_code': shipmentCode,
      'shipment_service_id': shipmentServiceId,
      'shipment_signature_flg': shipmentSignatureFlg,
      'shipment_branch_id': shipmentBranchId,
      'shipment_reference_code': shipmentReferenceCode,
      'shipment_status': shipmentStatus,
      'shipment_goods_name': shipmentGoodsName,
      'shipment_value': shipmentValue,
      'shipment_export_as': shipmentExportAs,
      'shipment_amount_transport': shipmentAmountTransport,
      'shipment_amount_total_customer': shipmentAmountTotalCustomer,
      'shipment_amount_surcharge': shipmentAmountSurcharge,
      'shipment_amount_insurance': shipmentAmountInsurance,
      'shipment_amount_vat': shipmentAmountVat,
      'shipment_amount_fsc': shipmentAmountFsc,
      'shipment_domestic_charges': shipmentDomesticCharges,
      'shipment_collection_fee': shipmentCollectionFee,
      'shipment_amount_peak': shipmentAmountPeak,
      'shipment_amount_residential': shipmentAmountResidential,
      'shipment_paid_by': shipmentPaidBy,
      'shipment_amount_original': shipmentAmountOriginal,
      'shipment_amount_insurance_value': shipmentAmountInsuranceValue,
      'shipment_amount_profit': shipmentAmountProfit,
      'shipment_amount_operating_costs': shipmentAmountOperatingCosts,
      'shipment_amount_discount': shipmentAmountDiscount,
      'shipment_amount_service_actual': shipmentAmountServiceActual,
      'shipment_total_amount_actual': shipmentTotalAmountActual,
      'shipment_note': shipmentNote,
      'shipment_file_label': shipmentFileLabel,
      'shipment_file_proof_of_payment': shipmentFileProofOfPayment,
      'shipment_payment_method': shipmentPaymentMethod,
      'shipment_iosscode': shipmentIosscode,
      'shipment_payment_status': shipmentPaymentStatus,
      'shipment_payment_des': shipmentPaymentDes,
      'shipment_payment_step': shipmentPaymentStep,
      'shipment_payment_date': shipmentPaymentDate,
      'shipment_amount_service': shipmentAmountService,
      'shipment_debit_id': shipmentDebitId,
      'checked_payment_status': checkedPaymentStatus,
      'shipment_final_amount': shipmentFinalAmount,
      'user_id': userId,
      'receiver_id': receiverId,
      'sender_company_name': senderCompanyName,
      'sender_contact_name': senderContactName,
      'sender_telephone': senderTelephone,
      'sender_city': senderCity,
      'sender_district': senderDistrict,
      'sender_ward': senderWard,
      'sender_address': senderAddress,
      'serder_latitude': senderLatitude,
      'sender_longitude': senderLongitude,
      'receiver_company_name': receiverCompanyName,
      'receiver_contact_name': receiverContactName,
      'receiver_telephone': receiverTelephone,
      'receiver_country_id': receiverCountryId,
      'receiver_state_id': receiverStateId,
      'receiver_state_name': receiverStateName,
      'receiver_city_id': receiverCityId,
      'receiver_postal_code': receiverPostalCode,
      'receiver_address_1': receiverAddress1,
      'receiver_address_2': receiverAddress2,
      'receiver_address_3': receiverAddress3,
      'save_receiver_flg': saveReceiverFlg,
      'shipment_close_bill': shipmentCloseBill,
      'shipment_hawb_code': shipmentHawbCode,
      'receiver_sms_name': receiverSmsName,
      'receiver_sms_phone': receiverSmsPhone,
      'active_flg': activeFlg,
      'import_approval': importApproval,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'shipment_check_create_label': shipmentCheckCreateLabel,
      'order_pickup_id': orderPickupId,
      'fwd_id': fwdId,
      'accountant_status': accountantStatus,
      'completed_date': completedDate,
      'created_lable_at': createdLabelAt,
      'accountant_cancel_note': accountantCancelNote,
      'document_id': documentId,
      'old_data': oldData,
      'service': service.toJson(),
      'branch': branch.toJson(),
      'country': country.toJson(),
      'packages': packages.map((e) => e.toJson()).toList(),
      'shipment_operating_costs':
          shipmentOperatingCosts.map((e) => e.toJson()).toList(),
    };
  }
}

class ServiceSale {
  final int? serviceId; // Nullable
  final String serviceName;
  final String serviceKind;
  final int? serviceVolumetricMass; // Nullable
  final int? serviceApplicableWeight; // Nullable
  final int? activeFlg; // Nullable
  final int? deleteFlg; // Nullable
  final String createdAt;
  final String updatedAt;
  final int? promotionFlg; // Nullable
  final String? serviceCode;
  final String? serviceNote;

  ServiceSale({
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

  factory ServiceSale.fromJson(Map<String, dynamic> json) {
    return ServiceSale(
      serviceId: json['service_id'] as int?,
      serviceName: json['service_name'] as String,
      serviceKind: json['service_kind'] as String,
      serviceVolumetricMass: json['service_volumetric_mass'] as int?,
      serviceApplicableWeight: json['service_applicable_weight'] as int?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      promotionFlg: json['promotion_flg'] as int?,
      serviceCode: json['service_code'] as String?,
      serviceNote: json['service_note'] as String?,
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

class BranchSale {
  final int? branchId; // Nullable
  final String branchName;
  final String branchDescription;
  final String branchLatitude;
  final String branchLongitude;
  final int? activeFlg; // Nullable
  final int? deleteFlg; // Nullable
  final String createdAt;
  final String updatedAt;

  BranchSale({
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

  factory BranchSale.fromJson(Map<String, dynamic> json) {
    return BranchSale(
      branchId: json['branch_id'] as int?,
      branchName: json['branch_name'] as String,
      branchDescription: json['branch_description'] as String,
      branchLatitude: json['branch_latitude'] as String,
      branchLongitude: json['branch_longitude'] as String,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'branch_name': branchName,
      'branch_description': branchDescription,
      'branch_latitude': branchLatitude,
      'branch_longitude': branchLongitude,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class CountrySale {
  final int? countryId; // Nullable
  final String countryName;
  final String countryCode;
  final int? activeFlg; // Nullable
  final int? deleteFlg; // Nullable
  final String createdAt;
  final String updatedAt;

  CountrySale({
    required this.countryId,
    required this.countryName,
    required this.countryCode,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CountrySale.fromJson(Map<String, dynamic> json) {
    return CountrySale(
      countryId: json['country_id'] as int?,
      countryName: json['country_name'] as String,
      countryCode: json['country_code'] as String,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_id': countryId,
      'country_name': countryName,
      'country_code': countryCode,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class PackageSale {
  final int? packageId; // Nullable
  final int? shipmentId; // Nullable
  final String packageCode;
  final int? packageQuantity; // Nullable
  final int? packageType; // Nullable
  final String packageDescription;
  final int? packageLength; // Nullable
  final dynamic packageLengthActual;
  final int? packageWidth; // Nullable
  final dynamic packageWidthActual;
  final int? packageHeight; // Nullable
  final dynamic packageHeightActual;
  final int? packageWeight; // Nullable
  final dynamic packageWeightActual;
  final String packageHawbCode;
  final double packageConvertedWeight;
  final dynamic packageConvertedWeightActual;
  final int? packageChargedWeight; // Nullable
  final dynamic packageChargedWeightActual;
  final String? packageTrackingCode;
  final int? packagePrice; // Nullable
  final int? packagePriceActual; // Nullable
  final int? packageApprove; // Nullable
  final String? processingStaffId;
  final String? carrierCode;
  final String? packageImage;
  final String? bagCode;
  final String? smTracktryId;
  final String? branchConnect;
  final String packageStatus;
  final int? activeFlg; // Nullable
  final int? deleteFlg; // Nullable
  final String createdAt;
  final String updatedAt;

  PackageSale({
    required this.packageId,
    required this.shipmentId,
    required this.packageCode,
    required this.packageQuantity,
    required this.packageType,
    required this.packageDescription,
    required this.packageLength,
    this.packageLengthActual,
    required this.packageWidth,
    this.packageWidthActual,
    required this.packageHeight,
    this.packageHeightActual,
    required this.packageWeight,
    this.packageWeightActual,
    required this.packageHawbCode,
    required this.packageConvertedWeight,
    this.packageConvertedWeightActual,
    required this.packageChargedWeight,
    this.packageChargedWeightActual,
    this.packageTrackingCode,
    required this.packagePrice,
    required this.packagePriceActual,
    required this.packageApprove,
    this.processingStaffId,
    this.carrierCode,
    this.packageImage,
    this.bagCode,
    this.smTracktryId,
    this.branchConnect,
    required this.packageStatus,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageSale.fromJson(Map<String, dynamic> json) {
    return PackageSale(
      packageId: json['package_id'] as int?,
      shipmentId: json['shipment_id'] as int?,
      packageCode: json['package_code'] as String,
      packageQuantity: json['package_quantity'] as int?,
      packageType: json['package_type'] as int?,
      packageDescription: json['package_description'] as String,
      packageLength: json['package_length'] as int?,
      packageLengthActual: json['package_length_actual'],
      packageWidth: json['package_width'] as int?,
      packageWidthActual: json['package_width_actual'],
      packageHeight: json['package_height'] as int?,
      packageHeightActual: json['package_height_actual'],
      packageWeight: json['package_weight'] as int?,
      packageWeightActual: json['package_weight_actual'],
      packageHawbCode: json['package_hawb_code'] as String,
      packageConvertedWeight:
          (json['package_converted_weight'] as num?)?.toDouble() ?? 0.0,
      packageConvertedWeightActual: json['package_converted_weight_actual'],
      packageChargedWeight: json['package_charged_weight'] as int?,
      packageChargedWeightActual: json['package_charged_weight_actual'],
      packageTrackingCode: json['package_tracking_code'] as String?,
      packagePrice: json['package_price'] as int?,
      packagePriceActual: json['package_price_actual'] as int?,
      packageApprove: json['package_approve'] as int?,
      processingStaffId: json['processing_staff_id'] as String?,
      carrierCode: json['carrier_code'] as String?,
      packageImage: json['package_image'] as String?,
      bagCode: json['bag_code'] as String?,
      smTracktryId: json['sm_tracktry_id'] as String?,
      branchConnect: json['branch_connect'] as String?,
      packageStatus: json['package_status'] as String,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'shipment_id': shipmentId,
      'package_code': packageCode,
      'package_quantity': packageQuantity,
      'package_type': packageType,
      'package_description': packageDescription,
      'package_length': packageLength,
      'package_length_actual': packageLengthActual,
      'package_width': packageWidth,
      'package_width_actual': packageWidthActual,
      'package_height': packageHeight,
      'package_height_actual': packageHeightActual,
      'package_weight': packageWeight,
      'package_weight_actual': packageWeightActual,
      'package_hawb_code': packageHawbCode,
      'package_converted_weight': packageConvertedWeight,
      'package_converted_weight_actual': packageConvertedWeightActual,
      'package_charged_weight': packageChargedWeight,
      'package_charged_weight_actual': packageChargedWeightActual,
      'package_tracking_code': packageTrackingCode,
      'package_price': packagePrice,
      'package_price_actual': packagePriceActual,
      'package_approve': packageApprove,
      'processing_staff_id': processingStaffId,
      'carrier_code': carrierCode,
      'package_image': packageImage,
      'bag_code': bagCode,
      'sm_tracktry_id': smTracktryId,
      'branch_connect': branchConnect,
      'package_status': packageStatus,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class ShipmentOperatingCostSale {
  final int? shipmentOperatingCostId; // Nullable
  final int? shipmentId; // Nullable
  final int? operatingCostId; // Nullable
  final int? shipmentOperatingCostAmount; // Nullable
  final int? shipmentOperatingCostTotalAmount; // Nullable
  final String shipmentOperatingCostQuantity;
  final int? activeFlg; // Nullable
  final int? deleteFlg; // Nullable
  final String createdAt;
  final String updatedAt;

  ShipmentOperatingCostSale({
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
  });

  factory ShipmentOperatingCostSale.fromJson(Map<String, dynamic> json) {
    return ShipmentOperatingCostSale(
      shipmentOperatingCostId: json['shipment_operating_cost_id'] as int?,
      shipmentId: json['shipment_id'] as int?,
      operatingCostId: json['operating_cost_id'] as int?,
      shipmentOperatingCostAmount:
          json['shipment_operating_cost_amount'] as int?,
      shipmentOperatingCostTotalAmount:
          json['shipment_operating_cost_total_amount'] as int?,
      shipmentOperatingCostQuantity:
          json['shipment_operating_cost_quantity'] as String,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shipment_operating_cost_id': shipmentOperatingCostId,
      'shipment_id': shipmentId,
      'operating_cost_id': operatingCostId,
      'shipment_operating_cost_amount': shipmentOperatingCostAmount,
      'shipment_operating_cost_total_amount': shipmentOperatingCostTotalAmount,
      'shipment_operating_cost_quantity': shipmentOperatingCostQuantity,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
