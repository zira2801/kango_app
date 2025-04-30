// Class chính chứa response
class ShipmentDebitResponse {
  final int status;
  final List<DebitShipment>? debits;

  ShipmentDebitResponse({
    required this.status,
    this.debits,
  });

  factory ShipmentDebitResponse.fromJson(Map<String, dynamic> json) {
    return ShipmentDebitResponse(
      status: json['status'] as int,
      debits: json['debits'] != null
          ? (json['debits'] as List)
              .map((item) => DebitShipment.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'debits': debits?.map((item) => item.toJson()).toList(),
    };
  }
}

// Model cho DebitShipment
class DebitShipment {
  final int shipmentId;
  final String shipmentCode;
  final int shipmentServiceId;
  final int shipmentSignatureFlg;
  final int shipmentBranchId;
  final String? shipmentReferenceCode;
  final int shipmentStatus;
  final String shipmentGoodsName;
  final int shipmentValue;
  final int shipmentExportAs;
  final int shipmentAmountTransport;
  final int shipmentAmountTotalCustomer;
  final int shipmentAmountSurcharge;
  final int shipmentAmountInsurance;
  final int shipmentAmountVat;
  final int shipmentAmountFsc;
  final int shipmentDomesticCharges;
  final int shipmentCollectionFee;
  final String? shipmentAmountPeak;
  final String? shipmentAmountResidential;
  final int shipmentPaidBy;
  final int shipmentAmountOriginal;
  final int shipmentAmountInsuranceValue;
  final int shipmentAmountProfit;
  final int shipmentAmountOperatingCosts;
  final int shipmentAmountDiscount;
  final int shipmentAmountServiceActual;
  final int shipmentTotalAmountActual;
  final String? shipmentNote;
  final String? shipmentFileLabel;
  final String? shipmentFileProofOfPayment;
  final int shipmentPaymentMethod;
  final String? shipmentIosscode;
  final int shipmentPaymentStatus;
  final String? shipmentPaymentDes;
  final int shipmentPaymentStep;
  final String? shipmentPaymentDate;
  final int shipmentAmountService;
  final String shipmentDebitId;
  final int checkedPaymentStatus;
  final int shipmentFinalAmount;
  final int userId;
  final int? receiverId;
  final String senderCompanyName;
  final String senderContactName;
  final String senderTelephone;
  final int senderCity;
  final int senderDistrict;
  final int senderWard;
  final String senderAddress;
  final String? serderLatitude;
  final String? senderLongitude;
  final String receiverCompanyName;
  final String receiverContactName;
  final String receiverTelephone;
  final int receiverCountryId;
  final int receiverStateId;
  final String receiverStateName;
  final int receiverCityId;
  final String receiverPostalCode;
  final String receiverAddress1;
  final String receiverAddress2;
  final String receiverAddress3;
  final int saveReceiverFlg;
  final String? shipmentCloseBill;
  final String? shipmentHawbCode;
  final String? receiverSmsName;
  final String receiverSmsPhone;
  final int activeFlg;
  final int importApproval;
  final int deleteFlg;
  final String createdAt;
  final String updatedAt;
  final int shipmentCheckCreateLabel;
  final int? orderPickupId;
  final int? fwdId;
  final int accountantStatus;
  final String completedDate;
  final String? createdLableAt;
  final String? accountantCancelNote;
  final int? documentId;
  final int oldData;

  DebitShipment({
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
    required this.shipmentAmountFsc,
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
    required this.shipmentDebitId,
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
    this.serderLatitude,
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
    required this.receiverAddress2,
    required this.receiverAddress3,
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
    this.createdLableAt,
    this.accountantCancelNote,
    this.documentId,
    required this.oldData,
  });

  factory DebitShipment.fromJson(Map<String, dynamic> json) {
    return DebitShipment(
      shipmentId: json['shipment_id'] as int,
      shipmentCode: json['shipment_code'] as String? ?? '',
      shipmentServiceId: json['shipment_service_id'] as int,
      shipmentSignatureFlg: json['shipment_signature_flg'] as int,
      shipmentBranchId: json['shipment_branch_id'] as int,
      shipmentReferenceCode: json['shipment_reference_code'] as String?,
      shipmentStatus: json['shipment_status'] as int,
      shipmentGoodsName: json['shipment_goods_name'] as String? ?? '',
      shipmentValue: json['shipment_value'] as int,
      shipmentExportAs: json['shipment_export_as'] as int,
      shipmentAmountTransport: json['shipment_amount_transport'] as int,
      shipmentAmountTotalCustomer:
          json['shipment_amount_total_customer'] as int,
      shipmentAmountSurcharge: json['shipment_amount_surcharge'] as int,
      shipmentAmountInsurance: json['shipment_amount_insurance'] as int,
      shipmentAmountVat: json['shipment_amount_vat'] as int,
      shipmentAmountFsc: json['shipment_amount_fsc'] as int,
      shipmentDomesticCharges: json['shipment_domestic_charges'] as int,
      shipmentCollectionFee: json['shipment_collection_fee'] as int,
      shipmentAmountPeak: json['shipment_amount_peak'] as String? ?? '',
      shipmentAmountResidential:
          json['shipment_amount_residential'] as String? ?? '',
      shipmentPaidBy: json['shipment_paid_by'] as int,
      shipmentAmountOriginal: json['shipment_amount_original'] as int,
      shipmentAmountInsuranceValue:
          json['shipment_amount_insurance_value'] as int,
      shipmentAmountProfit: json['shipment_amount_profit'] as int,
      shipmentAmountOperatingCosts:
          json['shipment_amount_operating_costs'] as int,
      shipmentAmountDiscount: json['shipment_amount_discount'] as int,
      shipmentAmountServiceActual:
          json['shipment_amount_service_actual'] as int,
      shipmentTotalAmountActual: json['shipment_total_amount_actual'] as int,
      shipmentNote: json['shipment_note'] as String?,
      shipmentFileLabel: json['shipment_file_label'] as String?,
      shipmentFileProofOfPayment:
          json['shipment_file_proof_of_payment'] as String?,
      shipmentPaymentMethod: json['shipment_payment_method'] as int,
      shipmentIosscode: json['shipment_iosscode'] as String?,
      shipmentPaymentStatus: json['shipment_payment_status'] as int,
      shipmentPaymentDes: json['shipment_payment_des'] as String?,
      shipmentPaymentStep: json['shipment_payment_step'] as int,
      shipmentPaymentDate: json['shipment_payment_date'] as String?,
      shipmentAmountService: json['shipment_amount_service'] as int,
      shipmentDebitId: json['shipment_debit_id'] as String? ?? '',
      checkedPaymentStatus: json['checked_payment_status'] as int,
      shipmentFinalAmount: json['shipment_final_amount'] as int,
      userId: json['user_id'] as int,
      receiverId: json['receiver_id'] as int?,
      senderCompanyName: json['sender_company_name'] as String? ?? '',
      senderContactName: json['sender_contact_name'] as String? ?? '',
      senderTelephone: json['sender_telephone'] as String? ?? '',
      senderCity: json['sender_city'] as int,
      senderDistrict: json['sender_district'] as int,
      senderWard: json['sender_ward'] as int,
      senderAddress: json['sender_address'] as String? ?? '',
      serderLatitude: json['serder_latitude'] as String?,
      senderLongitude: json['sender_longitude'] as String?,
      receiverCompanyName: json['receiver_company_name'] as String? ?? '',
      receiverContactName: json['receiver_contact_name'] as String? ?? '',
      receiverTelephone: json['receiver_telephone'] as String? ?? '',
      receiverCountryId: json['receiver_country_id'] as int,
      receiverStateId: json['receiver_state_id'] as int,
      receiverStateName: json['receiver_state_name'] as String? ?? '',
      receiverCityId: json['receiver_city_id'] as int,
      receiverPostalCode: json['receiver_postal_code'] as String? ?? '',
      receiverAddress1: json['receiver_address_1'] as String? ?? '',
      receiverAddress2: json['receiver_address_2'] as String? ?? '',
      receiverAddress3: json['receiver_address_3'] as String? ?? '',
      saveReceiverFlg: json['save_receiver_flg'] as int,
      shipmentCloseBill: json['shipment_close_bill'] as String?,
      shipmentHawbCode: json['shipment_hawb_code'] as String?,
      receiverSmsName: json['receiver_sms_name'] as String?,
      receiverSmsPhone: json['receiver_sms_phone'] as String? ?? '',
      activeFlg: json['active_flg'] as int,
      importApproval: json['import_approval'] as int,
      deleteFlg: json['delete_flg'] as int,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      shipmentCheckCreateLabel: json['shipment_check_create_label'] as int,
      orderPickupId: json['order_pickup_id'] as int?,
      fwdId: json['fwd_id'] as int?,
      accountantStatus: json['accountant_status'] as int,
      completedDate: json['completed_date'] as String? ?? '',
      createdLableAt: json['created_lable_at'] as String?,
      accountantCancelNote: json['accountant_cancel_note'] as String?,
      documentId: json['document_id'] as int?,
      oldData: json['old_data'] as int,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
      'shipment_check_create_label': shipmentCheckCreateLabel,
      'order_pickup_id': orderPickupId,
      'fwd_id': fwdId,
      'accountant_status': accountantStatus,
      'completed_date': completedDate,
      'created_lable_at': createdLableAt,
      'accountant_cancel_note': accountantCancelNote,
      'document_id': documentId,
      'old_data': oldData,
    };
  }
}
