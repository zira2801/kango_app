// Để sử dụng model với danh sách users từ JSON
class UserFwdNoLinkResponse {
  final int status;
  final List<UserFwdNoLink> fwds;

  UserFwdNoLinkResponse({
    required this.status,
    required this.fwds,
  });

  factory UserFwdNoLinkResponse.fromJson(Map<String, dynamic> json) {
    return UserFwdNoLinkResponse(
      status: json['status'] as int,
      fwds: (json['fwds'] as List<dynamic>)
          .map((e) => UserFwdNoLink.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'fwds': fwds.map((e) => e.toJson()).toList(),
    };
  }
}

class UserFwdNoLink {
  final int? userId;
  final String? userName;
  final String? userCode;
  final String? passwordShow;
  final int? positionId;
  final int? branchId;
  final String? userContactName;
  final String? userPhone;
  final String? userAddress;
  final String? userLatitude;
  final String? userLongitude;
  final String? userSignature;
  final double? userLimitAmountForSale;
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
  final double? userRemainingLimit;
  final int? userKpiId;
  final int? userIsFreeTime;
  final int? contractYears;

  UserFwdNoLink({
    this.userId,
    this.userName,
    this.userCode,
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

  factory UserFwdNoLink.fromJson(Map<String, dynamic> json) {
    return UserFwdNoLink(
      userId: json['user_id'] as int?,
      userName: json['user_name'] as String?,
      userCode: json['user_code'] as String?,
      passwordShow: json['password_show'] as String?,
      positionId: json['position_id'] as int?,
      branchId: json['branch_id'] as int?,
      userContactName: json['user_contact_name'] as String?,
      userPhone: json['user_phone'] as String?,
      userAddress: json['user_address'] as String?,
      userLatitude: json['user_latitude'] as String?,
      userLongitude: json['user_longitude'] as String?,
      userSignature: json['user_signature'] as String?,
      userLimitAmountForSale: json['user_limit_amount_for_sale'] != null
          ? (json['user_limit_amount_for_sale'] as num?)?.toDouble()
          : null,
      activeFlg: json['active_flg'] as int?,
      isExport: json['is_export'] as int?,
      userPendingApproval: json['user_pending_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
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
          ? DateTime.parse(json['user_price_list_change_date'] as String)
          : null,
      userRemainingLimit: json['user_remaining_limit'] != null
          ? (json['user_remaining_limit'] as num?)?.toDouble()
          : null,
      userKpiId: json['user_kpi_id'] as int?,
      userIsFreeTime: json['user_is_free_time'] as int?,
      contractYears: json['contract_years'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_code': userCode,
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
