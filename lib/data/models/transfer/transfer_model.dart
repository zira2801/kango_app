// Main response model
import 'dart:convert';
import 'dart:developer';

import 'package:scan_barcode_app/data/env/index.dart';

class TransferResponse {
  final int? status;
  final TransferHtml? html;

  TransferResponse({
    this.status,
    this.html,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      status: json['status'] as int?,
      html: json['html'] != null ? TransferHtml.fromJson(json['html']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'html': html?.toJson(),
    };
  }
}

class TransferHtml {
  final int? currentPage;
  final List<Transfer>? data;

  TransferHtml({
    this.currentPage,
    this.data,
  });

  factory TransferHtml.fromJson(Map<String, dynamic> json) {
    return TransferHtml(
      currentPage: json['current_page'] as int?,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => Transfer.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

// Transfer Model
class Transfer {
  final int? transferId;
  final int? userId;
  final String? transferContent;
  final String? transferImages;
  final int? transferStatus;
  final int? transferReviewerId;
  final int? activeFlg;
  final int? deleteFlg;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? receiverName;
  final String? receiverPhone;
  final String? receiverAddress;
  final User? user;
  final Reviewer? reviewer;
  final List<ShipmentTransfer>? transferShipments;

  Transfer({
    this.transferId,
    this.userId,
    this.transferContent,
    this.transferImages,
    this.transferStatus,
    this.transferReviewerId,
    this.activeFlg,
    this.deleteFlg,
    this.createdAt,
    this.updatedAt,
    this.receiverName,
    this.receiverPhone,
    this.receiverAddress,
    this.user,
    this.reviewer,
    this.transferShipments,
  });
  List<String> get parsedImages {
    if (transferImages == null || transferImages!.isEmpty) {
      return [];
    }

    try {
      // Thử in ra để debug
      print("Original transfer_images: $transferImages");

      // Xử lý chuỗi JSON
      String cleaned = transferImages!;

      // Parse chuỗi JSON
      var decoded = jsonDecode(cleaned);
      if (decoded is List) {
        // Nếu là List thì chuyển đổi thành List<String>
        List<String> imageUrls =
            decoded.map<String>((img) => img.toString()).toList();
        // Thêm base URL và xử lý các ký tự escape
        return imageUrls.map<String>((img) {
          String cleanedPath = img.replaceAll('\\\/', '/');
          return "$httpImage$cleanedPath";
        }).toList();
      } else {
        log("JSON decoded is not a List: $decoded");
        return [];
      }
    } catch (e) {
      log("Error parsing images: $e");
      // Trả về danh sách rỗng để tránh lỗi
      return [];
    }
  }

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      transferId: json['transfer_id'] as int?,
      userId: json['user_id'] as int?,
      transferContent: json['transfer_content'] as String?,
      transferImages: json['transfer_images'] as String?,
      transferStatus: json['transfer_status'] as int?,
      transferReviewerId: json['transfer_reviewer_id'] as int?,
      activeFlg: json['active_flg'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      receiverName: json['receiver_name'] as String?,
      receiverPhone: json['receiver_phone'] as String?,
      receiverAddress: json['receiver_address'] as String?,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      reviewer:
          json['reviewer'] != null ? Reviewer.fromJson(json['reviewer']) : null,
      transferShipments: json['transfer_shipments'] != null
          ? (json['transfer_shipments'] as List)
              .map((item) => ShipmentTransfer.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transfer_id': transferId,
      'user_id': userId,
      'transfer_content': transferContent,
      'transfer_images': transferImages,
      'transfer_status': transferStatus,
      'transfer_reviewer_id': transferReviewerId,
      'active_flg': activeFlg,
      'delete_flg': deleteFlg,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'receiver_address': receiverAddress,
      'user': user?.toJson(),
      'reviewer': reviewer?.toJson(),
      'transfer_shipments': transferShipments,
    };
  }
}

class ShipmentTransfer {
  final int? id;
  final int? shipmentID;
  final int? transferID;
  final dynamic shipmentCode;
  final DateTime? createAt;
  final DateTime? updateAt;

  ShipmentTransfer(
      {this.id,
      this.shipmentID,
      this.transferID,
      required this.shipmentCode,
      this.createAt,
      this.updateAt});

  factory ShipmentTransfer.fromJson(Map<String, dynamic> json) {
    return ShipmentTransfer(
      id: json['id'] ?? '',
      shipmentID: json['shipment_id'] ?? '',
      transferID: json['transfer_id'] ?? '',
      shipmentCode: json['shipment_code'] ?? '',
      createAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updateAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shipment_id': shipmentID,
      'transfer_id': transferID,
      'shipment_code': shipmentCode,
      'create_at': createAt,
      'updated_at': updateAt
    };
  }
}

// User Model
class User {
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
  final String? userDebitType;
  final int? userPriceListMainType;
  final int? userPriceListChangeType;
  final DateTime? userPriceListChangeDate;
  final int? userRemainingLimit;
  final int? userKpiId;
  final int? userIsFreeTime;
  final String? contractYears;

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
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
      userLatitude: json['user_latitude']?.toDouble(),
      userLongitude: json['user_longitude']?.toDouble(),
      userSignature: json['user_signature'] as String?,
      userLimitAmountForSale: json['user_limit_amount_for_sale'] as int?,
      activeFlg: json['active_flg'] as int?,
      isExport: json['is_export'] as int?,
      userPendingApproval: json['user_pending_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userAccountantKey: json['user_accountant_key'] as String?,
      userCompanyName: json['user_company_name'] as String?,
      userTaxCode: json['user_tax_code'] as String?,
      userAddress1: json['user_address_1'] as String?,
      userAddress2: json['user_address_2'] as String?,
      userAddress3: json['user_address_3'] as String?,
      userLogo: json['user_logo'] as String?,
      userDebitType: json['user_debit_type'] as String?,
      userPriceListMainType: json['user_price_list_main_type'] as int?,
      userPriceListChangeType: json['user_price_list_change_type'] as int?,
      userPriceListChangeDate: json['user_price_list_change_date'] != null
          ? DateTime.parse(json['user_price_list_change_date'])
          : null,
      userRemainingLimit: json['user_remaining_limit'] as int?,
      userKpiId: json['user_kpi_id'] as int?,
      userIsFreeTime: json['user_is_free_time'] as int?,
      contractYears: json['contract_years'] as String?,
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

// Reviewer Model
class Reviewer {
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
  final String? userDebitType;
  final int? userPriceListMainType;
  final int? userPriceListChangeType;
  final DateTime? userPriceListChangeDate;
  final int? userRemainingLimit;
  final int? userKpiId;
  final int? userIsFreeTime;
  final String? contractYears;

  Reviewer({
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

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
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
      userLatitude: json['user_latitude']?.toDouble(),
      userLongitude: json['user_longitude']?.toDouble(),
      userSignature: json['user_signature'] as String?,
      userLimitAmountForSale: json['user_limit_amount_for_sale'] as int?,
      activeFlg: json['active_flg'] as int?,
      isExport: json['is_export'] as int?,
      userPendingApproval: json['user_pending_approval'] as int?,
      deleteFlg: json['delete_flg'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      userAccountantKey: json['user_accountant_key'] as String?,
      userCompanyName: json['user_company_name'] as String?,
      userTaxCode: json['user_tax_code'] as String?,
      userAddress1: json['user_address_1'] as String?,
      userAddress2: json['user_address_2'] as String?,
      userAddress3: json['user_address_3'] as String?,
      userLogo: json['user_logo'] as String?,
      userDebitType: json['user_debit_type'] as String?,
      userPriceListMainType: json['user_price_list_main_type'] as int?,
      userPriceListChangeType: json['user_price_list_change_type'] as int?,
      userPriceListChangeDate: json['user_price_list_change_date'] != null
          ? DateTime.parse(json['user_price_list_change_date'])
          : null,
      userRemainingLimit: json['user_remaining_limit'] as int?,
      userKpiId: json['user_kpi_id'] as int?,
      userIsFreeTime: json['user_is_free_time'] as int?,
      contractYears: json['contract_years'] as String?,
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
