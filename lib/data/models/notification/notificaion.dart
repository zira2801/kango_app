import 'dart:convert';

NotificationResponse notificationModelFromJson(String str) =>
    NotificationResponse.fromJson(json.decode(str));

String notificationModelToJson(NotificationResponse data) =>
    json.encode(data.toJson());

class NotificationResponse {
  final int status;
  final NotificationPage notifications;

  NotificationResponse({
    required this.status,
    required this.notifications,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'],
      notifications: NotificationPage.fromJson(json['notifications']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'notifications': notifications.toJson(),
    };
  }
}

class NotificationPage {
  final int currentPage;
  final List<NotificationItem> data;

  NotificationPage({
    required this.currentPage,
    required this.data,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    return NotificationPage(
      currentPage: json['current_page'],
      data: (json['data'] as List)
          .map((item) => NotificationItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class NotificationItem {
  final int? notificationId; // Cho phép null
  final int? userId; // Cho phép null
  final String notificationTitle;
  final int? notificationImportant; // Cho phép null
  final String? notificationFile;
  final String createdAt;
  final UserNotification user;

  NotificationItem({
    this.notificationId, // Không còn required
    this.userId, // Không còn required
    required this.notificationTitle,
    this.notificationImportant, // Không còn required
    this.notificationFile,
    required this.createdAt,
    required this.user,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notification_id'],
      userId: json['user_id'],
      notificationTitle:
          json['notification_title'] ?? '', // Giá trị mặc định nếu null
      notificationImportant: json['notification_important'],
      notificationFile: json['notification_file'] ?? null,
      createdAt: json['created_at'] ?? '', // Giá trị mặc định nếu null
      user: UserNotification.fromJson(
          json['user'] ?? {}), // Giá trị mặc định nếu null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_id': notificationId,
      'user_id': userId,
      'notification_title': notificationTitle,
      'notification_important': notificationImportant,
      'notification_file': notificationFile,
      'created_at': createdAt,
      'user': user.toJson(),
    };
  }

  @override
  String toString() {
    return 'NotificationItem(notificationId: $notificationId, userId: $userId, title: $notificationTitle, createdAt: $createdAt, user: $user)';
  }
}

class UserNotification {
  final int? userId; // Cho phép null
  final String userName;
  final String userCode;
  final String userApiKey;
  final String passwordShow;
  final int? positionId; // Cho phép null
  final int? branchId; // Cho phép null
  final String userContactName;
  final String userPhone;
  final String userAddress;
  final dynamic userLatitude;
  final dynamic userLongitude;
  final dynamic userSignature;
  final dynamic userLimitAmountForSale;
  final int? activeFlg; // Cho phép null
  final int? isExport; // Cho phép null
  final int? userPendingApproval; // Cho phép null
  final int? deleteFlg; // Cho phép null
  final String createdAt;
  final String updatedAt;
  final String? userAccountantKey;
  final String userCompanyName;
  final String? userTaxCode;
  final String? userAddress1;
  final String? userAddress2;
  final String? userAddress3;
  final String? userLogo;
  final dynamic userDebitType;
  final int? userPriceListMainType; // Cho phép null
  final dynamic userPriceListChangeType;
  final dynamic userPriceListChangeDate;
  final int? userRemainingLimit; // Cho phép null
  final dynamic userKpiId;
  final int? userIsFreeTime; // Cho phép null
  final dynamic contractYears;

  UserNotification({
    this.userId, // Không còn required
    required this.userName,
    required this.userCode,
    required this.userApiKey,
    required this.passwordShow,
    this.positionId, // Không còn required
    this.branchId, // Không còn required
    required this.userContactName,
    required this.userPhone,
    required this.userAddress,
    this.userLatitude,
    this.userLongitude,
    this.userSignature,
    this.userLimitAmountForSale,
    this.activeFlg, // Không còn required
    this.isExport, // Không còn required
    this.userPendingApproval, // Không còn required
    this.deleteFlg, // Không còn required
    required this.createdAt,
    required this.updatedAt,
    this.userAccountantKey,
    required this.userCompanyName,
    this.userTaxCode,
    this.userAddress1,
    this.userAddress2,
    this.userAddress3,
    this.userLogo,
    this.userDebitType,
    this.userPriceListMainType, // Không còn required
    this.userPriceListChangeType,
    this.userPriceListChangeDate,
    this.userRemainingLimit, // Không còn required
    this.userKpiId,
    this.userIsFreeTime, // Không còn required
    this.contractYears,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      userId: json['user_id'],
      userName: json['user_name'] ?? '', // Giá trị mặc định nếu null
      userCode: json['user_code'] ?? '', // Giá trị mặc định nếu null
      userApiKey: json['user_api_key'] ?? '', // Giá trị mặc định nếu null
      passwordShow: json['password_show'] ?? '', // Giá trị mặc định nếu null
      positionId: json['position_id'],
      branchId: json['branch_id'],
      userContactName:
          json['user_contact_name'] ?? '', // Giá trị mặc định nếu null
      userPhone: json['user_phone'] ?? '', // Giá trị mặc định nếu null
      userAddress: json['user_address'] ?? '', // Giá trị mặc định nếu null
      userLatitude: json['user_latitude'],
      userLongitude: json['user_longitude'],
      userSignature: json['user_signature'],
      userLimitAmountForSale: json['user_limit_amount_for_sale'],
      activeFlg: json['active_flg'],
      isExport: json['is_export'],
      userPendingApproval: json['user_pending_approval'],
      deleteFlg: json['delete_flg'],
      createdAt: json['created_at'] ?? '', // Giá trị mặc định nếu null
      updatedAt: json['updated_at'] ?? '', // Giá trị mặc định nếu null
      userAccountantKey: json['user_accountant_key'],
      userCompanyName:
          json['user_company_name'] ?? '', // Giá trị mặc định nếu null
      userTaxCode: json['user_tax_code'],
      userAddress1: json['user_address_1'],
      userAddress2: json['user_address_2'],
      userAddress3: json['user_address_3'],
      userLogo: json['user_logo'],
      userDebitType: json['user_debit_type'],
      userPriceListMainType: json['user_price_list_main_type'],
      userPriceListChangeType: json['user_price_list_change_type'],
      userPriceListChangeDate: json['user_price_list_change_date'],
      userRemainingLimit: json['user_remaining_limit'],
      userKpiId: json['user_kpi_id'],
      userIsFreeTime: json['user_is_free_time'],
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

  @override
  String toString() {
    return 'UserNotification(id: $userId, name: $userName, phone: $userPhone, address: $userAddress)';
  }
}
