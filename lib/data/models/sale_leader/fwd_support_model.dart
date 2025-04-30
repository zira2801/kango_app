// Main Response Model
class ResponseFwdSupportModel {
  final int? status;
  final SaleManagerModel? saleManager;
  final CompanyModel? company;

  ResponseFwdSupportModel({
    this.status,
    this.saleManager,
    this.company,
  });

  // FromJson Constructor
  factory ResponseFwdSupportModel.fromJson(Map<String, dynamic> json) {
    return ResponseFwdSupportModel(
      status: json['status'] as int?,
      saleManager: json['sale_manager'] != null
          ? SaleManagerModel.fromJson(json['sale_manager'])
          : null,
      company: json['company'] != null
          ? CompanyModel.fromJson(json['company'])
          : null,
    );
  }

  // ToJson Method
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'sale_manager': saleManager?.toJson(),
      'company': company?.toJson(),
    };
  }
}

class SaleManagerModel {
  final int? userId;
  final String? userName;
  final String? userCode;
  final String? userApiKey;
  final String? password;
  final String? passwordShow;
  final int? positionId;
  final int? branchId;
  final String? userContactName;
  final String? userPhone;
  final String? userAddress;
  final double? userLatitude;
  final double? userLongitude;
  final String? userSignature;
  final int? userLimitAmountForSale;
  final int? activeFlg;
  final int? isExport;
  final int? userPendingApproval;
  final int? deleteFlg;
  final String? rememberToken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userAccountantKey;
  final String? userCompanyName;
  final String? userTaxCode;
  final String? userAddress1;
  final String? userAddress2;
  final String? userAddress3;
  final String? userLogo;
  final int? userDebitType;
  final int? userPriceListMainType;
  final int? userPriceListChangeType;
  final DateTime? userPriceListChangeDate;
  final int? userRemainingLimit;
  final int? userKpiId;
  final int? userIsFreeTime;
  final String? contractYears;

  SaleManagerModel({
    this.userId,
    this.userName,
    this.userCode,
    this.userApiKey,
    this.password,
    this.passwordShow,
    this.positionId,
    this.branchId,
    this.userContactName,
    this.userPhone,
    this.userAddress,
    this.userLatitude,
    this.userLongitude,
    this.userSignature,
    this.userLimitAmountForSale,
    this.activeFlg,
    this.isExport,
    this.userPendingApproval,
    this.deleteFlg,
    this.rememberToken,
    this.createdAt,
    this.updatedAt,
    this.userAccountantKey,
    this.userCompanyName,
    this.userTaxCode,
    this.userAddress1,
    this.userAddress2,
    this.userAddress3,
    this.userLogo,
    this.userDebitType,
    this.userPriceListMainType,
    this.userPriceListChangeType,
    this.userPriceListChangeDate,
    this.userRemainingLimit,
    this.userKpiId,
    this.userIsFreeTime,
    this.contractYears,
  });

  // FromJson Constructor
  factory SaleManagerModel.fromJson(Map<String, dynamic> json) {
    return SaleManagerModel(
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userCode: json['user_code'] as String?,
      userApiKey: json['user_api_key'] as String?,
      password: json['password'] as String?,
      passwordShow: json['password_show'] as String?,
      positionId: json['position_id'] as int?,
      branchId: json['branch_id'] as int?,
      userContactName: json['user_contact_name'] as String?,
      userPhone: json['user_phone'] as String?,
      userAddress: json['user_address'] as String?,
      userLatitude: json['user_latitude'] != null
          ? double.tryParse(json['user_latitude'].toString())
          : null,
      userLongitude: json['user_longitude'] != null
          ? double.tryParse(json['user_longitude'].toString())
          : null,
      userSignature: json['user_signature'] as String?,
      userLimitAmountForSale: json['user_limit_amount_for_sale'] as int?,
      activeFlg: json['active_flg'] as int?,
      isExport: json['is_export'] as int?,
      userPendingApproval: json['user_pending_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      rememberToken: json['remember_token'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      userAccountantKey: json['user_accountant_key'] as String?,
      userCompanyName: json['user_company_name'] as String?,
      userTaxCode: json['user_tax_code'] as String?,
      userAddress1: json['user_address_1'] as String?,
      userAddress2: json['user_address_2'] as String?,
      userAddress3: json['user_address_3'] as String?,
      userLogo: json['user_logo'] as String?,
      userDebitType: json['user_debit_type'] as int?,
      userPriceListMainType: json['user_price_list_main_type'] as int?,
      userPriceListChangeType: json['user_price_list_change_type'] as int?,
      userPriceListChangeDate: json['user_price_list_change_date'] != null
          ? DateTime.tryParse(json['user_price_list_change_date'].toString())
          : null,
      userRemainingLimit: json['user_remaining_limit'] as int?,
      userKpiId: json['user_kpi_id'] as int?,
      userIsFreeTime: json['user_is_free_time'] as int?,
      contractYears: json['contract_years'] as String?,
    );
  }

  // ToJson Method
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_code': userCode,
      'user_api_key': userApiKey,
      'password': password,
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
      'remember_token': rememberToken,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
      'user_price_list_change_date': userPriceListChangeDate?.toIso8601String(),
      'user_remaining_limit': userRemainingLimit,
      'user_kpi_id': userKpiId,
      'user_is_free_time': userIsFreeTime,
      'contract_years': contractYears,
    };
  }
}

class CompanyModel {
  final int? userId;
  final String? userName;
  final String? userCode;
  final String? userApiKey;
  final String? passwordShow;
  final int? positionId;
  final int? branchId;
  final String? userContactName;
  final String? userPhone;
  final String? userAddress;
  final double? userLatitude;
  final double? userLongitude;
  final String? userSignature;
  final int? userLimitAmountForSale;
  final int? activeFlg;
  final int? isExport;
  final int? userPendingApproval;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? userAccountantKey;
  final String? userCompanyName;
  final String? userTaxCode;
  final String? userAddress1;
  final String? userAddress2;
  final String? userAddress3;
  final String? userLogo;
  final int? userDebitType;
  final int? userPriceListMainType;
  final int? userPriceListChangeType;
  final DateTime? userPriceListChangeDate;
  final int? userRemainingLimit;
  final int? userKpiId;
  final int? userIsFreeTime;
  final String? contractYears;

  CompanyModel({
    this.userId,
    this.userName,
    this.userCode,
    this.userApiKey,
    this.passwordShow,
    this.positionId,
    this.branchId,
    this.userContactName,
    this.userPhone,
    this.userAddress,
    this.userLatitude,
    this.userLongitude,
    this.userSignature,
    this.userLimitAmountForSale,
    this.activeFlg,
    this.isExport,
    this.userPendingApproval,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.userAccountantKey,
    this.userCompanyName,
    this.userTaxCode,
    this.userAddress1,
    this.userAddress2,
    this.userAddress3,
    this.userLogo,
    this.userDebitType,
    this.userPriceListMainType,
    this.userPriceListChangeType,
    this.userPriceListChangeDate,
    this.userRemainingLimit,
    this.userKpiId,
    this.userIsFreeTime,
    this.contractYears,
  });

  // FromJson Constructor
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userCode: json['user_code'] as String?,
      userApiKey: json['user_api_key'] as String?,
      passwordShow: json['password_show'] as String?,
      positionId: json['position_id'] as int?,
      branchId: json['branch_id'] as int?,
      userContactName: json['user_contact_name'] as String?,
      userPhone: json['user_phone'] as String?,
      userAddress: json['user_address'] as String?,
      userLatitude: json['user_latitude'] != null
          ? double.tryParse(json['user_latitude'].toString())
          : null,
      userLongitude: json['user_longitude'] != null
          ? double.tryParse(json['user_longitude'].toString())
          : null,
      userSignature: json['user_signature'] as String?,
      userLimitAmountForSale: json['user_limit_amount_for_sale'] as int?,
      activeFlg: json['active_flg'] as int?,
      isExport: json['is_export'] as int?,
      userPendingApproval: json['user_pending_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      userAccountantKey: json['user_accountant_key'] as String?,
      userCompanyName: json['user_company_name'] as String?,
      userTaxCode: json['user_tax_code'] as String?,
      userAddress1: json['user_address_1'] as String?,
      userAddress2: json['user_address_2'] as String?,
      userAddress3: json['user_address_3'] as String?,
      userLogo: json['user_logo'] as String?,
      userDebitType: json['user_debit_type'] as int?,
      userPriceListMainType: json['user_price_list_main_type'] as int?,
      userPriceListChangeType: json['user_price_list_change_type'] as int?,
      userPriceListChangeDate: json['user_price_list_change_date'] != null
          ? DateTime.tryParse(json['user_price_list_change_date'].toString())
          : null,
      userRemainingLimit: json['user_remaining_limit'] as int?,
      userKpiId: json['user_kpi_id'] as int?,
      userIsFreeTime: json['user_is_free_time'] as int?,
      contractYears: json['contract_years'] as String?,
    );
  }

  // ToJson Method
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
      'user_price_list_change_date': userPriceListChangeDate?.toIso8601String(),
      'user_remaining_limit': userRemainingLimit,
      'user_kpi_id': userKpiId,
      'user_is_free_time': userIsFreeTime,
      'contract_years': contractYears,
    };
  }
}
