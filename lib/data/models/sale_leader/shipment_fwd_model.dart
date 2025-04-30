class ShipmentFwdResponse {
  final int? status;
  final List<ShipmentFwdModel>? shipments;
  final SaleTeam? saleTeam;

  ShipmentFwdResponse({
    this.status,
    this.shipments,
    this.saleTeam,
  });

  factory ShipmentFwdResponse.fromJson(Map<String, dynamic> json) {
    return ShipmentFwdResponse(
      status: json['status'] as int?,
      shipments: json['shipments'] != null
          ? (json['shipments'] as List)
              .map((e) => ShipmentFwdModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      saleTeam: json['sale_team'] != null
          ? SaleTeam.fromJson(json['sale_team'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'shipments': shipments?.map((e) => e.toJson()).toList(),
      'sale_team': saleTeam?.toJson(),
    };
  }
}

class ShipmentFwdModel {
  final int? shipmentId;
  final String? shipmentCode;
  final int? shipmentServiceId;
  final int? shipmentSignatureFlg;
  final int? shipmentBranchId;
  final String? shipmentReferenceCode;
  final int? shipmentStatus;
  final String? shipmentGoodsName;
  final int? shipmentValue;
  final int? shipmentExportAs;
  final int? shipmentAmountTransport;
  final int? shipmentAmountTotalCustomer;
  final int? shipmentAmountSurcharge;
  final int? shipmentAmountInsurance;
  final int? shipmentAmountVat;
  final int? shipmentAmountFsc;
  final int? shipmentDomesticCharges;
  final int? shipmentCollectionFee;
  final String? shipmentAmountPeak;
  final String? shipmentAmountResidential;
  final int? shipmentPaidBy;
  final int? shipmentAmountOriginal;
  final int? shipmentAmountInsuranceValue;
  final int? shipmentAmountProfit;
  final int? shipmentAmountOperatingCosts;
  final int? shipmentAmountDiscount;
  final int? shipmentAmountServiceActual;
  final int? shipmentTotalAmountActual;
  final String? shipmentNote;
  final String? shipmentFileLabel;
  final String? shipmentFileProofOfPayment;
  final int? shipmentPaymentMethod;
  final String? shipmentIosscode;
  final int? shipmentPaymentStatus;
  final String? shipmentPaymentDes;
  final int? shipmentPaymentStep;
  final String? shipmentPaymentDate;
  final int? shipmentAmountService;
  final int? shipmentDebitId;
  final int? checkedPaymentStatus;
  final int? shipmentFinalAmount;
  final int? userId;
  final int? receiverId;
  final String? senderCompanyName;
  final String? senderContactName;
  final String? senderTelephone;
  final int? senderCity;
  final int? senderDistrict;
  final int? senderWard;
  final String? senderAddress;
  final String? serderLatitude;
  final String? senderLongitude;
  final String? receiverCompanyName;
  final String? receiverContactName;
  final String? receiverTelephone;
  final int? receiverCountryId;
  final int? receiverStateId;
  final String? receiverStateName;
  final int? receiverCityId;
  final String? receiverPostalCode;
  final String? receiverAddress1;
  final String? receiverAddress2;
  final String? receiverAddress3;
  final int? saveReceiverFlg;
  final String? shipmentCloseBill;
  final String? shipmentHawbCode;
  final String? receiverSmsName;
  final String? receiverSmsPhone;
  final int? activeFlg;
  final int? importApproval;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? shipmentCheckCreateLabel;
  final int? orderPickupId;
  final int? fwdId;
  final int? accountantStatus;
  final String? completedDate;
  final String? createdLableAt;
  final String? accountantCancelNote;
  final int? documentId;
  final int? oldData;
  final Service? service;
  final Branch? branch;
  final Country? country;
  final List<Package>? packages;
  final DataCosts? dataCosts;
  final int? surchargeGoodsPrice;

  ShipmentFwdModel({
    this.shipmentId,
    this.shipmentCode,
    this.shipmentServiceId,
    this.shipmentSignatureFlg,
    this.shipmentBranchId,
    this.shipmentReferenceCode,
    this.shipmentStatus,
    this.shipmentGoodsName,
    this.shipmentValue,
    this.shipmentExportAs,
    this.shipmentAmountTransport,
    this.shipmentAmountTotalCustomer,
    this.shipmentAmountSurcharge,
    this.shipmentAmountInsurance,
    this.shipmentAmountVat,
    this.shipmentAmountFsc,
    this.shipmentDomesticCharges,
    this.shipmentCollectionFee,
    this.shipmentAmountPeak,
    this.shipmentAmountResidential,
    this.shipmentPaidBy,
    this.shipmentAmountOriginal,
    this.shipmentAmountInsuranceValue,
    this.shipmentAmountProfit,
    this.shipmentAmountOperatingCosts,
    this.shipmentAmountDiscount,
    this.shipmentAmountServiceActual,
    this.shipmentTotalAmountActual,
    this.shipmentNote,
    this.shipmentFileLabel,
    this.shipmentFileProofOfPayment,
    this.shipmentPaymentMethod,
    this.shipmentIosscode,
    this.shipmentPaymentStatus,
    this.shipmentPaymentDes,
    this.shipmentPaymentStep,
    this.shipmentPaymentDate,
    this.shipmentAmountService,
    this.shipmentDebitId,
    this.checkedPaymentStatus,
    this.shipmentFinalAmount,
    this.userId,
    this.receiverId,
    this.senderCompanyName,
    this.senderContactName,
    this.senderTelephone,
    this.senderCity,
    this.senderDistrict,
    this.senderWard,
    this.senderAddress,
    this.serderLatitude,
    this.senderLongitude,
    this.receiverCompanyName,
    this.receiverContactName,
    this.receiverTelephone,
    this.receiverCountryId,
    this.receiverStateId,
    this.receiverStateName,
    this.receiverCityId,
    this.receiverPostalCode,
    this.receiverAddress1,
    this.receiverAddress2,
    this.receiverAddress3,
    this.saveReceiverFlg,
    this.shipmentCloseBill,
    this.shipmentHawbCode,
    this.receiverSmsName,
    this.receiverSmsPhone,
    this.activeFlg,
    this.importApproval,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.shipmentCheckCreateLabel,
    this.orderPickupId,
    this.fwdId,
    this.accountantStatus,
    this.completedDate,
    this.createdLableAt,
    this.accountantCancelNote,
    this.documentId,
    this.oldData,
    this.service,
    this.branch,
    this.country,
    this.packages,
    this.dataCosts,
    this.surchargeGoodsPrice,
  });

  factory ShipmentFwdModel.fromJson(Map<String, dynamic> json) {
    return ShipmentFwdModel(
      shipmentId: json['shipment_id'] as int?,
      shipmentCode: json['shipment_code'] as String?,
      shipmentServiceId: json['shipment_service_id'] as int?,
      shipmentSignatureFlg: json['shipment_signature_flg'] as int?,
      shipmentBranchId: json['shipment_branch_id'] as int?,
      shipmentReferenceCode: json['shipment_reference_code'] as String?,
      shipmentStatus: json['shipment_status'] as int?,
      shipmentGoodsName: json['shipment_goods_name'] as String?,
      shipmentValue: json['shipment_value'] as int?,
      shipmentExportAs: json['shipment_export_as'] as int?,
      shipmentAmountTransport: json['shipment_amount_transport'] as int?,
      shipmentAmountTotalCustomer:
          json['shipment_amount_total_customer'] as int?,
      shipmentAmountSurcharge: json['shipment_amount_surcharge'] as int?,
      shipmentAmountInsurance: json['shipment_amount_insurance'] as int?,
      shipmentAmountVat: json['shipment_amount_vat'] as int?,
      shipmentAmountFsc: json['shipment_amount_fsc'] as int?,
      shipmentDomesticCharges: json['shipment_domestic_charges'] as int?,
      shipmentCollectionFee: json['shipment_collection_fee'] as int?,
      shipmentAmountPeak: json['shipment_amount_peak'] as String?,
      shipmentAmountResidential: json['shipment_amount_residential'] as String?,
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
      shipmentDebitId: json['shipment_debit_id'] as int?,
      checkedPaymentStatus: json['checked_payment_status'] as int?,
      shipmentFinalAmount: json['shipment_final_amount'] as int?,
      userId: json['user_id'] as int?,
      receiverId: json['receiver_id'] as int?,
      senderCompanyName: json['sender_company_name'] as String?,
      senderContactName: json['sender_contact_name'] as String?,
      senderTelephone: json['sender_telephone'] as String?,
      senderCity: json['sender_city'] as int?,
      senderDistrict: json['sender_district'] as int?,
      senderWard: json['sender_ward'] as int?,
      senderAddress: json['sender_address'] as String?,
      serderLatitude: json['serder_latitude'] as String?,
      senderLongitude: json['sender_longitude'] as String?,
      receiverCompanyName: json['receiver_company_name'] as String?,
      receiverContactName: json['receiver_contact_name'] as String?,
      receiverTelephone: json['receiver_telephone'] as String?,
      receiverCountryId: json['receiver_country_id'] as int?,
      receiverStateId: json['receiver_state_id'] as int?,
      receiverStateName: json['receiver_state_name'] as String?,
      receiverCityId: json['receiver_city_id'] as int?,
      receiverPostalCode: json['receiver_postal_code'] as String?,
      receiverAddress1: json['receiver_address_1'] as String?,
      receiverAddress2: json['receiver_address_2'] as String?,
      receiverAddress3: json['receiver_address_3'] as String?,
      saveReceiverFlg: json['save_receiver_flg'] as int?,
      shipmentCloseBill: json['shipment_close_bill'] as String?,
      shipmentHawbCode: json['shipment_hawb_code'] as String?,
      receiverSmsName: json['receiver_sms_name'] as String?,
      receiverSmsPhone: json['receiver_sms_phone'] as String?,
      activeFlg: json['active_flg'] as int?,
      importApproval: json['import_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      shipmentCheckCreateLabel: json['shipment_check_create_label'] as int?,
      orderPickupId: json['order_pickup_id'] as int?,
      fwdId: json['fwd_id'] as int?,
      accountantStatus: json['accountant_status'] as int?,
      completedDate: json['completed_date'] as String?,
      createdLableAt: json['created_lable_at'] as String?,
      accountantCancelNote: json['accountant_cancel_note'] as String?,
      documentId: json['document_id'] as int?,
      oldData: json['old_data'] as int?,
      service: json['service'] != null
          ? Service.fromJson(json['service'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] != null
          ? Branch.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
      country: json['country'] != null
          ? Country.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      packages: json['packages'] != null
          ? (json['packages'] as List)
              .map((e) => Package.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      dataCosts: json['data_costs'] != null
          ? DataCosts.fromJson(json['data_costs'] as Map<String, dynamic>)
          : null,
      surchargeGoodsPrice: json['surcharge_goods_price'] as int?,
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
      'serder_latitude': serderLatitude,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shipment_check_create_label': shipmentCheckCreateLabel,
      'order_pickup_id': orderPickupId,
      'fwd_id': fwdId,
      'accountant_status': accountantStatus,
      'completed_date': completedDate,
      'created_lable_at': createdLableAt,
      'accountant_cancel_note': accountantCancelNote,
      'document_id': documentId,
      'old_data': oldData,
      'service': service?.toJson(),
      'branch': branch?.toJson(),
      'country': country?.toJson(),
      'packages': packages?.map((e) => e.toJson()).toList(),
      'data_costs': dataCosts?.toJson(),
      'surcharge_goods_price': surchargeGoodsPrice,
    };
  }
}

class Service {
  final int? serviceId;
  final String? serviceName;
  final String? serviceKind;
  final int? serviceVolumetricMass;
  final int? serviceApplicableWeight;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? promotionFlg;
  final String? serviceCode;
  final String? serviceNote;

  Service({
    this.serviceId,
    this.serviceName,
    this.serviceKind,
    this.serviceVolumetricMass,
    this.serviceApplicableWeight,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.promotionFlg,
    this.serviceCode,
    this.serviceNote,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['service_id'] as int?,
      serviceName: json['service_name'] as String?,
      serviceKind: json['service_kind'] as String?,
      serviceVolumetricMass: json['service_volumetric_mass'] as int?,
      serviceApplicableWeight: json['service_applicable_weight'] as int?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'promotion_flg': promotionFlg,
      'service_code': serviceCode,
      'service_note': serviceNote,
    };
  }
}

class Branch {
  final int? branchId;
  final String? branchName;
  final String? branchDescription;
  final String? branchLatitude;
  final String? branchLongitude;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Branch({
    this.branchId,
    this.branchName,
    this.branchDescription,
    this.branchLatitude,
    this.branchLongitude,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branch_id'] as int?,
      branchName: json['branch_name'] as String?,
      branchDescription: json['branch_description'] as String?,
      branchLatitude: json['branch_latitude'] as String?,
      branchLongitude: json['branch_longitude'] as String?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Country {
  final int? countryId;
  final String? countryName;
  final String? countryCode;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Country({
    this.countryId,
    this.countryName,
    this.countryCode,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: json['country_id'] as int?,
      countryName: json['country_name'] as String?,
      countryCode: json['country_code'] as String?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_id': countryId,
      'country_name': countryName,
      'country_code': countryCode,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class Package {
  final int? packageId;
  final int? shipmentId;
  final String? packageCode;
  final int? packageQuantity;
  final int? packageType;
  final String? packageDescription;
  final int? packageLength;
  final int? packageLengthActual;
  final int? packageWidth;
  final int? packageWidthActual;
  final int? packageHeight;
  final int? packageHeightActual;
  final int? packageWeight;
  final int? packageWeightActual;
  final String? packageHawbCode;
  final double? packageConvertedWeight;
  final double? packageConvertedWeightActual;
  final int? packageChargedWeight;
  final int? packageChargedWeightActual;
  final String? packageTrackingCode;
  final int? packagePrice;
  final int? packagePriceActual;
  final int? packageApprove;
  final int? processingStaffId;
  final String? carrierCode;
  final String? packageImage;
  final String? bagCode;
  final int? smTracktryId;
  final int? branchConnect;
  final String? packageStatus;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Package({
    this.packageId,
    this.shipmentId,
    this.packageCode,
    this.packageQuantity,
    this.packageType,
    this.packageDescription,
    this.packageLength,
    this.packageLengthActual,
    this.packageWidth,
    this.packageWidthActual,
    this.packageHeight,
    this.packageHeightActual,
    this.packageWeight,
    this.packageWeightActual,
    this.packageHawbCode,
    this.packageConvertedWeight,
    this.packageConvertedWeightActual,
    this.packageChargedWeight,
    this.packageChargedWeightActual,
    this.packageTrackingCode,
    this.packagePrice,
    this.packagePriceActual,
    this.packageApprove,
    this.processingStaffId,
    this.carrierCode,
    this.packageImage,
    this.bagCode,
    this.smTracktryId,
    this.branchConnect,
    this.packageStatus,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageId: json['package_id'] as int?,
      shipmentId: json['shipment_id'] as int?,
      packageCode: json['package_code'] as String?,
      packageQuantity: json['package_quantity'] as int?,
      packageType: json['package_type'] as int?,
      packageDescription: json['package_description'] as String?,
      packageLength: json['package_length'] as int?,
      packageLengthActual: json['package_length_actual'] as int?,
      packageWidth: json['package_width'] as int?,
      packageWidthActual: json['package_width_actual'] as int?,
      packageHeight: json['package_height'] as int?,
      packageHeightActual: json['package_height_actual'] as int?,
      packageWeight: json['package_weight'] as int?,
      packageWeightActual: json['package_weight_actual'] as int?,
      packageHawbCode: json['package_hawb_code'] as String?,
      packageConvertedWeight:
          (json['package_converted_weight'] as num?)?.toDouble(),
      packageConvertedWeightActual:
          (json['package_converted_weight_actual'] as num?)?.toDouble(),
      packageChargedWeight: json['package_charged_weight'] as int?,
      packageChargedWeightActual: json['package_charged_weight_actual'] as int?,
      packageTrackingCode: json['package_tracking_code'] as String?,
      packagePrice: json['package_price'] as int?,
      packagePriceActual: json['package_price_actual'] as int?,
      packageApprove: json['package_approve'] as int?,
      processingStaffId: json['processing_staff_id'] as int?,
      carrierCode: json['carrier_code'] as String?,
      packageImage: json['package_image'] as String?,
      bagCode: json['bag_code'] as String?,
      smTracktryId: json['sm_tracktry_id'] as int?,
      branchConnect: json['branch_connect'] as int?,
      packageStatus: json['package_status'] as String?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class DataCosts {
  final int? saleCost;
  final int? weight;
  final int? leaderCost;
  final int? memberCost;
  final int? leaderMemberCost;
  final int? amountWeight;
  final int? amountWeightMember;

  DataCosts({
    this.saleCost,
    this.weight,
    this.leaderCost,
    this.memberCost,
    this.leaderMemberCost,
    this.amountWeight,
    this.amountWeightMember,
  });

  factory DataCosts.fromJson(Map<String, dynamic> json) {
    return DataCosts(
      saleCost: json['sale_cost'] as int?,
      weight: json['weight'] as int?,
      leaderCost: json['leader_cost'] as int?,
      memberCost: json['member_cost'] as int?,
      leaderMemberCost: json['leader_member_cost'] as int?,
      amountWeight: json['amount_weight'] as int?,
      amountWeightMember: json['amount_weight_member'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sale_cost': saleCost,
      'weight': weight,
      'leader_cost': leaderCost,
      'member_cost': memberCost,
      'leader_member_cost': leaderMemberCost,
      'amount_weight': amountWeight,
      'amount_weight_member': amountWeightMember,
    };
  }
}

class SaleTeam {
  final int? userId;
  final int? leaderId;
  final int? memberKind;

  SaleTeam({
    this.userId,
    this.leaderId,
    this.memberKind,
  });

  factory SaleTeam.fromJson(Map<String, dynamic> json) {
    return SaleTeam(
      userId: json['user_id'] as int?,
      leaderId: json['leader_id'] as int?,
      memberKind: json['member_kind'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'leader_id': leaderId,
      'member_kind': memberKind,
    };
  }
}
