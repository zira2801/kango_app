// Class chính chứa toàn bộ response
import 'dart:convert';

class DebitDetailResponse {
  final int status;
  final DebitDetail? debit;
  final UserDebit? userDebit;
  final String? content;

  DebitDetailResponse({
    required this.status,
    this.debit,
    this.userDebit,
    this.content,
  });

  factory DebitDetailResponse.fromJson(Map<String, dynamic> json) {
    return DebitDetailResponse(
      status: json['status'] as int,
      debit: json['debit'] != null ? DebitDetail.fromJson(json['debit']) : null,
      userDebit: json['user_debit'] != null
          ? UserDebit.fromJson(json['user_debit'])
          : null,
      content: json['content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'debit': debit?.toJson(),
      'user_debit': userDebit?.toJson(),
      'content': content,
    };
  }
}

class DebitDetail {
  final int shipmentFinalAmount;
  final int shipmentAmountFsc;
  final int totalPrice;
  final int totalVat;
  final int totalFsc;
  final int totalSm;
  final String methodLabel;
  final int debitId;
  final String debitNo;
  final int paymentByStatement;
  final dynamic statementId;
  final int customerId;
  final int createdBy;
  final String? debitNote;
  final int debitStatus;
  final int debitType;
  final String debitFsc;
  final String? debitAdvanceDate;
  final String? debitAdvanceNote;
  final List<String>? debitAdvanceImages;
  final int debitAdvanceAmount;
  final String? debitPaymentDate;
  final int debitPaymentAmount;
  final int debitAccount;
  final int activeFlg;
  final int deleteFlg;
  final String createdAt;
  final String updatedAt;
  final List<String>? debitImages;
  final int paymentMethod;
  final int checkedPaymentStatus;

  DebitDetail({
    required this.shipmentFinalAmount,
    required this.shipmentAmountFsc,
    required this.totalPrice,
    required this.totalVat,
    required this.totalFsc,
    required this.totalSm,
    required this.methodLabel,
    required this.debitId,
    required this.debitNo,
    required this.paymentByStatement,
    this.statementId,
    required this.customerId,
    required this.createdBy,
    this.debitNote,
    required this.debitStatus,
    required this.debitType,
    required this.debitFsc,
    this.debitAdvanceDate,
    this.debitAdvanceNote,
    this.debitAdvanceImages,
    required this.debitAdvanceAmount,
    this.debitPaymentDate,
    required this.debitPaymentAmount,
    required this.debitAccount,
    required this.activeFlg,
    required this.deleteFlg,
    required this.createdAt,
    required this.updatedAt,
    this.debitImages,
    required this.paymentMethod,
    required this.checkedPaymentStatus,
  });

  factory DebitDetail.fromJson(Map<String, dynamic> json) {
    return DebitDetail(
      shipmentFinalAmount: json['shipment_final_amount'] as int,
      shipmentAmountFsc: json['shipment_amount_fsc'] as int,
      totalPrice: json['total_price'] as int,
      totalVat: json['total_vat'] as int,
      totalFsc: json['total_fsc'] as int,
      totalSm: json['total_sm'] as int,
      methodLabel: json['method_label'] as String,
      debitId: json['debit_id'] as int,
      debitNo: json['debit_no'] as String,
      paymentByStatement: json['payment_by_statement'] as int,
      statementId: json['statement_id'],
      customerId: json['customer_id'] as int,
      createdBy: json['created_by'] as int,
      debitNote: json['debit_note'] as String?,
      debitStatus: json['debit_status'] as int,
      debitType: json['debit_type'] as int,
      debitFsc: json['debit_fsc'] as String,
      debitAdvanceDate: json['debit_advance_date'] as String?,
      debitAdvanceNote: json['debit_advance_note'] as String?,
      debitAdvanceImages: json['debit_advance_images'] != null
          ? (json['debit_advance_images'] is String
              ? List<String>.from(jsonDecode(json['debit_advance_images']))
              : List<String>.from(json['debit_advance_images']))
          : null,
      debitAdvanceAmount: json['debit_advance_amount'] as int,
      debitPaymentDate: json['debit_payment_date'] as String?,
      debitPaymentAmount: json['debit_payment_amount'] as int,
      debitAccount: json['debit_account'] as int,
      activeFlg: json['active_flg'] as int,
      deleteFlg: json['delete_flg'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      debitImages: json['debit_images'] != null
          ? (json['debit_images'] is String
              ? List<String>.from(jsonDecode(json['debit_images']))
              : List<String>.from(json['debit_images']))
          : null,
      paymentMethod: json['payment_method'] as int,
      checkedPaymentStatus: json['checked_payment_status'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shipment_final_amount': shipmentFinalAmount,
      'shipment_amount_fsc': shipmentAmountFsc,
      'total_price': totalPrice,
      'total_vat': totalVat,
      'total_fsc': totalFsc,
      'total_sm': totalSm,
      'method_label': methodLabel,
      'debit_id': debitId,
      'debit_no': debitNo,
      'payment_by_statement': paymentByStatement,
      'statement_id': statementId,
      'customer_id': customerId,
      'created_by': createdBy,
      'debit_note': debitNote,
      'debit_status': debitStatus,
      'debit_type': debitType,
      'debit_fsc': debitFsc,
      'debit_advance_date': debitAdvanceDate,
      'debit_advance_note': debitAdvanceNote,
      'debit_advance_images': debitAdvanceImages,
      'debit_advance_amount': debitAdvanceAmount,
      'debit_payment_date': debitPaymentDate,
      'debit_payment_amount': debitPaymentAmount,
      'debit_account': debitAccount,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'debit_images': debitImages,
      'payment_method': paymentMethod,
      'checked_payment_status': checkedPaymentStatus,
    };
  }
}

// Model cho UserDebit
class UserDebit {
  final int userId;
  final String userName;
  final String userCode;
  final String userApiKey;
  final String passwordShow;
  final int positionId;
  final int branchId;
  final String userContactName;
  final String userPhone;
  final String userAddress;
  final String userLatitude;
  final String userLongitude;
  final String? userSignature;
  final int userLimitAmountForSale;
  final int activeFlg;
  final int isExport;
  final int userPendingApproval;
  final int deleteFlg;
  final String createdAt;
  final String updatedAt;
  final String userAccountantKey;
  final String userCompanyName;
  final String userTaxCode;
  final String userAddress1;
  final String userAddress2;
  final String userAddress3;
  final String userLogo;
  final int userDebitType;
  final int userPriceListMainType;
  final dynamic userPriceListChangeType;
  final String? userPriceListChangeDate;
  final int userRemainingLimit;
  final dynamic userKpiId;
  final int userIsFreeTime;
  final dynamic contractYears;

  UserDebit({
    required this.userId,
    required this.userName,
    required this.userCode,
    required this.userApiKey,
    required this.passwordShow,
    required this.positionId,
    required this.branchId,
    required this.userContactName,
    required this.userPhone,
    required this.userAddress,
    required this.userLatitude,
    required this.userLongitude,
    this.userSignature,
    required this.userLimitAmountForSale,
    required this.activeFlg,
    required this.isExport,
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
    this.userPriceListChangeType,
    this.userPriceListChangeDate,
    required this.userRemainingLimit,
    this.userKpiId,
    required this.userIsFreeTime,
    this.contractYears,
  });

  factory UserDebit.fromJson(Map<String, dynamic> json) {
    return UserDebit(
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      userCode: json['user_code'] as String,
      userApiKey: json['user_api_key'] as String,
      passwordShow: json['password_show'] as String,
      positionId: json['position_id'] as int,
      branchId: json['branch_id'] as int,
      userContactName: json['user_contact_name'] as String,
      userPhone: json['user_phone'] as String,
      userAddress: json['user_address'] as String,
      userLatitude: json['user_latitude'] as String,
      userLongitude: json['user_longitude'] as String,
      userSignature: json['user_signature'] as String?,
      userLimitAmountForSale: json['user_limit_amount_for_sale'] as int,
      activeFlg: json['active_flg'] as int,
      isExport: json['is_export'] as int,
      userPendingApproval: json['user_pending_approval'] as int,
      deleteFlg: json['delete_flg'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      userAccountantKey: json['user_accountant_key'] as String,
      userCompanyName: json['user_company_name'] as String,
      userTaxCode: json['user_tax_code'] as String,
      userAddress1: json['user_address_1'] as String,
      userAddress2: json['user_address_2'] as String,
      userAddress3: json['user_address_3'] as String,
      userLogo: json['user_logo'] as String,
      userDebitType: json['user_debit_type'] as int,
      userPriceListMainType: json['user_price_list_main_type'] as int,
      userPriceListChangeType: json['user_price_list_change_type'],
      userPriceListChangeDate: json['user_price_list_change_date'] as String?,
      userRemainingLimit: json['user_remaining_limit'] as int,
      userKpiId: json['user_kpi_id'],
      userIsFreeTime: json['user_is_free_time'] as int,
      contractYears: json['contract_years'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_code': userCode,
      'user_api_key': userApiKey,
      'password_show': passwordShow,
      'position_id': positionId,
      'branch_id': branchId,
      'user_contact_name': userContactName,
      'user_phone': userPhone,
      'user_address': userAddress,
      'user_latitude': userLatitude,
      'user_longitude': userLongitude,
      'user_signature': userSignature,
      'user_limit_amount_for_sale': userLimitAmountForSale,
      'active_flg': activeFlg,
      'is_export': isExport,
      'user_pending_approval': userPendingApproval,
      'delete_flg': deleteFlg,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'user_accountant_key': userAccountantKey,
      'user_company_name': userCompanyName,
      'user_tax_code': userTaxCode,
      'user_address_1': userAddress1,
      'user_address_2': userAddress2,
      'user_address_3': userAddress3,
      'user_logo': userLogo,
      'user_debit_type': userDebitType,
      'user_price_list_main_type': userPriceListMainType,
      'user_price_list_change_type': userPriceListChangeType,
      'user_price_list_change_date': userPriceListChangeDate,
      'user_remaining_limit': userRemainingLimit,
      'user_kpi_id': userKpiId,
      'user_is_free_time': userIsFreeTime,
      'contract_years': contractYears,
    };
  }
}
